-- Align ratings table with mobile app expectations
-- 1) Add review column (app sends 'review')
-- 2) Make booking_id nullable so ratings can be left unbound to a specific booking
-- 3) Drop strict unique constraint on (booking_id, consumer_id) if present

ALTER TABLE public.ratings
ADD COLUMN IF NOT EXISTS review TEXT;

ALTER TABLE public.ratings
ALTER COLUMN booking_id DROP NOT NULL;

ALTER TABLE public.ratings
DROP CONSTRAINT IF EXISTS ratings_booking_id_consumer_id_key;


