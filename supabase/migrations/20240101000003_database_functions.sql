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


