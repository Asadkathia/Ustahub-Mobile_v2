-- Initial Database Schema for Ustahub
-- This migration creates all core tables for the marketplace

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
-- Note: gen_random_uuid() is available from pgcrypto, no need for uuid-ossp

-- User Profiles (extends Supabase auth.users)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    avatar TEXT,
    phone TEXT,
    role TEXT NOT NULL CHECK (role IN ('consumer', 'provider')),
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Addresses
CREATE TABLE public.addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    address_line1 TEXT NOT NULL,
    address_line2 TEXT,
    city TEXT NOT NULL,
    state TEXT,
    postal_code TEXT,
    country TEXT DEFAULT 'UZ',
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_default_address UNIQUE (user_id, is_default) DEFERRABLE INITIALLY DEFERRED
);

-- Services (Service Categories)
CREATE TABLE public.services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    image TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Providers
CREATE TABLE public.providers (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    business_name TEXT,
    business_license TEXT,
    is_verified BOOLEAN DEFAULT false,
    background_check_status TEXT DEFAULT 'pending',
    average_rating DECIMAL(3, 2) DEFAULT 0.00,
    total_ratings INTEGER DEFAULT 0,
    total_bookings INTEGER DEFAULT 0,
    completed_bookings INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Provider Services (Many-to-Many)
CREATE TABLE public.provider_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(provider_id, service_id)
);

-- Plans (Service Plans: Basic, Standard, Premium)
CREATE TABLE public.plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_service_id UUID NOT NULL REFERENCES public.provider_services(id) ON DELETE CASCADE,
    plan_type TEXT NOT NULL CHECK (plan_type IN ('basic', 'standard', 'premium')),
    plan_price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    features JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(provider_service_id, plan_type)
);

-- Bookings
CREATE TABLE public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id TEXT UNIQUE NOT NULL,
    consumer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES public.plans(id) ON DELETE SET NULL,
    address_id UUID NOT NULL REFERENCES public.addresses(id) ON DELETE RESTRICT,
    booking_date DATE NOT NULL,
    booking_time TIME NOT NULL,
    note TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'in_progress', 'completed', 'cancelled')),
    remark TEXT,
    otp TEXT,
    visiting_charge DECIMAL(10, 2) DEFAULT 0.00,
    service_fee DECIMAL(10, 2) DEFAULT 0.00,
    item_total DECIMAL(10, 2) DEFAULT 0.00,
    item_discount DECIMAL(10, 2) DEFAULT 0.00,
    total DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Booking Notes
CREATE TABLE public.booking_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    note TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ratings
CREATE TABLE public.ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    consumer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating DECIMAL(2, 1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(booking_id, consumer_id)
);

-- Favorites
CREATE TABLE public.favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consumer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(consumer_id, provider_id)
);

-- Banners
CREATE TABLE public.banners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    image TEXT NOT NULL,
    title TEXT,
    link TEXT,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Provider Documents (KYC)
CREATE TABLE public.provider_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL,
    document_url TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Wallet Transactions
CREATE TABLE public.wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('credit', 'debit')),
    amount DECIMAL(10, 2) NOT NULL,
    balance_after DECIMAL(10, 2) NOT NULL,
    description TEXT,
    reference_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Wallet Balance
CREATE TABLE public.wallet_balance (
    provider_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    balance DECIMAL(10, 2) DEFAULT 0.00,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- FCM Tokens
CREATE TABLE public.fcm_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    device_type TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, token)
);

-- OTP Verifications (for custom OTP flow)
CREATE TABLE public.otp_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    otp TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_addresses_user_id ON public.addresses(user_id);
CREATE INDEX idx_addresses_default ON public.addresses(user_id, is_default) WHERE is_default = true;
CREATE INDEX idx_provider_services_provider ON public.provider_services(provider_id);
CREATE INDEX idx_provider_services_service ON public.provider_services(service_id);
CREATE INDEX idx_plans_provider_service ON public.plans(provider_service_id);
CREATE INDEX idx_bookings_consumer ON public.bookings(consumer_id);
CREATE INDEX idx_bookings_provider ON public.bookings(provider_id);
CREATE INDEX idx_bookings_status ON public.bookings(status);
CREATE INDEX idx_bookings_date ON public.bookings(booking_date);
CREATE INDEX idx_ratings_provider ON public.ratings(provider_id);
CREATE INDEX idx_favorites_consumer ON public.favorites(consumer_id);
CREATE INDEX idx_favorites_provider ON public.favorites(provider_id);
CREATE INDEX idx_wallet_transactions_provider ON public.wallet_transactions(provider_id);
CREATE INDEX idx_fcm_tokens_user ON public.fcm_tokens(user_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_addresses_updated_at BEFORE UPDATE ON public.addresses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON public.services
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_providers_updated_at BEFORE UPDATE ON public.providers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_plans_updated_at BEFORE UPDATE ON public.plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON public.bookings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ratings_updated_at BEFORE UPDATE ON public.ratings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_banners_updated_at BEFORE UPDATE ON public.banners
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_provider_documents_updated_at BEFORE UPDATE ON public.provider_documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_wallet_balance_updated_at BEFORE UPDATE ON public.wallet_balance
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fcm_tokens_updated_at BEFORE UPDATE ON public.fcm_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) Policies
-- Enable RLS on all tables

-- User Profiles
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "Users can read own profile"
    ON public.user_profiles FOR SELECT
    USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON public.user_profiles FOR UPDATE
    USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile"
    ON public.user_profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Public read access to provider profiles
CREATE POLICY "Public can read provider profiles"
    ON public.user_profiles FOR SELECT
    USING (role = 'provider' AND is_verified = true);

-- Addresses
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;

-- Users can manage their own addresses
CREATE POLICY "Users can manage own addresses"
    ON public.addresses FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Services
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

-- Public read access to active services
CREATE POLICY "Public can read active services"
    ON public.services FOR SELECT
    USING (is_active = true);

-- Providers
ALTER TABLE public.providers ENABLE ROW LEVEL SECURITY;

-- Public read access to verified providers
CREATE POLICY "Public can read verified providers"
    ON public.providers FOR SELECT
    USING (is_verified = true);

-- Providers can update their own data
CREATE POLICY "Providers can update own data"
    ON public.providers FOR UPDATE
    USING (auth.uid() = id);

-- Providers can insert their own data
CREATE POLICY "Providers can insert own data"
    ON public.providers FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Provider Services
ALTER TABLE public.provider_services ENABLE ROW LEVEL SECURITY;

-- Public read access
CREATE POLICY "Public can read provider services"
    ON public.provider_services FOR SELECT
    USING (true);

-- Providers can manage their own services
CREATE POLICY "Providers can manage own services"
    ON public.provider_services FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.providers
            WHERE providers.id = provider_services.provider_id
            AND providers.id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.providers
            WHERE providers.id = provider_services.provider_id
            AND providers.id = auth.uid()
        )
    );

-- Plans
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;

-- Public read access
CREATE POLICY "Public can read plans"
    ON public.plans FOR SELECT
    USING (true);

-- Providers can manage plans for their services
CREATE POLICY "Providers can manage own plans"
    ON public.plans FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.provider_services ps
            JOIN public.providers p ON p.id = ps.provider_id
            WHERE ps.id = plans.provider_service_id
            AND p.id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.provider_services ps
            JOIN public.providers p ON p.id = ps.provider_id
            WHERE ps.id = plans.provider_service_id
            AND p.id = auth.uid()
        )
    );

-- Bookings
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Consumers can read their own bookings
CREATE POLICY "Consumers can read own bookings"
    ON public.bookings FOR SELECT
    USING (auth.uid() = consumer_id);

-- Consumers can create bookings
CREATE POLICY "Consumers can create bookings"
    ON public.bookings FOR INSERT
    WITH CHECK (auth.uid() = consumer_id);

-- Providers can read bookings assigned to them
CREATE POLICY "Providers can read own bookings"
    ON public.bookings FOR SELECT
    USING (auth.uid() = provider_id);

-- Providers can update booking status
CREATE POLICY "Providers can update booking status"
    ON public.bookings FOR UPDATE
    USING (auth.uid() = provider_id)
    WITH CHECK (auth.uid() = provider_id);

-- Consumers can update their own bookings (for cancellation)
CREATE POLICY "Consumers can update own bookings"
    ON public.bookings FOR UPDATE
    USING (auth.uid() = consumer_id)
    WITH CHECK (auth.uid() = consumer_id);

-- Booking Notes
ALTER TABLE public.booking_notes ENABLE ROW LEVEL SECURITY;

-- Users can read notes for bookings they're involved in
CREATE POLICY "Users can read booking notes"
    ON public.booking_notes FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.bookings
            WHERE bookings.id = booking_notes.booking_id
            AND (bookings.consumer_id = auth.uid() OR bookings.provider_id = auth.uid())
        )
    );

-- Users can add notes to bookings they're involved in
CREATE POLICY "Users can add booking notes"
    ON public.booking_notes FOR INSERT
    WITH CHECK (
        auth.uid() = user_id
        AND EXISTS (
            SELECT 1 FROM public.bookings
            WHERE bookings.id = booking_notes.booking_id
            AND (bookings.consumer_id = auth.uid() OR bookings.provider_id = auth.uid())
        )
    );

-- Ratings
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;

-- Public read access to ratings
CREATE POLICY "Public can read ratings"
    ON public.ratings FOR SELECT
    USING (true);

-- Consumers can create ratings for their bookings
CREATE POLICY "Consumers can create ratings"
    ON public.ratings FOR INSERT
    WITH CHECK (
        auth.uid() = consumer_id
        AND EXISTS (
            SELECT 1 FROM public.bookings
            WHERE bookings.id = ratings.booking_id
            AND bookings.consumer_id = auth.uid()
            AND bookings.status = 'completed'
        )
    );

-- Users can update their own ratings
CREATE POLICY "Users can update own ratings"
    ON public.ratings FOR UPDATE
    USING (auth.uid() = consumer_id)
    WITH CHECK (auth.uid() = consumer_id);

-- Favorites
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

-- Users can manage their own favorites
CREATE POLICY "Users can manage own favorites"
    ON public.favorites FOR ALL
    USING (auth.uid() = consumer_id)
    WITH CHECK (auth.uid() = consumer_id);

-- Public read access to favorite counts (via aggregation)
CREATE POLICY "Public can read favorites"
    ON public.favorites FOR SELECT
    USING (true);

-- Banners
ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;

-- Public read access to active banners
CREATE POLICY "Public can read active banners"
    ON public.banners FOR SELECT
    USING (is_active = true);

-- Provider Documents
ALTER TABLE public.provider_documents ENABLE ROW LEVEL SECURITY;

-- Providers can read their own documents
CREATE POLICY "Providers can read own documents"
    ON public.provider_documents FOR SELECT
    USING (auth.uid() = provider_id);

-- Providers can upload their own documents
CREATE POLICY "Providers can upload own documents"
    ON public.provider_documents FOR INSERT
    WITH CHECK (auth.uid() = provider_id);

-- Wallet Transactions
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;

-- Providers can read their own transactions
CREATE POLICY "Providers can read own transactions"
    ON public.wallet_transactions FOR SELECT
    USING (auth.uid() = provider_id);

-- Wallet Balance
ALTER TABLE public.wallet_balance ENABLE ROW LEVEL SECURITY;

-- Providers can read their own balance
CREATE POLICY "Providers can read own balance"
    ON public.wallet_balance FOR SELECT
    USING (auth.uid() = provider_id);

-- FCM Tokens
ALTER TABLE public.fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Users can manage their own FCM tokens
CREATE POLICY "Users can manage own FCM tokens"
    ON public.fcm_tokens FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- OTP Verifications (no RLS - managed by Edge Functions with service role)

-- Database Functions for Complex Queries

-- Function to get available booking slots for a provider
CREATE OR REPLACE FUNCTION get_booking_slots(
    p_provider_id UUID,
    p_booking_date DATE
)
RETURNS TABLE (
    time_slot TIME,
    is_available BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    WITH all_slots AS (
        SELECT unnest(ARRAY[
            '08:00:00'::TIME, '09:00:00'::TIME, '10:00:00'::TIME,
            '11:00:00'::TIME, '12:00:00'::TIME, '13:00:00'::TIME,
            '14:00:00'::TIME, '15:00:00'::TIME, '16:00:00'::TIME,
            '17:00:00'::TIME, '18:00:00'::TIME, '19:00:00'::TIME,
            '20:00:00'::TIME
        ]) AS slot
    ),
    booked_slots AS (
        SELECT DISTINCT booking_time
        FROM public.bookings
        WHERE provider_id = p_provider_id
        AND booking_date = p_booking_date
        AND status IN ('pending', 'accepted', 'in_progress')
    )
    SELECT 
        all_slots.slot AS time_slot,
        CASE WHEN booked_slots.booking_time IS NULL THEN true ELSE false END AS is_available
    FROM all_slots
    LEFT JOIN booked_slots ON all_slots.slot = booked_slots.booking_time
    ORDER BY all_slots.slot;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to calculate booking total
CREATE OR REPLACE FUNCTION calculate_booking_total(
    p_service_id UUID,
    p_plan_id UUID,
    p_visiting_charge DECIMAL DEFAULT 0
)
RETURNS TABLE (
    item_total DECIMAL,
    service_fee DECIMAL,
    total DECIMAL
) AS $$
DECLARE
    v_plan_price DECIMAL;
    v_item_total DECIMAL;
    v_service_fee DECIMAL;
    v_total DECIMAL;
BEGIN
    -- Get plan price
    SELECT plan_price INTO v_plan_price
    FROM public.plans
    WHERE id = p_plan_id;
    
    -- Calculate item total (plan price + visiting charge)
    v_item_total := COALESCE(v_plan_price, 0) + COALESCE(p_visiting_charge, 0);
    
    -- Service fee (5% of item total)
    v_service_fee := v_item_total * 0.05;
    
    -- Total
    v_total := v_item_total + v_service_fee;
    
    RETURN QUERY SELECT v_item_total, v_service_fee, v_total;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get provider dashboard data
CREATE OR REPLACE FUNCTION get_provider_dashboard_data(
    p_provider_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'overview', json_build_object(
            'booking_request', (
                SELECT COUNT(*)::INTEGER
                FROM public.bookings
                WHERE provider_id = p_provider_id
                AND status = 'pending'
            ),
            'calendar', (
                SELECT COUNT(*)::INTEGER
                FROM public.bookings
                WHERE provider_id = p_provider_id
                AND booking_date >= CURRENT_DATE
                AND status IN ('accepted', 'in_progress')
            ),
            'completed', (
                SELECT COUNT(*)::INTEGER
                FROM public.bookings
                WHERE provider_id = p_provider_id
                AND status = 'completed'
            ),
            'earnings', (
                SELECT COALESCE(SUM(total), 0)
                FROM public.bookings
                WHERE provider_id = p_provider_id
                AND status = 'completed'
            )
        ),
        'recent_bookings', (
            SELECT json_agg(
                json_build_object(
                    'id', id,
                    'booking_id', booking_id,
                    'consumer_id', consumer_id,
                    'service_id', service_id,
                    'booking_date', booking_date,
                    'booking_time', booking_time,
                    'status', status,
                    'total', total
                )
            )
            FROM (
                SELECT *
                FROM public.bookings
                WHERE provider_id = p_provider_id
                ORDER BY created_at DESC
                LIMIT 10
            ) recent
        )
    ) INTO v_result;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to search providers with filters
CREATE OR REPLACE FUNCTION search_providers(
    p_search_term TEXT DEFAULT NULL,
    p_service_id UUID DEFAULT NULL,
    p_min_rating DECIMAL DEFAULT NULL,
    p_location TEXT DEFAULT NULL
)
RETURNS TABLE (
    provider_id UUID,
    name TEXT,
    avatar TEXT,
    average_rating DECIMAL,
    total_ratings INTEGER,
    services JSONB,
    is_favorite BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        up.id AS provider_id,
        up.name,
        up.avatar,
        p.average_rating,
        p.total_ratings,
        (
            SELECT json_agg(json_build_object('id', s.id, 'name', s.name))
            FROM public.provider_services ps
            JOIN public.services s ON s.id = ps.service_id
            WHERE ps.provider_id = up.id
        ) AS services,
        false AS is_favorite -- Will be set by application based on user
    FROM public.user_profiles up
    JOIN public.providers p ON p.id = up.id
    WHERE up.role = 'provider'
    AND p.is_verified = true
    AND (
        p_search_term IS NULL 
        OR up.name ILIKE '%' || p_search_term || '%'
        OR p.business_name ILIKE '%' || p_search_term || '%'
    )
    AND (
        p_service_id IS NULL
        OR EXISTS (
            SELECT 1 FROM public.provider_services ps
            WHERE ps.provider_id = up.id
            AND ps.service_id = p_service_id
        )
    )
    AND (
        p_min_rating IS NULL
        OR p.average_rating >= p_min_rating
    )
    ORDER BY p.average_rating DESC, p.total_ratings DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get top providers
CREATE OR REPLACE FUNCTION get_top_providers(
    p_limit INTEGER DEFAULT 10,
    p_service_id UUID DEFAULT NULL
)
RETURNS TABLE (
    provider_id UUID,
    name TEXT,
    avatar TEXT,
    average_rating DECIMAL,
    total_ratings INTEGER,
    services JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        up.id AS provider_id,
        up.name,
        up.avatar,
        p.average_rating,
        p.total_ratings,
        (
            SELECT json_agg(json_build_object('id', s.id, 'name', s.name))
            FROM public.provider_services ps
            JOIN public.services s ON s.id = ps.service_id
            WHERE ps.provider_id = up.id
        ) AS services
    FROM public.user_profiles up
    JOIN public.providers p ON p.id = up.id
    WHERE up.role = 'provider'
    AND p.is_verified = true
    AND (
        p_service_id IS NULL
        OR EXISTS (
            SELECT 1 FROM public.provider_services ps
            WHERE ps.provider_id = up.id
            AND ps.service_id = p_service_id
        )
    )
    ORDER BY p.average_rating DESC, p.total_ratings DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update provider rating after new rating
CREATE OR REPLACE FUNCTION update_provider_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.providers
    SET 
        average_rating = (
            SELECT AVG(rating)
            FROM public.ratings
            WHERE provider_id = NEW.provider_id
        ),
        total_ratings = (
            SELECT COUNT(*)
            FROM public.ratings
            WHERE provider_id = NEW.provider_id
        )
    WHERE id = NEW.provider_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update provider rating
CREATE TRIGGER trigger_update_provider_rating
    AFTER INSERT OR UPDATE ON public.ratings
    FOR EACH ROW
    EXECUTE FUNCTION update_provider_rating();

-- Function to handle default address constraint
CREATE OR REPLACE FUNCTION ensure_single_default_address()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_default = true THEN
        UPDATE public.addresses
        SET is_default = false
        WHERE user_id = NEW.user_id
        AND id != NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to ensure only one default address
CREATE TRIGGER trigger_ensure_single_default_address
    BEFORE INSERT OR UPDATE ON public.addresses
    FOR EACH ROW
    WHEN (NEW.is_default = true)
    EXECUTE FUNCTION ensure_single_default_address();

-- Function to generate unique booking ID
CREATE OR REPLACE FUNCTION generate_booking_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.booking_id IS NULL OR NEW.booking_id = '' THEN
        NEW.booking_id := 'BK-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
                         LPAD(NEXTVAL('booking_id_seq')::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create sequence for booking IDs
CREATE SEQUENCE IF NOT EXISTS booking_id_seq;

-- Trigger to generate booking ID
CREATE TRIGGER trigger_generate_booking_id
    BEFORE INSERT ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION generate_booking_id();

-- Additional Indexes for Performance

-- OTP Verifications indexes
CREATE INDEX IF NOT EXISTS idx_otp_email ON public.otp_verifications(email);
CREATE INDEX IF NOT EXISTS idx_otp_expires ON public.otp_verifications(expires_at);
CREATE INDEX IF NOT EXISTS idx_otp_verified ON public.otp_verifications(verified) WHERE verified = false;

-- Booking indexes for common queries
CREATE INDEX IF NOT EXISTS idx_bookings_consumer_status ON public.bookings(consumer_id, status);
CREATE INDEX IF NOT EXISTS idx_bookings_provider_status ON public.bookings(provider_id, status);
CREATE INDEX IF NOT EXISTS idx_bookings_date_status ON public.bookings(booking_date, status);

-- Provider service lookup
CREATE INDEX IF NOT EXISTS idx_provider_services_lookup ON public.provider_services(provider_id, service_id);

-- Ratings lookup
CREATE INDEX IF NOT EXISTS idx_ratings_provider_rating ON public.ratings(provider_id, rating);

-- Favorites lookup
CREATE INDEX IF NOT EXISTS idx_favorites_lookup ON public.favorites(consumer_id, provider_id);

-- Wallet transactions
CREATE INDEX IF NOT EXISTS idx_wallet_transactions_date ON public.wallet_transactions(provider_id, created_at DESC);

