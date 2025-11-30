-- Provider Portfolio/Work Gallery Table
CREATE TABLE public.provider_portfolios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    service_id UUID REFERENCES public.services(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    project_date DATE,
    image_urls TEXT[] NOT NULL DEFAULT '{}',
    video_url TEXT,
    tags TEXT[],
    is_featured BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_portfolios_provider ON public.provider_portfolios(provider_id);
CREATE INDEX idx_portfolios_service ON public.provider_portfolios(service_id);
CREATE INDEX idx_portfolios_featured ON public.provider_portfolios(is_featured) WHERE is_featured = true;

-- Trigger for updated_at
CREATE TRIGGER update_portfolios_updated_at BEFORE UPDATE ON public.provider_portfolios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS Policies
ALTER TABLE public.provider_portfolios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Providers can view all portfolios"
    ON public.provider_portfolios FOR SELECT
    USING (true);

CREATE POLICY "Providers can insert own portfolios"
    ON public.provider_portfolios FOR INSERT
    WITH CHECK (auth.uid() = provider_id);

CREATE POLICY "Providers can update own portfolios"
    ON public.provider_portfolios FOR UPDATE
    USING (auth.uid() = provider_id);

CREATE POLICY "Providers can delete own portfolios"
    ON public.provider_portfolios FOR DELETE
    USING (auth.uid() = provider_id);

