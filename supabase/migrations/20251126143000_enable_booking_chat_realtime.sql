-- Ensure booking chat tables are part of the supabase_realtime publication
-- so Supabase Flutter streams receive live updates.

DO $$
BEGIN
  BEGIN
    ALTER PUBLICATION supabase_realtime
      ADD TABLE public.booking_messages,
                public.booking_conversations,
                public.booking_conversation_participants;
  EXCEPTION
    WHEN duplicate_object THEN
      NULL; -- tables already added, safe to ignore
    WHEN undefined_object THEN
      NULL; -- publication missing (e.g. local dev), safe to ignore
  END;
END;
$$;


