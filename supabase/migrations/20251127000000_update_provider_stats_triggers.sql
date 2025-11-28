-- Function to update provider booking stats when booking status changes
CREATE OR REPLACE FUNCTION update_provider_booking_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update if status changed to/from 'completed'
    IF (OLD.status IS DISTINCT FROM NEW.status) AND 
       (NEW.status = 'completed' OR OLD.status = 'completed') THEN
        
        -- Update completed_bookings count
        UPDATE public.providers
        SET completed_bookings = (
            SELECT COUNT(*)
            FROM public.bookings
            WHERE provider_id = NEW.provider_id
            AND status = 'completed'
        ),
        total_bookings = (
            SELECT COUNT(*)
            FROM public.bookings
            WHERE provider_id = NEW.provider_id
        )
        WHERE id = NEW.provider_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update provider booking stats
DROP TRIGGER IF EXISTS trigger_update_provider_booking_stats ON public.bookings;
CREATE TRIGGER trigger_update_provider_booking_stats
    AFTER INSERT OR UPDATE OF status ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION update_provider_booking_stats();

-- Function to recalculate all provider stats (for backfilling)
CREATE OR REPLACE FUNCTION recalculate_provider_stats()
RETURNS void AS $$
BEGIN
    -- Recalculate completed_bookings and total_bookings for all providers
    UPDATE public.providers p
    SET 
        completed_bookings = (
            SELECT COUNT(*)
            FROM public.bookings b
            WHERE b.provider_id = p.id
            AND b.status = 'completed'
        ),
        total_bookings = (
            SELECT COUNT(*)
            FROM public.bookings b
            WHERE b.provider_id = p.id
        ),
        average_rating = COALESCE((
            SELECT AVG(rating)
            FROM public.ratings r
            WHERE r.provider_id = p.id
        ), 0.0)::DECIMAL(3, 2),
        total_ratings = (
            SELECT COUNT(*)
            FROM public.ratings r
            WHERE r.provider_id = p.id
        );
END;
$$ LANGUAGE plpgsql;

-- Run the recalculation
SELECT recalculate_provider_stats();

