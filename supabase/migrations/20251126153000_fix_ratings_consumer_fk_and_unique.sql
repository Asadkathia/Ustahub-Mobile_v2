-- Point ratings.consumer_id FK to user_profiles (for provider ratings join)
-- and enforce one rating per booking per consumer (when booking_id is present).

ALTER TABLE public.ratings
DROP CONSTRAINT IF EXISTS ratings_consumer_id_fkey;

ALTER TABLE public.ratings
ADD CONSTRAINT ratings_consumer_id_fkey
FOREIGN KEY (consumer_id) REFERENCES public.user_profiles(id) ON DELETE CASCADE;

-- Enforce at most one rating per booking per consumer (when booking_id is not null)
CREATE UNIQUE INDEX IF NOT EXISTS idx_ratings_booking_consumer_unique
ON public.ratings(booking_id, consumer_id)
WHERE booking_id IS NOT NULL;


