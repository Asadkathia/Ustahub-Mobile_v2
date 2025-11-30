-- Add columns to ratings table
ALTER TABLE public.ratings 
ADD COLUMN IF NOT EXISTS image_urls TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS helpful_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS verified_booking BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS category_ratings JSONB DEFAULT '{}'; -- {quality: 5, punctuality: 4, communication: 5, price: 4}

-- Review Helpful Votes Table
CREATE TABLE IF NOT EXISTS public.review_helpful_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rating_id UUID NOT NULL REFERENCES public.ratings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    is_helpful BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(rating_id, user_id)
);

-- Provider Responses to Reviews
CREATE TABLE IF NOT EXISTS public.review_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rating_id UUID NOT NULL REFERENCES public.ratings(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    response_text TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(rating_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_ratings_provider_verified ON public.ratings(provider_id, verified_booking);
CREATE INDEX IF NOT EXISTS idx_review_votes_rating ON public.review_helpful_votes(rating_id);
CREATE INDEX IF NOT EXISTS idx_review_responses_rating ON public.review_responses(rating_id);

-- Trigger for updated_at on review_responses
CREATE TRIGGER update_review_responses_updated_at BEFORE UPDATE ON public.review_responses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update helpful count
CREATE OR REPLACE FUNCTION update_review_helpful_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.ratings
    SET helpful_count = (
        SELECT COUNT(*) FROM public.review_helpful_votes
        WHERE rating_id = COALESCE(NEW.rating_id, OLD.rating_id) AND is_helpful = true
    )
    WHERE id = COALESCE(NEW.rating_id, OLD.rating_id);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists and recreate
DROP TRIGGER IF EXISTS update_helpful_count_trigger ON public.review_helpful_votes;
CREATE TRIGGER update_helpful_count_trigger
AFTER INSERT OR UPDATE OR DELETE ON public.review_helpful_votes
FOR EACH ROW EXECUTE FUNCTION update_review_helpful_count();

-- RLS Policies
ALTER TABLE public.review_helpful_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_responses ENABLE ROW LEVEL SECURITY;

-- Review Helpful Votes Policies
CREATE POLICY "Anyone can view helpful votes"
    ON public.review_helpful_votes FOR SELECT
    USING (true);

CREATE POLICY "Users can vote on reviews"
    ON public.review_helpful_votes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own votes"
    ON public.review_helpful_votes FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own votes"
    ON public.review_helpful_votes FOR DELETE
    USING (auth.uid() = user_id);

-- Review Responses Policies
CREATE POLICY "Anyone can view review responses"
    ON public.review_responses FOR SELECT
    USING (true);

CREATE POLICY "Providers can respond to reviews"
    ON public.review_responses FOR INSERT
    WITH CHECK (auth.uid() = provider_id);

CREATE POLICY "Providers can update own responses"
    ON public.review_responses FOR UPDATE
    USING (auth.uid() = provider_id);

CREATE POLICY "Providers can delete own responses"
    ON public.review_responses FOR DELETE
    USING (auth.uid() = provider_id);

