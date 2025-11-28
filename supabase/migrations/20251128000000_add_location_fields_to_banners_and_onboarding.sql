-- Add location fields to banners and onboarding_slides for location-based content

-- Add location fields to banners table
ALTER TABLE public.banners
ADD COLUMN IF NOT EXISTS city TEXT,
ADD COLUMN IF NOT EXISTS country TEXT DEFAULT 'all';

-- Add location fields to onboarding_slides table
ALTER TABLE public.onboarding_slides
ADD COLUMN IF NOT EXISTS city TEXT,
ADD COLUMN IF NOT EXISTS country TEXT DEFAULT 'all';

-- Create indexes for location-based queries
CREATE INDEX IF NOT EXISTS idx_banners_location 
    ON public.banners (city, country) 
    WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_onboarding_slides_location 
    ON public.onboarding_slides (city, country) 
    WHERE is_active = true;

-- Update existing records to have 'all' as default country if null
UPDATE public.banners 
SET country = 'all' 
WHERE country IS NULL;

UPDATE public.onboarding_slides 
SET country = 'all' 
WHERE country IS NULL;

