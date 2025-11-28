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


