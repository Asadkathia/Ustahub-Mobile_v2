<!-- f4e3c254-8abe-4c3e-a794-cbcd2edbdba9 be1435f9-5fe0-414b-87a3-7a2973d6794d -->
# Ustahub Feature Enhancement Implementation Plan

## System Architecture Review

### Current Architecture

- **Backend**: Supabase (PostgreSQL) with Edge Functions
- **Frontend**: Flutter with GetX state management
- **Pattern**: Repository → SupabaseApiServices → Supabase Client
- **Storage**: Supabase Storage (avatars, documents, banners, service-images)
- **Database**: Well-structured with RLS policies, indexes, and triggers
- **API Pattern**: Edge Functions for complex operations, direct Supabase queries for simple CRUD

### Key Files & Patterns

- **API Layer**: `lib/network/supabase_api_services.dart` (centralized API service)
- **Repository Pattern**: `lib/app/modules/*/repository/*.dart` (business logic layer)
- **Controllers**: `lib/app/modules/*/controller/*.dart` (GetX state management)
- **Models**: `lib/app/modules/*/model_class/*.dart` (data models)
- **UI V2**: `lib/app/ui_v2/` (new design system)
- **Migrations**: `supabase/migrations/` (database schema changes)

---

## Phase 1: Provider Portfolios & Work Galleries (HIGH PRIORITY)

### 1.1 Database Schema Changes

**Migration File**: `supabase/migrations/20250101000001_add_provider_portfolios.sql`

```sql
-- Provider Portfolio/Work Gallery Table
CREATE TABLE public.provider_portfolios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    service_id UUID REFERENCES public.services(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    project_date DATE,
    image_urls TEXT[] NOT NULL DEFAULT '{}',
    video_url TEXT,
    tags TEXT[],
    is_featured BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_portfolios_provider ON public.provider_portfolios(provider_id);
CREATE INDEX idx_portfolios_service ON public.provider_portfolios(service_id);
CREATE INDEX idx_portfolios_featured ON public.provider_portfolios(is_featured) WHERE is_featured = true;

-- Trigger for updated_at
CREATE TRIGGER update_portfolios_updated_at BEFORE UPDATE ON public.provider_portfolios
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS Policies
ALTER TABLE public.provider_portfolios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Providers can view all portfolios"
    ON public.provider_portfolios FOR SELECT
    USING (true);

CREATE POLICY "Providers can insert own portfolios"
    ON public.provider_portfolios FOR INSERT
    WITH CHECK (auth.uid() = provider_id);

CREATE POLICY "Providers can update own portfolios"
    ON public.provider_portfolios FOR UPDATE
    USING (auth.uid() = provider_id);

CREATE POLICY "Providers can delete own portfolios"
    ON public.provider_portfolios FOR DELETE
    USING (auth.uid() = provider_id);
```

**Storage Bucket**: Add `portfolios` bucket in Supabase Dashboard

- Public bucket for portfolio images
- Max file size: 10MB
- Allowed types: image/jpeg, image/png, image/webp, video/mp4

### 1.2 Backend API Implementation

**File**: `lib/network/supabase_api_services.dart`

Add methods:

- `getProviderPortfolios(String providerId, {String? serviceId})`
- `createPortfolio(Map<String, dynamic> data)`
- `updatePortfolio(String portfolioId, Map<String, dynamic> data)`
- `deletePortfolio(String portfolioId)`
- `uploadPortfolioMedia(File file, String portfolioId)`

**Pattern**: Follow existing `getProviderById` pattern using Supabase queries with joins.

### 1.3 Repository Layer

**File**: `lib/app/modules/provider_portfolio/repository/portfolio_repository.dart`

Create repository following pattern from `lib/app/modules/rating/repository/rating_repository.dart`:

- Methods call `SupabaseApiServices`
- Error handling and response transformation
- Returns standardized response format

### 1.4 Model Classes

**File**: `lib/app/modules/provider_portfolio/model/portfolio_model.dart`

```dart
class PortfolioModel {
  final String? id;
  final String? providerId;
  final String? serviceId;
  final String? title;
  final String? description;
  final DateTime? projectDate;
  final List<String> imageUrls;
  final String? videoUrl;
  final List<String> tags;
  final bool isFeatured;
  final int displayOrder;
  // ... fromJson, toJson methods
}
```

### 1.5 Controller

**File**: `lib/app/modules/provider_portfolio/controller/portfolio_controller.dart`

- Use GetX observables (`RxList<PortfolioModel> portfolios`)
- Methods: `getPortfolios()`, `createPortfolio()`, `updatePortfolio()`, `deletePortfolio()`
- Follow pattern from `RatingController`

### 1.6 UI Components

**Files**:

- `lib/app/ui_v2/components/cards/portfolio_card_v2.dart` - Portfolio card widget
- `lib/app/ui_v2/screens/provider/portfolio/portfolio_gallery_screen_v2.dart` - Full gallery view
- `lib/app/ui_v2/screens/provider/portfolio/add_portfolio_screen_v2.dart` - Add/edit portfolio

**Integration Points**:

- Update `lib/app/ui_v2/screens/provider/provider_details_screen_v2.dart` to add Portfolio tab
- Add portfolio section in provider details (similar to ratings section)

### 1.7 File Upload Integration

**File**: `lib/app/modules/upload_file/upload_file.dart`

Extend existing `UploadFile` class:

- Add `'portfolio'` case to bucket selection
- Support multiple image uploads
- Support video upload (if needed)

---

## Phase 2: Price Comparison & Transparency (HIGH PRIORITY)

### 2.1 Database Schema Changes

**Migration File**: `supabase/migrations/20250101000002_add_price_comparison.sql`

```sql
-- Quote Requests Table
CREATE TABLE public.quote_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consumer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    address_id UUID NOT NULL REFERENCES public.addresses(id) ON DELETE RESTRICT,
    description TEXT,
    preferred_date DATE,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'responded', 'expired', 'cancelled')),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Quote Responses Table
CREATE TABLE public.quote_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quote_request_id UUID NOT NULL REFERENCES public.quote_requests(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT,
    estimated_duration TEXT,
    is_accepted BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(quote_request_id, provider_id)
);

-- Price History Table (for tracking price trends)
CREATE TABLE public.price_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES public.plans(id) ON DELETE SET NULL,
    price DECIMAL(10, 2) NOT NULL,
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_quote_requests_consumer ON public.quote_requests(consumer_id);
CREATE INDEX idx_quote_requests_service ON public.quote_requests(service_id);
CREATE INDEX idx_quote_responses_quote ON public.quote_responses(quote_request_id);
CREATE INDEX idx_quote_responses_provider ON public.quote_responses(provider_id);
CREATE INDEX idx_price_history_provider_service ON public.price_history(provider_id, service_id);

-- RLS Policies (similar pattern to existing tables)
```

### 2.2 Database Functions

**File**: `supabase/migrations/20250101000003_price_comparison_functions.sql`

```sql
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
```

### 2.3 Backend API Implementation

**File**: `lib/network/supabase_api_services.dart`

Add methods:

- `createQuoteRequest(Map<String, dynamic> data)`
- `getQuoteRequests({String? status})`
- `respondToQuote(String quoteRequestId, Map<String, dynamic> data)`
- `getQuoteResponses(String quoteRequestId)`
- `getServicePriceRange(String serviceId)`
- `compareProviderPrices(List<String> providerIds, String serviceId)`

### 2.4 Repository Layer

**File**: `lib/app/modules/quote/repository/quote_repository.dart`

### 2.5 Controllers

**Files**:

- `lib/app/modules/quote/controller/quote_controller.dart` - Consumer quote management
- `lib/app/modules/quote/controller/quote_response_controller.dart` - Provider response management

### 2.6 UI Components

**Files**:

- `lib/app/ui_v2/screens/quote/create_quote_request_screen_v2.dart`
- `lib/app/ui_v2/screens/quote/quote_comparison_screen_v2.dart` - Side-by-side comparison
- `lib/app/ui_v2/components/cards/quote_response_card_v2.dart`
- `lib/app/ui_v2/components/widgets/price_range_indicator_v2.dart`

**Integration Points**:

- Add "Request Quote" button in provider details screen
- Add price comparison widget in service selection
- Show price range in service cards

---

## Phase 3: Advanced Search & Filtering (HIGH PRIORITY)

### 3.1 Database Schema Enhancements

**Migration File**: `supabase/migrations/20250101000004_enhance_search.sql`

```sql
-- Add search-related columns if needed
ALTER TABLE public.providers 
ADD COLUMN IF NOT EXISTS response_time_minutes INTEGER DEFAULT 60,
ADD COLUMN IF NOT EXISTS completion_rate DECIMAL(5, 2) DEFAULT 0.00;

-- Create search index for full-text search
CREATE INDEX IF NOT EXISTS idx_providers_search ON public.user_profiles 
USING gin(to_tsvector('english', coalesce(name, '') || ' ' || coalesce(bio, '')));

-- Function for advanced provider search
CREATE OR REPLACE FUNCTION advanced_search_providers(
    p_search_term TEXT DEFAULT NULL,
    p_service_id UUID DEFAULT NULL,
    p_min_rating DECIMAL DEFAULT NULL,
    p_max_price DECIMAL DEFAULT NULL,
    p_min_price DECIMAL DEFAULT NULL,
    p_max_distance_km DECIMAL DEFAULT NULL,
    p_latitude DECIMAL DEFAULT NULL,
    p_longitude DECIMAL DEFAULT NULL,
    p_verified_only BOOLEAN DEFAULT false,
    p_available_today BOOLEAN DEFAULT false,
    p_sort_by TEXT DEFAULT 'rating' -- 'rating', 'price', 'distance', 'reviews'
)
RETURNS TABLE (
    provider_id UUID,
    name TEXT,
    avatar TEXT,
    average_rating DECIMAL,
    total_ratings INTEGER,
    services JSONB,
    distance_km DECIMAL,
    min_price DECIMAL,
    max_price DECIMAL,
    is_verified BOOLEAN,
    response_time_minutes INTEGER
) AS $$
BEGIN
    -- Implementation with distance calculation, price filtering, etc.
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 3.2 Backend API Implementation

**File**: `lib/network/supabase_api_services.dart`

Enhance `getProviders()` method:

- Add parameters: `minPrice`, `maxPrice`, `minRating`, `maxDistance`, `sortBy`, `verifiedOnly`, `availableToday`
- Call new `advanced_search_providers` RPC function
- Return enriched data with distance, price ranges

### 3.3 Repository Layer

**File**: `lib/app/modules/search/repository/advanced_search_repository.dart`

Extend existing search repository with new filtering methods.

### 3.4 Controller Updates

**File**: `lib/app/modules/search/controller/search_controller.dart`

Add reactive filter state:

- `RxDouble minPrice = 0.0.obs`
- `RxDouble maxPrice = 10000.0.obs`
- `RxDouble minRating = 0.0.obs`
- `RxString sortBy = 'rating'.obs`
- `RxBool verifiedOnly = false.obs`
- `RxBool availableToday = false.obs`

### 3.5 UI Components

**Files**:

- `lib/app/ui_v2/screens/search/advanced_search_screen_v2.dart` - Enhanced search with filters
- `lib/app/ui_v2/components/filters/price_range_filter_v2.dart` - Price slider
- `lib/app/ui_v2/components/filters/rating_filter_v2.dart` - Rating filter
- `lib/app/ui_v2/components/filters/sort_options_v2.dart` - Sort dropdown
- `lib/app/ui_v2/components/filters/distance_filter_v2.dart` - Distance selector

**Integration Points**:

- Update `lib/app/ui_v2/screens/search/search_screen_v2.dart` with filter panel
- Add filter chips for active filters
- Add "Clear Filters" functionality

---

## Phase 4: Enhanced Review System (HIGH PRIORITY)

### 4.1 Database Schema Changes

**Migration File**: `supabase/migrations/20250101000005_enhance_reviews.sql`

```sql
-- Add columns to ratings table
ALTER TABLE public.ratings 
ADD COLUMN IF NOT EXISTS image_urls TEXT[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS helpful_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS verified_booking BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS category_ratings JSONB DEFAULT '{}'; -- {quality: 5, punctuality: 4, communication: 5, price: 4}

-- Review Helpful Votes Table
CREATE TABLE public.review_helpful_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rating_id UUID NOT NULL REFERENCES public.ratings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    is_helpful BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(rating_id, user_id)
);

-- Provider Responses to Reviews
CREATE TABLE public.review_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rating_id UUID NOT NULL REFERENCES public.ratings(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    response_text TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(rating_id)
);

-- Indexes
CREATE INDEX idx_ratings_provider_verified ON public.ratings(provider_id, verified_booking);
CREATE INDEX idx_review_votes_rating ON public.review_helpful_votes(rating_id);

-- Function to update helpful count
CREATE OR REPLACE FUNCTION update_review_helpful_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.ratings
    SET helpful_count = (
        SELECT COUNT(*) FROM public.review_helpful_votes
        WHERE rating_id = NEW.rating_id AND is_helpful = true
    )
    WHERE id = NEW.rating_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_helpful_count_trigger
AFTER INSERT OR UPDATE OR DELETE ON public.review_helpful_votes
FOR EACH ROW EXECUTE FUNCTION update_review_helpful_count();
```

### 4.2 Backend API Implementation

**File**: `lib/network/supabase_api_services.dart`

Enhance `rateProvider()` method:

- Accept `imageUrls`, `categoryRatings` parameters
- Mark as `verified_booking` if booking exists

Add new methods:

- `voteReviewHelpful(String ratingId, bool isHelpful)`
- `respondToReview(String ratingId, String responseText)`
- `getReviewResponses(String providerId)`
- `getReviewsWithFilters(String providerId, {String? sortBy, bool? withPhotos, bool? verifiedOnly})`

### 4.3 Repository Layer

**File**: `lib/app/modules/rating/repository/rating_repository.dart`

Update existing repository:

- Enhance `rateProvider()` to accept images and category ratings
- Add `voteHelpful()`, `respondToReview()` methods

### 4.4 Controller Updates

**File**: `lib/app/modules/rating/controller/rating_controller.dart`

Add:

- `RxList<File> reviewImages = <File>[].obs`
- `RxMap<String, double> categoryRatings = <String, double>{}.obs`
- Image upload handling
- Category rating management

### 4.5 UI Components

**Files**:

- `lib/app/ui_v2/components/reviews/review_with_images_v2.dart` - Review card with photos
- `lib/app/ui_v2/components/reviews/review_response_v2.dart` - Provider response widget
- `lib/app/ui_v2/components/reviews/review_filters_v2.dart` - Filter chips
- `lib/app/ui_v2/components/reviews/category_rating_widget_v2.dart` - Category ratings
- `lib/app/ui_v2/screens/rating/enhanced_rating_screen_v2.dart` - Enhanced rating form

**Integration Points**:

- Update `lib/app/modules/provider_details/view/provider_details_screen.dart` ratings section
- Add image gallery in reviews
- Add "Helpful" button on reviews
- Show provider responses
- Add review sorting/filtering UI

---

## Implementation Order & Dependencies

### Week 1-2: Provider Portfolios

1. Database migration
2. API methods
3. Repository & Controller
4. UI components
5. Integration with provider details

### Week 3-4: Enhanced Reviews

1. Database migration
2. API enhancements
3. Repository updates
4. UI components
5. Integration

### Week 5-6: Advanced Search

1. Database functions
2. API enhancements
3. Filter UI components
4. Search screen updates

### Week 7-8: Price Comparison

1. Database schema
2. Quote system API
3. Comparison UI
4. Integration points

---

## Technical Considerations

### File Upload Pattern

- Use existing `UploadFile` class
- Add portfolio bucket support
- Handle multiple image uploads
- Progress tracking for batch uploads

### State Management

- Follow GetX patterns from existing controllers
- Use `.obs` for reactive state
- Proper cleanup in `onClose()`

### Error Handling

- Use existing `CustomToast` for user feedback
- Follow error handling patterns from `SupabaseApiServices._handleError()`
- Add proper logging with `AppLogger`

### Performance

- Use `RepaintBoundary` for image-heavy widgets
- Implement pagination for portfolios/reviews
- Cache frequently accessed data
- Use `CachedNetworkImage` for all images

### Testing Strategy

- Test database migrations locally first
- Test API methods with sample data
- Test UI components in isolation
- Integration testing with existing features

---

## Migration & Deployment

1. **Database Migrations**: Run migrations in order
2. **Storage Buckets**: Create new buckets in Supabase Dashboard
3. **RLS Policies**: Verify all policies are correctly set
4. **Edge Functions**: Deploy if needed for complex operations
5. **Frontend**: Deploy in phases, test each feature before next

---

## Files to Create/Modify Summary

### New Files (Estimated 40+ files)

- Database migrations: 5 files
- Models: 5 files
- Repositories: 4 files
- Controllers: 6 files
- UI Components: 15+ files
- Screens: 8+ files

### Modified Files

- `lib/network/supabase_api_services.dart` - Add new API methods
- `lib/app/modules/upload_file/upload_file.dart` - Add portfolio bucket
- `lib/app/ui_v2/screens/provider/provider_details_screen_v2.dart` - Add portfolio tab
- `lib/app/modules/rating/controller/rating_controller.dart` - Enhance with images
- `lib/app/ui_v2/screens/search/search_screen_v2.dart` - Add filters
- `lib/app/export/exports.dart` - Export new modules

---

## Risk Mitigation

1. **Database Changes**: Test migrations on staging first
2. **Breaking Changes**: Maintain backward compatibility where possible
3. **Performance**: Monitor query performance, add indexes as needed
4. **Storage Costs**: Implement image optimization/compression
5. **User Experience**: Gradual rollout with feature flags

---

## Success Metrics

- Provider portfolio upload rate
- Quote request completion rate
- Search filter usage
- Review photo attachment rate
- User engagement metrics