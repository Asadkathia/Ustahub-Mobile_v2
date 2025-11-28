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


