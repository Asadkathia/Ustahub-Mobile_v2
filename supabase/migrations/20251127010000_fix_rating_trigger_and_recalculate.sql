-- Fix rating trigger to handle DELETE and ensure proper decimal casting
CREATE OR REPLACE FUNCTION update_provider_rating()
RETURNS TRIGGER AS $$
DECLARE
    v_provider_id UUID;
BEGIN
    -- Get provider_id from NEW (INSERT/UPDATE) or OLD (DELETE)
    v_provider_id := COALESCE(NEW.provider_id, OLD.provider_id);
    
    IF v_provider_id IS NULL THEN
        RETURN COALESCE(NEW, OLD);
    END IF;
    
    UPDATE public.providers
    SET 
        average_rating = COALESCE((
            SELECT AVG(rating)
            FROM public.ratings
            WHERE provider_id = v_provider_id
        ), 0.0)::DECIMAL(3, 2),
        total_ratings = (
            SELECT COUNT(*)
            FROM public.ratings
            WHERE provider_id = v_provider_id
        )
    WHERE id = v_provider_id;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Drop and recreate trigger to ensure it's active
DROP TRIGGER IF EXISTS trigger_update_provider_rating ON public.ratings;
CREATE TRIGGER trigger_update_provider_rating
    AFTER INSERT OR UPDATE OR DELETE ON public.ratings
    FOR EACH ROW
    EXECUTE FUNCTION update_provider_rating();

-- Recalculate all provider stats (this will fix existing data)
SELECT recalculate_provider_stats();


