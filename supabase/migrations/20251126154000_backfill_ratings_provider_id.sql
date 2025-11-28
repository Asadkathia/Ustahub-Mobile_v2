-- Backfill ratings.provider_id from bookings.provider_id
-- so provider detail pages can correctly load historical reviews.

UPDATE public.ratings r
SET provider_id = b.provider_id
FROM public.bookings b
WHERE r.booking_id = b.id
  AND r.provider_id <> b.provider_id;



