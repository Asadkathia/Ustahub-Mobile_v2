-- Function to get price range for a service
CREATE OR REPLACE FUNCTION get_service_price_range(p_service_id UUID)
RETURNS TABLE (min_price DECIMAL, max_price DECIMAL, avg_price DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        MIN(p.plan_price) as min_price,
        MAX(p.plan_price) as max_price,
        AVG(p.plan_price) as avg_price
    FROM public.plans p
    JOIN public.provider_services ps ON ps.id = p.provider_service_id
    WHERE ps.service_id = p_service_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to compare provider prices for a service
CREATE OR REPLACE FUNCTION compare_provider_prices(
    p_service_id UUID,
    p_provider_ids UUID[] DEFAULT NULL
)
RETURNS TABLE (
    provider_id UUID,
    provider_name TEXT,
    provider_avatar TEXT,
    min_price DECIMAL,
    max_price DECIMAL,
    avg_price DECIMAL,
    plan_count INTEGER,
    average_rating DECIMAL,
    total_ratings INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        up.id as provider_id,
        up.name as provider_name,
        up.avatar as provider_avatar,
        MIN(p.plan_price) as min_price,
        MAX(p.plan_price) as max_price,
        AVG(p.plan_price) as avg_price,
        COUNT(DISTINCT p.id)::INTEGER as plan_count,
        COALESCE(pr.average_rating, 0.0)::DECIMAL as average_rating,
        COALESCE(pr.total_ratings, 0)::INTEGER as total_ratings
    FROM public.user_profiles up
    JOIN public.provider_services ps ON ps.provider_id = up.id
    JOIN public.plans p ON p.provider_service_id = ps.id
    LEFT JOIN public.providers pr ON pr.id = up.id
    WHERE ps.service_id = p_service_id
    AND (p_provider_ids IS NULL OR up.id = ANY(p_provider_ids))
    GROUP BY up.id, up.name, up.avatar, pr.average_rating, pr.total_ratings
    ORDER BY min_price ASC, average_rating DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

