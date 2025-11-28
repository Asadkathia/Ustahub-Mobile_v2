-- Ensure provider RPCs return JSONB to match table signatures
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
    SELECT
        up.id AS provider_id,
        up.name,
        up.avatar,
        p.average_rating,
        p.total_ratings,
        COALESCE((
            SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name))
            FROM public.provider_services ps
            JOIN public.services s ON s.id = ps.service_id
            WHERE ps.provider_id = up.id
        ), '[]'::jsonb) AS services,
        false AS is_favorite
    FROM public.user_profiles up
    JOIN public.providers p ON p.id = up.id
    WHERE up.role = 'provider'
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
    GROUP BY up.id, up.name, up.avatar, p.average_rating, p.total_ratings
    ORDER BY p.average_rating DESC NULLS LAST, p.total_ratings DESC NULLS LAST;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

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
    SELECT
        up.id AS provider_id,
        up.name,
        up.avatar,
        p.average_rating,
        p.total_ratings,
        COALESCE((
            SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name))
            FROM public.provider_services ps
            JOIN public.services s ON s.id = ps.service_id
            WHERE ps.provider_id = up.id
        ), '[]'::jsonb) AS services
    FROM public.user_profiles up
    JOIN public.providers p ON p.id = up.id
    WHERE up.role = 'provider'
    AND (
        p_service_id IS NULL
        OR EXISTS (
            SELECT 1 FROM public.provider_services ps
            WHERE ps.provider_id = up.id
            AND ps.service_id = p_service_id
        )
    )
    GROUP BY up.id, up.name, up.avatar, p.average_rating, p.total_ratings
    ORDER BY p.average_rating DESC NULLS LAST, p.total_ratings DESC NULLS LAST
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


