-- Onboarding slides sourced from banners

CREATE TABLE IF NOT EXISTS public.onboarding_slides (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    banner_id UUID REFERENCES public.banners(id) ON DELETE SET NULL,
    title TEXT,
    subtitle TEXT,
    description TEXT,
    locale TEXT DEFAULT 'en',
    audience TEXT DEFAULT 'all' CHECK (audience IN ('all', 'consumer', 'provider', 'guest')),
    cta_text TEXT,
    cta_route TEXT,
    image_override TEXT,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_onboarding_slides_active_order
    ON public.onboarding_slides (is_active, display_order);

CREATE INDEX IF NOT EXISTS idx_onboarding_slides_banner
    ON public.onboarding_slides (banner_id);

ALTER TABLE public.onboarding_slides ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read onboarding slides" ON public.onboarding_slides;
CREATE POLICY "Public can read onboarding slides"
    ON public.onboarding_slides FOR SELECT
    USING (is_active = true);

DROP TRIGGER IF EXISTS update_onboarding_slides_updated_at ON public.onboarding_slides;
CREATE TRIGGER update_onboarding_slides_updated_at
    BEFORE UPDATE ON public.onboarding_slides
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Seed the onboarding slides table with the first few active banners (idempotent)
INSERT INTO public.onboarding_slides (
    banner_id,
    title,
    subtitle,
    description,
    cta_text,
    cta_route,
    display_order
)
SELECT
    b.id,
    COALESCE(b.title, 'Trusted local experts'),
    'Book verified providers in minutes',
    'Ustahub connects you with vetted pros for every household need.',
    'Continue',
    '/login',
    ROW_NUMBER() OVER (ORDER BY b.display_order, b.created_at)
FROM public.banners b
WHERE b.is_active = true
  AND NOT EXISTS (
      SELECT 1 FROM public.onboarding_slides
  )
ORDER BY b.display_order, b.created_at
LIMIT 3;

