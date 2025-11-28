-- Fix provider profile read policy to allow reading all provider profiles (not just verified)
-- This ensures provider details can be displayed even if provider is not yet verified

-- Drop the old policy that only allows verified providers
DROP POLICY IF EXISTS "Public can read provider profiles" ON public.user_profiles;

-- Create new policy that allows reading all provider profiles
CREATE POLICY "Public can read provider profiles"
    ON public.user_profiles FOR SELECT
    USING (role = 'provider');

-- Also allow reading provider records even if not verified
DROP POLICY IF EXISTS "Public can read verified providers" ON public.providers;

-- Create new policy that allows reading all provider records
CREATE POLICY "Public can read providers"
    ON public.providers FOR SELECT
    USING (true);




