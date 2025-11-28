-- Add missing columns to user_profiles table and fix provider queries
-- This migration adds bio, email and other missing fields

-- Add missing columns to user_profiles
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- Update email from auth.users for existing records
UPDATE public.user_profiles up
SET email = au.email
FROM auth.users au
WHERE up.id = au.id AND up.email IS NULL;

-- Add missing columns to providers table if needed
ALTER TABLE public.providers ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE public.providers ADD COLUMN IF NOT EXISTS email TEXT;

-- Create or replace function to get all top providers (not filtered by verification)
CREATE OR REPLACE FUNCTION get_all_top_providers(
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    provider_id UUID,
    name TEXT,
    avatar TEXT,
    email TEXT,
    bio TEXT,
    average_rating DECIMAL,
    total_ratings INTEGER,
    services JSONB,
    is_verified BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        up.id AS provider_id,
        up.name,
        up.avatar,
        up.email,
        COALESCE(up.bio, p.bio, '') AS bio,
        COALESCE(p.average_rating, 0) AS average_rating,
        COALESCE(p.total_ratings, 0) AS total_ratings,
        COALESCE(
            (
                SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name))
                FROM public.provider_services ps
                JOIN public.services s ON s.id = ps.service_id
                WHERE ps.provider_id = up.id
            ),
            '[]'::jsonb
        ) AS services,
        COALESCE(p.is_verified, false) AS is_verified
    FROM public.user_profiles up
    LEFT JOIN public.providers p ON p.id = up.id
    WHERE up.role = 'provider'
    GROUP BY up.id, up.name, up.avatar, up.email, up.bio, p.bio, p.average_rating, p.total_ratings, p.is_verified
    ORDER BY p.average_rating DESC NULLS LAST, p.total_ratings DESC NULLS LAST, up.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update the get_top_providers function to return all providers if no service filter
DROP FUNCTION IF EXISTS get_top_providers(INTEGER, UUID);
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
        COALESCE(p.average_rating, 0) AS average_rating,
        COALESCE(p.total_ratings, 0) AS total_ratings,
        COALESCE(
            (
                SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name))
                FROM public.provider_services ps
                JOIN public.services s ON s.id = ps.service_id
                WHERE ps.provider_id = up.id
            ),
            '[]'::jsonb
        ) AS services
    FROM public.user_profiles up
    LEFT JOIN public.providers p ON p.id = up.id
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
    ORDER BY p.average_rating DESC NULLS LAST, p.total_ratings DESC NULLS LAST, up.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update search_providers to return bio and email
DROP FUNCTION IF EXISTS search_providers(TEXT, UUID, DECIMAL, TEXT);
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
    email TEXT,
    bio TEXT,
    average_rating DECIMAL,
    total_ratings INTEGER,
    services JSONB,
    is_favorite BOOLEAN,
    is_verified BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        up.id AS provider_id,
        up.name,
        up.avatar,
        up.email,
        COALESCE(up.bio, p.bio, '') AS bio,
        COALESCE(p.average_rating, 0) AS average_rating,
        COALESCE(p.total_ratings, 0) AS total_ratings,
        COALESCE(
            (
                SELECT jsonb_agg(jsonb_build_object('id', s.id, 'name', s.name))
                FROM public.provider_services ps
                JOIN public.services s ON s.id = ps.service_id
                WHERE ps.provider_id = up.id
            ),
            '[]'::jsonb
        ) AS services,
        false AS is_favorite,
        COALESCE(p.is_verified, false) AS is_verified
    FROM public.user_profiles up
    LEFT JOIN public.providers p ON p.id = up.id
    WHERE up.role = 'provider'
    AND (
        p_search_term IS NULL 
        OR up.name ILIKE '%' || p_search_term || '%'
        OR COALESCE(p.business_name, '') ILIKE '%' || p_search_term || '%'
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
        OR COALESCE(p.average_rating, 0) >= p_min_rating
    )
    GROUP BY up.id, up.name, up.avatar, up.email, up.bio, p.bio, p.average_rating, p.total_ratings, p.is_verified
    ORDER BY p.average_rating DESC NULLS LAST, p.total_ratings DESC NULLS LAST, up.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

