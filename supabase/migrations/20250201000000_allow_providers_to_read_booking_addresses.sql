-- Allow providers to view consumer addresses for bookings assigned to them
DROP POLICY IF EXISTS "Providers can view booking addresses" ON public.addresses;
CREATE POLICY "Providers can view booking addresses"
  ON public.addresses
  FOR SELECT
  USING (
    auth.uid() = user_id OR EXISTS (
      SELECT 1
      FROM public.bookings b
      WHERE b.address_id = addresses.id
        AND b.provider_id = auth.uid()
    )
  );

