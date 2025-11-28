-- Booking Chat (1:1, booking-bound conversations)

-- Conversations are always tied to a booking and are implicitly 1:1
-- between the booking's consumer and provider.
CREATE TABLE IF NOT EXISTS public.booking_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL UNIQUE REFERENCES public.bookings(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    closed_at TIMESTAMPTZ
);

-- Participants in a conversation (redundant with bookings.consumer_id / provider_id
-- but useful for generic querying and future extensions).
CREATE TABLE IF NOT EXISTS public.booking_conversation_participants (
    conversation_id UUID NOT NULL REFERENCES public.booking_conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('consumer', 'provider')),
    last_read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (conversation_id, user_id)
);

-- Individual chat messages bound to a booking (and optionally a conversation).
CREATE TABLE IF NOT EXISTS public.booking_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES public.booking_conversations(id) ON DELETE CASCADE,
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes to speed up common chat queries
CREATE INDEX IF NOT EXISTS idx_booking_messages_booking_created_at
    ON public.booking_messages(booking_id, created_at ASC);

CREATE INDEX IF NOT EXISTS idx_booking_conversations_booking_id
    ON public.booking_conversations(booking_id);

-- Enable RLS for chat tables
ALTER TABLE public.booking_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.booking_conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.booking_messages ENABLE ROW LEVEL SECURITY;

-- Helper condition: a user is the consumer or provider for a booking
-- (used inside policies).
CREATE OR REPLACE FUNCTION public.is_booking_user(p_booking_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM public.bookings b
        WHERE b.id = p_booking_id
        AND (b.consumer_id = auth.uid() OR b.provider_id = auth.uid())
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- booking_conversations policies
DROP POLICY IF EXISTS "Users can view their booking conversations" ON public.booking_conversations;
CREATE POLICY "Users can view their booking conversations"
ON public.booking_conversations
FOR SELECT
USING (public.is_booking_user(booking_id));

DROP POLICY IF EXISTS "Users can insert booking conversations for their bookings" ON public.booking_conversations;
CREATE POLICY "Users can insert booking conversations for their bookings"
ON public.booking_conversations
FOR INSERT
WITH CHECK (public.is_booking_user(booking_id));

DROP POLICY IF EXISTS "Users can update their booking conversations" ON public.booking_conversations;
CREATE POLICY "Users can update their booking conversations"
ON public.booking_conversations
FOR UPDATE
USING (public.is_booking_user(booking_id))
WITH CHECK (public.is_booking_user(booking_id));

-- booking_conversation_participants policies
DROP POLICY IF EXISTS "Users can view conversation participants" ON public.booking_conversation_participants;
CREATE POLICY "Users can view conversation participants"
ON public.booking_conversation_participants
FOR SELECT
USING (
    EXISTS (
        SELECT 1
        FROM public.booking_conversations c
        WHERE c.id = booking_conversation_participants.conversation_id
        AND public.is_booking_user(c.booking_id)
    )
);

DROP POLICY IF EXISTS "Users can manage participants for their conversations" ON public.booking_conversation_participants;
CREATE POLICY "Users can manage participants for their conversations"
ON public.booking_conversation_participants
FOR ALL
USING (
    EXISTS (
        SELECT 1
        FROM public.booking_conversations c
        WHERE c.id = booking_conversation_participants.conversation_id
        AND public.is_booking_user(c.booking_id)
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM public.booking_conversations c
        WHERE c.id = booking_conversation_participants.conversation_id
        AND public.is_booking_user(c.booking_id)
    )
);

-- booking_messages policies:
-- Users can only see and send messages for bookings where they are consumer/provider.
DROP POLICY IF EXISTS "Users can view booking messages" ON public.booking_messages;
CREATE POLICY "Users can view booking messages"
ON public.booking_messages
FOR SELECT
USING (public.is_booking_user(booking_id));

DROP POLICY IF EXISTS "Users can insert booking messages while booking is active" ON public.booking_messages;
CREATE POLICY "Users can insert booking messages while booking is active"
ON public.booking_messages
FOR INSERT
WITH CHECK (
    public.is_booking_user(booking_id)
    AND EXISTS (
        SELECT 1
        FROM public.bookings b
        WHERE b.id = public.booking_messages.booking_id
        AND b.status IN ('pending', 'accepted', 'in_progress')
    )
    AND sender_id = auth.uid()
);

DROP POLICY IF EXISTS "Users can soft-delete their booking messages" ON public.booking_messages;
CREATE POLICY "Users can soft-delete their booking messages"
ON public.booking_messages
FOR UPDATE
USING (sender_id = auth.uid() AND public.is_booking_user(booking_id))
WITH CHECK (sender_id = auth.uid() AND public.is_booking_user(booking_id));

-- Add chat tables to Supabase realtime publication so Flutter streams
-- receive live updates without manual refresh.
DO $$
BEGIN
  -- booking_messages is the only table we stream in the app right now,
  -- but we add all three for future flexibility.
  BEGIN
    ALTER PUBLICATION supabase_realtime
      ADD TABLE public.booking_messages,
                public.booking_conversations,
                public.booking_conversation_participants;
  EXCEPTION
    WHEN duplicate_object THEN
      NULL; -- tables already in publication, safe to ignore
    WHEN undefined_object THEN
      NULL; -- publication does not exist (e.g. local dev), safe to ignore
  END;
END;
$$;


