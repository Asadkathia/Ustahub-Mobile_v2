# Ustahub Feature Testing Guide

This guide explains how to test each of the newly implemented features in the Ustahub app.

## Prerequisites

1. **Database Setup**: All migrations have been applied to Supabase
2. **Storage Buckets**: Ensure the following buckets exist in Supabase Storage:
   - `portfolios` (for portfolio images)
   - `avatars` (for user avatars)
   - `banners` (for banners)
   - `service-images` (for service images)

3. **Test Accounts**: You'll need:
   - At least one **Provider** account (to create portfolios, respond to quotes, manage reviews)
   - At least one **Consumer** account (to request quotes, view portfolios, leave reviews)
   - Test services in the database

---

## Feature 1: Provider Portfolios & Work Galleries

### How to Access

**As a Consumer:**
1. Navigate to **Home** screen
2. Browse providers or search for a provider
3. Tap on any provider card to open **Provider Details Screen**
4. Scroll down to see the **Portfolio** section

**As a Provider:**
1. Log in as a provider
2. Navigate to your **Provider Details** screen (via Account or Profile)
3. The portfolio section should be visible (if you have portfolios)

### Testing Steps

#### Test 1: View Portfolios (Consumer)
1. ✅ Open any provider's details screen
2. ✅ Scroll to the "Portfolio" section
3. ✅ Verify portfolio cards display with:
   - Portfolio image
   - Title
   - Description (if available)
4. ✅ Tap "View All" if more than 3 portfolios exist
5. ✅ Verify the **Portfolio Gallery Screen** opens showing all portfolios
6. ✅ Tap on a portfolio card to view details

#### Test 2: Create Portfolio (Provider)
**Note**: The UI for creating portfolios may need to be added to the provider account screen. For now, you can test via API or add a button manually.

**Manual Testing via Code:**
```dart
// Navigate to: lib/app/ui_v2/screens/provider/portfolio/add_portfolio_screen_v2.dart
// Or add a button in provider account screen:
Get.to(() => AddEditPortfolioScreenV2(providerId: currentUserId));
```

**Steps:**
1. ✅ Navigate to Add Portfolio screen
2. ✅ Fill in:
   - Title (required)
   - Description (optional)
   - Project Date (optional)
   - Tags (comma-separated, optional)
   - Select Service (optional)
3. ✅ Tap "Add Images" and select multiple images
4. ✅ Verify images appear in preview
5. ✅ Tap "Create Portfolio"
6. ✅ Verify success message
7. ✅ Verify portfolio appears in gallery

#### Test 3: Edit Portfolio (Provider)
1. ✅ Open portfolio gallery
2. ✅ Tap edit icon on a portfolio
3. ✅ Modify title, description, or add more images
4. ✅ Save changes
5. ✅ Verify updates appear immediately

#### Test 4: Delete Portfolio (Provider)
1. ✅ Open portfolio gallery
2. ✅ Tap delete icon on a portfolio
3. ✅ Confirm deletion
4. ✅ Verify portfolio is removed

#### Test 5: Featured Portfolios
1. ✅ Create multiple portfolios
2. ✅ Mark one as featured (via database or API)
3. ✅ Verify featured portfolios appear first in the gallery

### Expected Behavior
- ✅ Portfolios load without errors
- ✅ Images display correctly with caching
- ✅ Empty state shows when no portfolios exist
- ✅ Loading indicators appear during fetch
- ✅ Error messages display if upload fails

---

## Feature 2: Price Comparison & Transparency

### How to Access

**As a Consumer:**
1. Navigate to **Provider Details** screen
2. Look for "Request Quote" button (may need to be added to UI)
3. Or navigate directly to quote request screen

**Navigation Code:**
```dart
Get.to(() => CreateQuoteRequestScreenV2());
```

### Testing Steps

#### Test 1: Create Quote Request (Consumer)
1. ✅ Navigate to Create Quote Request screen
2. ✅ Select a service from dropdown
3. ✅ Select an address from dropdown
4. ✅ Enter description of work needed
5. ✅ (Optional) Select preferred date
6. ✅ Tap "Send Quote Request"
7. ✅ Verify success message
8. ✅ Verify quote request appears in your requests list

#### Test 2: View Quote Requests (Consumer)
1. ✅ Navigate to quote requests list
2. ✅ Verify all your quote requests display:
   - Service name
   - Address
   - Status (pending, responded, expired, cancelled)
   - Created date
3. ✅ Tap on a request to see details

#### Test 3: Respond to Quote (Provider)
**Note**: Provider UI for viewing quote requests may need to be added.

**API Testing:**
```dart
// Use QuoteResponseController
final controller = Get.find<QuoteResponseController>();
controller.initializeResponse(quoteRequestId);
controller.priceController.text = '500.00';
controller.descriptionController.text = 'I can do this work';
controller.submitQuoteResponse();
```

**Steps:**
1. ✅ Provider receives notification of new quote request
2. ✅ Provider views quote request details
3. ✅ Provider enters:
   - Price
   - Description
   - Estimated duration
4. ✅ Provider submits response
5. ✅ Verify response appears in consumer's quote comparison

#### Test 4: Compare Quotes (Consumer)
1. ✅ Open a quote request that has multiple responses
2. ✅ Navigate to Quote Comparison screen
3. ✅ Verify all provider responses display:
   - Provider name and avatar
   - Price
   - Description
   - Estimated duration
   - Response date
4. ✅ Compare prices side-by-side
5. ✅ Tap "Accept" on preferred quote
6. ✅ Verify quote is marked as accepted

#### Test 5: Price Range Indicator
1. ✅ Navigate to service selection screen
2. ✅ Verify price range displays for services:
   - Min price
   - Max price
   - Average price (if available)
3. ✅ Verify price range updates when filtering providers

### Expected Behavior
- ✅ Quote requests create successfully
- ✅ Providers can view and respond to requests
- ✅ Price comparison displays all responses
- ✅ Quote acceptance works correctly
- ✅ Price ranges calculate accurately

---

## Feature 3: Advanced Search & Filtering

### How to Access

1. Navigate to **Home** screen
2. Use the search bar at the top
3. Or navigate to Advanced Search screen

**Navigation Code:**
```dart
Get.to(() => AdvancedSearchScreenV2());
```

### Testing Steps

#### Test 1: Basic Search
1. ✅ Enter a search term (e.g., "plumber", "electrician")
2. ✅ Verify results filter by:
   - Provider name
   - Service name
   - Provider bio
3. ✅ Verify results update in real-time

#### Test 2: Filter by Rating
1. ✅ Open search/filter panel
2. ✅ Adjust "Minimum Rating" slider
3. ✅ Verify only providers with rating >= selected value appear
4. ✅ Test with different rating values (0.0 to 5.0)

#### Test 3: Filter by Price Range
1. ✅ Open filter panel
2. ✅ Adjust price range slider
3. ✅ Set min and max price
4. ✅ Verify providers within price range appear
5. ✅ Verify providers outside range are filtered out

#### Test 4: Filter by Distance
1. ✅ Enable location services
2. ✅ Set maximum distance (e.g., 10 km)
3. ✅ Verify providers sorted by distance
4. ✅ Verify distance displays for each provider

#### Test 5: Filter by Verification Status
1. ✅ Toggle "Verified Only" filter
2. ✅ Verify only verified providers appear
3. ✅ Toggle off to see all providers

#### Test 6: Filter by Availability
1. ✅ Toggle "Available Today" filter
2. ✅ Verify only available providers appear
3. ✅ Verify availability status displays

#### Test 7: Sort Options
1. ✅ Select different sort options:
   - **Rating** (highest first)
   - **Price** (lowest first)
   - **Distance** (nearest first)
   - **Reviews** (most reviews first)
2. ✅ Verify results reorder correctly
3. ✅ Verify sort indicator displays

#### Test 8: Combined Filters
1. ✅ Apply multiple filters simultaneously:
   - Rating >= 4.0
   - Price range: $50 - $200
   - Verified only
   - Available today
   - Sort by rating
2. ✅ Verify results match all criteria
3. ✅ Verify filter chips display active filters
4. ✅ Tap "Clear Filters" to reset

### Expected Behavior
- ✅ Search works with partial matches
- ✅ Filters apply correctly
- ✅ Multiple filters work together
- ✅ Sort options function properly
- ✅ Results update quickly
- ✅ Empty state shows when no results

---

## Feature 4: Enhanced Review System

### How to Access

**As a Consumer:**
1. Complete a booking
2. Navigate to booking details
3. Tap "Rate Provider" or "Leave Review"

**As a Provider:**
1. Navigate to Provider Details screen
2. Scroll to "Ratings" section
3. View all reviews

### Testing Steps

#### Test 1: Leave Review with Images (Consumer)
1. ✅ Open rating/review screen
2. ✅ Select star rating (1-5)
3. ✅ Enter review text
4. ✅ Tap "Add Photos" and select images
5. ✅ Verify images appear in preview
6. ✅ (Optional) Set category ratings:
   - Quality
   - Punctuality
   - Communication
   - Price
7. ✅ Submit review
8. ✅ Verify success message
9. ✅ Verify review appears with images

#### Test 2: View Reviews with Images (Consumer/Provider)
1. ✅ Navigate to provider's ratings section
2. ✅ Verify reviews display:
   - User avatar and name
   - Star rating
   - Review text
   - Review images (if any)
   - Category ratings (if any)
   - "Verified Booking" badge (if applicable)
   - Date
3. ✅ Tap on review images to view full size
4. ✅ Verify image gallery works

#### Test 3: Helpful Votes (Consumer)
1. ✅ View a review
2. ✅ Tap "Helpful" button (thumbs up)
3. ✅ Verify helpful count increases
4. ✅ Tap again to remove vote
5. ✅ Verify count decreases

#### Test 4: Provider Response to Review
1. ✅ As provider, view a review
2. ✅ Tap "Respond" button
3. ✅ Enter response text
4. ✅ Submit response
5. ✅ Verify response appears below review
6. ✅ Verify response is marked as "Provider Response"

#### Test 5: Review Filtering
1. ✅ Open reviews section
2. ✅ Apply filters:
   - **Sort by**: Helpful, Recent, Rating
   - **With Photos**: Show only reviews with images
   - **Verified Only**: Show only verified bookings
3. ✅ Verify reviews filter correctly
4. ✅ Verify filter indicators display

#### Test 6: Category Ratings Display
1. ✅ View a review with category ratings
2. ✅ Verify category chips display:
   - Quality: ⭐⭐⭐⭐⭐
   - Punctuality: ⭐⭐⭐⭐
   - Communication: ⭐⭐⭐⭐⭐
   - Price: ⭐⭐⭐⭐
3. ✅ Verify ratings are accurate

### Expected Behavior
- ✅ Reviews submit successfully
- ✅ Images upload and display correctly
- ✅ Helpful votes work
- ✅ Provider responses appear correctly
- ✅ Filters work as expected
- ✅ Category ratings display properly

---

## Quick Testing Checklist

### Provider Portfolios
- [ ] View portfolios on provider details screen
- [ ] Create new portfolio with images
- [ ] Edit existing portfolio
- [ ] Delete portfolio
- [ ] View portfolio gallery
- [ ] Featured portfolios display first

### Price Comparison
- [ ] Create quote request
- [ ] Provider responds to quote
- [ ] Compare multiple quotes
- [ ] Accept a quote
- [ ] View price ranges for services

### Advanced Search
- [ ] Search by keyword
- [ ] Filter by rating
- [ ] Filter by price range
- [ ] Filter by distance
- [ ] Filter by verification
- [ ] Filter by availability
- [ ] Sort results
- [ ] Combine multiple filters

### Enhanced Reviews
- [ ] Leave review with images
- [ ] View reviews with images
- [ ] Vote review as helpful
- [ ] Provider responds to review
- [ ] Filter reviews
- [ ] View category ratings

---

## Troubleshooting

### Portfolios Not Loading
- Check Supabase Storage bucket `portfolios` exists
- Verify RLS policies allow read access
- Check image URLs are valid

### Quote Requests Not Appearing
- Verify user is authenticated
- Check quote_requests table has data
- Verify RLS policies allow access

### Search Not Working
- Check location services enabled
- Verify database indexes created
- Check RPC function `advanced_search_providers` exists

### Reviews Not Submitting
- Verify booking exists
- Check image upload permissions
- Verify ratings table schema updated

---

## Database Verification

Run these queries in Supabase SQL Editor to verify data:

```sql
-- Check portfolios
SELECT COUNT(*) FROM provider_portfolios;

-- Check quote requests
SELECT COUNT(*) FROM quote_requests WHERE status = 'pending';

-- Check enhanced reviews
SELECT COUNT(*) FROM ratings WHERE image_urls IS NOT NULL AND array_length(image_urls, 1) > 0;

-- Check helpful votes
SELECT COUNT(*) FROM review_helpful_votes;

-- Check provider responses
SELECT COUNT(*) FROM review_responses;
```

---

## Next Steps

1. **Add UI Navigation**: Some features may need navigation buttons added to existing screens
2. **Add Notifications**: Set up push notifications for quote requests and responses
3. **Add Analytics**: Track feature usage
4. **Performance Testing**: Test with large datasets
5. **User Acceptance Testing**: Get feedback from real users

---

## Support

If you encounter issues:
1. Check Supabase logs for API errors
2. Check Flutter console for client errors
3. Verify database migrations applied correctly
4. Check RLS policies are configured properly
5. Verify storage buckets exist and have correct permissions

