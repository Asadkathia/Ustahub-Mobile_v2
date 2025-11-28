-- Align provider_services RLS policy with Supabase auth.uid() UUIDs
DROP POLICY IF EXISTS "Providers can manage own services" ON public.provider_services;

CREATE POLICY "Providers can manage own services"
    ON public.provider_services FOR ALL
    USING (
        EXISTS (
            SELECT 1
            FROM public.user_profiles up
            WHERE up.id = provider_services.provider_id
              AND up.role = 'provider'
              AND up.id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.user_profiles up
            WHERE up.id = provider_services.provider_id
              AND up.role = 'provider'
              AND up.id = auth.uid()
        )
    );

