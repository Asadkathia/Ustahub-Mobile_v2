-- Fix provider RLS and ensure provider record creation
-- This migration ensures providers can create their own records and fixes upload issues

-- Make the trigger function SECURITY DEFINER so it can bypass RLS
CREATE OR REPLACE FUNCTION public.ensure_provider_record()
RETURNS trigger AS $$
BEGIN
  IF NEW.role = 'provider' THEN
    INSERT INTO public.providers (id, business_name, updated_at)
    VALUES (NEW.id, COALESCE(NEW.name, ''), NOW())
    ON CONFLICT (id)
    DO UPDATE SET
      business_name = COALESCE(EXCLUDED.business_name, providers.business_name),
      updated_at = NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ensure trigger exists and fires correctly
DROP TRIGGER IF EXISTS trg_user_profiles_provider_sync ON public.user_profiles;
CREATE TRIGGER trg_user_profiles_provider_sync
AFTER INSERT OR UPDATE OF role, name ON public.user_profiles
FOR EACH ROW
EXECUTE FUNCTION public.ensure_provider_record();

-- Add a policy to allow providers to read their own provider record (even if not verified)
DROP POLICY IF EXISTS "Providers can read own record" ON public.providers;
CREATE POLICY "Providers can read own record"
    ON public.providers FOR SELECT
    USING (auth.uid() = id);

-- Storage bucket policies for file uploads
-- Note: These need to be created in Supabase Dashboard, but we document them here

-- For avatars bucket (public):
-- Policy: "Users can upload their own avatars"
-- INSERT: auth.uid()::text = (storage.foldername(name))[1]
-- UPDATE: auth.uid()::text = (storage.foldername(name))[1]
-- DELETE: auth.uid()::text = (storage.foldername(name))[1]

-- For documents bucket (private):
-- Policy: "Users can upload their own documents"
-- INSERT: auth.uid()::text = (storage.foldername(name))[1]
-- SELECT: auth.uid()::text = (storage.foldername(name))[1]
-- UPDATE: auth.uid()::text = (storage.foldername(name))[1]
-- DELETE: auth.uid()::text = (storage.foldername(name))[1]

