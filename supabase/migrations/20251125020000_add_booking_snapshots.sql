-- Add booking snapshot columns and helper trigger
BEGIN;

ALTER TABLE public.bookings
    ADD COLUMN IF NOT EXISTS booking_number TEXT,
    ADD COLUMN IF NOT EXISTS consumer_name TEXT,
    ADD COLUMN IF NOT EXISTS consumer_avatar TEXT,
    ADD COLUMN IF NOT EXISTS consumer_phone TEXT,
    ADD COLUMN IF NOT EXISTS provider_name TEXT,
    ADD COLUMN IF NOT EXISTS provider_avatar TEXT,
    ADD COLUMN IF NOT EXISTS provider_phone TEXT,
    ADD COLUMN IF NOT EXISTS service_name TEXT,
    ADD COLUMN IF NOT EXISTS service_image TEXT,
    ADD COLUMN IF NOT EXISTS plan_name TEXT,
    ADD COLUMN IF NOT EXISTS plan_price NUMERIC(10, 2),
    ADD COLUMN IF NOT EXISTS address_full TEXT,
    ADD COLUMN IF NOT EXISTS address_city TEXT,
    ADD COLUMN IF NOT EXISTS address_state TEXT,
    ADD COLUMN IF NOT EXISTS address_postal TEXT,
    ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS started_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;

CREATE OR REPLACE FUNCTION public.refresh_booking_snapshots()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    consumer_rec RECORD;
    provider_rec RECORD;
    service_rec RECORD;
    plan_rec RECORD;
    address_rec RECORD;
BEGIN
    -- Consumer snapshot
    SELECT name, avatar, phone
    INTO consumer_rec
    FROM public.user_profiles
    WHERE id = NEW.consumer_id;

    NEW.consumer_name := consumer_rec.name;
    NEW.consumer_avatar := consumer_rec.avatar;
    NEW.consumer_phone := consumer_rec.phone;

    -- Provider snapshot
    SELECT name, avatar, phone
    INTO provider_rec
    FROM public.user_profiles
    WHERE id = NEW.provider_id;

    NEW.provider_name := provider_rec.name;
    NEW.provider_avatar := provider_rec.avatar;
    NEW.provider_phone := provider_rec.phone;

    -- Service snapshot
    SELECT name, image
    INTO service_rec
    FROM public.services
    WHERE id = NEW.service_id;

    NEW.service_name := service_rec.name;
    NEW.service_image := service_rec.image;

    -- Plan snapshot
    IF NEW.plan_id IS NOT NULL THEN
        SELECT name, price
        INTO plan_rec
        FROM public.plans
        WHERE id = NEW.plan_id;

        NEW.plan_name := plan_rec.name;
        NEW.plan_price := plan_rec.price;
    ELSE
        NEW.plan_name := NULL;
        NEW.plan_price := NULL;
    END IF;

    -- Address snapshot
    SELECT
        CONCAT_WS(', ',
            NULLIF(address_line1, ''),
            NULLIF(address_line2, ''),
            NULLIF(city, ''),
            NULLIF(state, ''),
            NULLIF(postal_code, ''),
            NULLIF(country, '')
        ) AS full_address,
        city,
        state,
        postal_code,
        latitude,
        longitude
    INTO address_rec
    FROM public.addresses
    WHERE id = NEW.address_id;

    NEW.address_full := address_rec.full_address;
    NEW.address_city := address_rec.city;
    NEW.address_state := address_rec.state;
    NEW.address_postal := address_rec.postal_code;
    NEW.latitude := address_rec.latitude;
    NEW.longitude := address_rec.longitude;

    NEW.booking_number := COALESCE(NEW.booking_number, NEW.booking_id);

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS booking_snapshots_biu ON public.bookings;

CREATE TRIGGER booking_snapshots_biu
BEFORE INSERT OR UPDATE OF consumer_id, provider_id, service_id, plan_id, address_id, booking_id
ON public.bookings
FOR EACH ROW
EXECUTE FUNCTION public.refresh_booking_snapshots();

-- Backfill existing bookings
UPDATE public.bookings
SET booking_number = COALESCE(booking_number, booking_id);

COMMIT;



