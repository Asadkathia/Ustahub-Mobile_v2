-- Quote Requests Table
CREATE TABLE public.quote_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consumer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    address_id UUID NOT NULL REFERENCES public.addresses(id) ON DELETE RESTRICT,
    description TEXT,
    preferred_date DATE,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'responded', 'expired', 'cancelled')),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Quote Responses Table
CREATE TABLE public.quote_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quote_request_id UUID NOT NULL REFERENCES public.quote_requests(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    estimated_duration TEXT,
    is_accepted BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(quote_request_id, provider_id)
);

-- Price History Table (for tracking price trends)
CREATE TABLE public.price_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES public.plans(id) ON DELETE SET NULL,
    price DECIMAL(10, 2) NOT NULL,
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_quote_requests_consumer ON public.quote_requests(consumer_id);
CREATE INDEX idx_quote_requests_service ON public.quote_requests(service_id);
CREATE INDEX idx_quote_requests_status ON public.quote_requests(status);
CREATE INDEX idx_quote_responses_quote ON public.quote_responses(quote_request_id);
CREATE INDEX idx_quote_responses_provider ON public.quote_responses(provider_id);
CREATE INDEX idx_price_history_provider_service ON public.price_history(provider_id, service_id);

-- Trigger for updated_at
CREATE TRIGGER update_quote_requests_updated_at BEFORE UPDATE ON public.quote_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quote_responses_updated_at BEFORE UPDATE ON public.quote_responses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS Policies
ALTER TABLE public.quote_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quote_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.price_history ENABLE ROW LEVEL SECURITY;

-- Quote Requests Policies
CREATE POLICY "Consumers can view own quote requests"
    ON public.quote_requests FOR SELECT
    USING (auth.uid() = consumer_id);

CREATE POLICY "Providers can view quote requests for their services"
    ON public.quote_requests FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.provider_services ps
            WHERE ps.service_id = quote_requests.service_id
            AND ps.provider_id = auth.uid()
        )
    );

CREATE POLICY "Consumers can create quote requests"
    ON public.quote_requests FOR INSERT
    WITH CHECK (auth.uid() = consumer_id);

CREATE POLICY "Consumers can update own quote requests"
    ON public.quote_requests FOR UPDATE
    USING (auth.uid() = consumer_id);

CREATE POLICY "Consumers can delete own quote requests"
    ON public.quote_requests FOR DELETE
    USING (auth.uid() = consumer_id);

-- Quote Responses Policies
CREATE POLICY "Anyone can view quote responses for accessible quote requests"
    ON public.quote_responses FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.quote_requests qr
            WHERE qr.id = quote_responses.quote_request_id
            AND (
                qr.consumer_id = auth.uid()
                OR quote_responses.provider_id = auth.uid()
            )
        )
    );

CREATE POLICY "Providers can create quote responses"
    ON public.quote_responses FOR INSERT
    WITH CHECK (auth.uid() = provider_id);

CREATE POLICY "Providers can update own quote responses"
    ON public.quote_responses FOR UPDATE
    USING (auth.uid() = provider_id);

CREATE POLICY "Consumers can accept quote responses"
    ON public.quote_responses FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.quote_requests qr
            WHERE qr.id = quote_responses.quote_request_id
            AND qr.consumer_id = auth.uid()
        )
    );

-- Price History Policies
CREATE POLICY "Anyone can view price history"
    ON public.price_history FOR SELECT
    USING (true);

CREATE POLICY "Providers can insert own price history"
    ON public.price_history FOR INSERT
    WITH CHECK (auth.uid() = provider_id);

