-- Add images column to booking_notes to support note attachments

ALTER TABLE public.booking_notes
ADD COLUMN IF NOT EXISTS images TEXT[] DEFAULT ARRAY[]::TEXT[];


