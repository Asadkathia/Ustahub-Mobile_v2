-- Add search-related columns if needed
ALTER TABLE public.providers 
ADD COLUMN IF NOT EXISTS response_time_minutes INTEGER DEFAULT 60,
ADD COLUMN IF NOT EXISTS completion_rate DECIMAL(5, 2) DEFAULT 0.00;

-- Create search index for full-text search
CREATE INDEX IF NOT EXISTS idx_providers_search ON public.user_profiles 
USING gin(to_tsvector('english', coalesce(name, '') || ' ' || coalesce(bio, '')));

-- Function for advanced provider search
CREATE OR REPLACE FUNCTION advanced_search_providers(
    p_search_term TEXT DEFAULT NULL,
    p_service_id UUID DEFAULT NULL,
    p_min_rating DECIMAL DEFAULT NULL,
    p_max_price DECIMAL DEFAULT NULL,
    p_min_price DECIMAL DEFAULT NULL,
    p_max_distance_km DECIMAL DEFAULT NULL,
    p_latitude DECIMAL DEFAULT NULL,
    p_longitude DECIMAL DEFAULT NULL,
    p_verified_only BOOLEAN DEFAULT false,
    p_available_today BOOLEAN DEFAULT false,
    p_sort_by TEXT DEFAULT 'rating' -- 'rating', 'price', 'distance', 'reviews'
)
RETURNS TABLE (
    provider_id UUID,
    name TEXT,
    avatar TEXT,
    average_rating DECIMAL,
    total_ratings INTEGER,
    services JSONB,
    distance_km DECIMAL,
    min_price DECIMAL,
    max_price DECIMAL,
    is_verified BOOLEAN,
    response_time_minutes INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        up.id as provider_id,
        up.name,
        up.avatar,
        COALESCE(pr.average_rating, 0.0)::DECIMAL as average_rating,
        COALESCE(pr.total_ratings, 0)::INTEGER as total_ratings,
        COALESCE(
            jsonb_agg(
                DISTINCT jsonb_build_object(
                    'id', s.id,
                    'name', s.name,
                    'icon', s.icon
                )
            ) FILTER (WHERE s.id IS NOT NULL),
            '[]'::jsonb
        ) as services,
        CASE 
            WHEN p_latitude IS NOT NULL AND p_longitude IS NOT NULL 
            THEN (
                6371 * acos(
                    cos(radians(p_latitude)) * 
                    cos(radians(COALESCE(a.latitude, 0))) * 
                    cos(radians(COALESCE(a.longitude, 0)) - radians(p_longitude)) + 
                    sin(radians(p_latitude)) * 
                    sin(radians(COALESCE(a.latitude, 0)))
                )
            )
            ELSE NULL
        END as distance_km,
        MIN(pl.plan_price) as min_price,
        MAX(pl.plan_price) as max_price,
        COALESCE(pr.is_verified, false) as is_verified,
        COALESCE(pr.response_time_minutes, 60)::INTEGER as response_time_minutes
    FROM public.user_profiles up
    LEFT JOIN public.providers pr ON pr.id = up.id
    LEFT JOIN public.provider_services ps ON ps.provider_id = up.id
    LEFT JOIN public.services s ON s.id = ps.service_id
    LEFT JOIN public.plans pl ON pl.provider_service_id = ps.id
    LEFT JOIN public.addresses a ON a.user_id = up.id AND a.is_default = true
    WHERE 
        (p_search_term IS NULL OR 
         to_tsvector('english', coalesce(up.name, '') || ' ' || coalesce(up.bio, '')) 
         @@ plainto_tsquery('english', p_search_term))
        AND (p_service_id IS NULL OR ps.service_id = p_service_id)
        AND (p_min_rating IS NULL OR COALESCE(pr.average_rating, 0.0) >= p_min_rating)
        AND (p_min_price IS NULL OR pl.plan_price >= p_min_price)
        AND (p_max_price IS NULL OR pl.plan_price <= p_max_price)
        AND (p_verified_only = false OR pr.is_verified = true)
        AND (p_max_distance_km IS NULL OR 
             (p_latitude IS NOT NULL AND p_longitude IS NOT NULL AND
              (6371 * acos(
                  cos(radians(p_latitude)) * 
                  cos(radians(COALESCE(a.latitude, 0))) * 
                  cos(radians(COALESCE(a.longitude, 0)) - radians(p_longitude)) + 
                  sin(radians(p_latitude)) * 
                  sin(radians(COALESCE(a.latitude, 0)))
              )) <= p_max_distance_km))
    GROUP BY up.id, up.name, up.avatar, pr.average_rating, pr.total_ratings, 
             pr.is_verified, pr.response_time_minutes, a.latitude, a.longitude
    ORDER BY 
        CASE p_sort_by
            WHEN 'price' THEN MIN(pl.plan_price)
            WHEN 'distance' THEN 
                CASE 
                    WHEN p_latitude IS NOT NULL AND p_longitude IS NOT NULL 
                    THEN (6371 * acos(
                        cos(radians(p_latitude)) * 
                        cos(radians(COALESCE(a.latitude, 0))) * 
                        cos(radians(COALESCE(a.longitude, 0)) - radians(p_longitude)) + 
                        sin(radians(p_latitude)) * 
                        sin(radians(COALESCE(a.latitude, 0)))
                    ))
                    ELSE 999999
                END
            WHEN 'reviews' THEN COALESCE(pr.total_ratings, 0)
            ELSE COALESCE(pr.average_rating, 0.0)
        END ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

