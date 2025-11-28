-- Relax RLS on ratings so mobile app can insert ratings without booking_id

ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;

-- Replace old insert policy that required a completed booking
DROP POLICY IF EXISTS "Consumers can create ratings" ON public.ratings;

CREATE POLICY "Consumers can create ratings"
ON public.ratings
FOR INSERT
WITH CHECK (auth.uid() = consumer_id);


