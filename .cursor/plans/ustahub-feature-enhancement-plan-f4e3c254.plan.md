<!-- f4e3c254-8abe-4c3e-a794-cbcd2edbdba9 5d0abf13-7ef2-49e7-a0da-c40c37713eb4 -->
# Roadmap A: Core Improvements Implementation Plan

## Overview

Implement core improvements across booking flow, trust & safety, architecture, and provider tools. All changes preserve existing business logic and Supabase schema.

---

## P1 – Booking Funnel, Trust & Safety

### 1.1 Improve Booking Flow UX

**File: `lib/app/ui_v2/screens/booking/booking_summary_screen_v2.dart`**

- Add price breakdown section showing:
  - `service_price` (from selected plan)
  - `service_fee` (from booking data)
  - `visit_fee` / `visiting_charge` (from booking data)
  - `total_amount` (calculated sum)
- Group information into clear sections:
  - Provider info (existing card)
  - Service & Address/Time (existing card)
  - **NEW**: Price Breakdown card
- Add loading state to "Confirm" button (already has `isLoading` but ensure it's properly displayed)

**File: `lib/app/modules/service_success/view/service_success_view.dart`**

- Replace countdown auto-navigation with action buttons:
  - "View Booking" button → Navigate to `BookingScreenV2` with booking ID
  - "Chat with Provider" button → Navigate to chat screen
- Display booking ID prominently
- Show booking summary (provider name, service, date/time)
- Remove auto-redirect timer (keep manual navigation only)

**File: `lib/app/modules/booking_summary/controller/booking_summary_controller.dart`**

- Modify `bookService()` to return booking ID after successful creation
- Pass booking ID to `ServiceSuccessView`

### 1.2 Make Advanced Search Discoverable

**File: `lib/app/ui_v2/screens/search/advanced_search_screen_v2.dart`** (CREATE NEW)

- Create new screen with filter options:
  - Price range slider
  - Rating filter
  - Distance filter
  - Service category filter
  - Sort options (rating, price, distance, reviews)
  - Verified only toggle
- Integrate with existing `ProviderController.searchProviders()` or create new search method
- Display results using `ProvidersListScreenV2`

**File: `lib/app/ui_v2/screens/search/search_screen_v2.dart`**

- Add filter icon button next to search field
- Icon: `Icons.tune` or `Icons.filter_list`
- On tap: Navigate to `AdvancedSearchScreenV2`

**File: `lib/app/ui_v2/screens/home/home_screen_v2.dart`**

- Add filter icon button in search bar (next to search icon)
- On tap: Navigate to `AdvancedSearchScreenV2`
- Remove long-press gesture (already removed per user edits)

### 1.3 Add Trust Signals in Provider Details

**File: `lib/app/ui_v2/screens/provider/provider_details_screen_v2.dart`**

- Add trust signals section after provider header:
  - "Member since YEAR" - Extract year from `overview.registeredSince` or `provider.created_at`
  - "Hired X times" - Display `overview.totalBookings` (completed_bookings)
  - Verified badge - Show if `provider.isVerified == true` (use existing badge component or create simple chip)
  - City/Region - Display `overview.city` prominently
- Place trust signals between `_ProviderHeader` and `_buildRatingSummary`
- Use consistent card styling with existing sections

### 1.4 Strengthen Authentication & Role Guards

**Files to modify:**

- `lib/app/modules/booking_summary/controller/booking_summary_controller.dart`
- `lib/app/modules/chat/controller/chat_controller.dart` (if exists)
- `lib/app/modules/favourite_providers/controller/favourite_provider_controller.dart`
- Any consumer-specific action controllers

**Implementation:**

- Add `_checkAuth()` helper method:
  ```dart
  Future<bool> _checkAuth({required String requiredRole}) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) {
      Get.to(() => LoginRequiredScreenV2(feature: 'Booking'));
      return false;
    }
    final role = await Sharedprefhelper.getRole();
    if (requiredRole == 'consumer' && role != 'consumer') {
      CustomToast.error('This feature is only available for consumers');
      return false;
    }
    if (requiredRole == 'provider' && role != 'provider') {
      CustomToast.error('This feature is only available for providers');
      return false;
    }
    return true;
  }
  ```

- Call `_checkAuth()` at start of critical methods (e.g., `bookService()`, `addToFavorites()`)

### 1.5 Supabase RLS Safety Patterns

**File: `lib/network/supabase_api_services.dart`**

- Review all methods to ensure they use `SupabaseClientService.currentUserId` instead of manual userId parameters
- Add defensive checks: `if (userId == null) return _handleError('User not authenticated', statusCode: 401);`
- Ensure booking/chat endpoints validate `auth.uid()` matches the user making the request

---

## P2 – Architecture & Performance

### 2.1 Split SupabaseApiServices

**Create new directory: `lib/network/supabase_services/`**

**File: `lib/network/supabase_services/user_supabase_service.dart`** (CREATE)

- Move user-related methods:
  - `getProfile()`
  - `updateProfile()`
  - `getProviderProfile()`
  - `updateProviderProfile()`
  - Any user profile operations

**File: `lib/network/supabase_services/provider_supabase_service.dart`** (CREATE)

- Move provider-related methods:
  - `getProviderById()`
  - `getProviders()`
  - `searchProviders()`
  - Any provider listing/search operations

**File: `lib/network/supabase_services/booking_supabase_service.dart`** (CREATE)

- Move booking-related methods:
  - `createBooking()`
  - `getBookings()`
  - `updateBookingStatus()`
  - Any booking operations

**File: `lib/network/supabase_api_services.dart`** (MODIFY)

- Keep as facade/wrapper that delegates to specific services
- Maintain backward compatibility by importing and re-exporting methods
- Or: Update all repository files to import from specific services

**Note:** This is a large refactor. Consider doing it incrementally:

1. Create new service files
2. Move methods one category at a time
3. Update imports in repositories
4. Test after each category

### 2.2 Convert Heavy Controllers to Lazy Load

**Files to modify:**

- `lib/app/modules/common_controller.dart/provider_controller.dart` - Change `Get.put()` to `Get.lazyPut()`
- `lib/app/modules/banners/controller/banner_controller.dart`
- `lib/app/modules/bookings/view/booking_view.dart` - Change `Get.put(BookingController())` to `Get.lazyPut(() => BookingController())`
- Any other heavy controllers initialized with `Get.put()` in `initState()`

**Pattern:**

```dart
// Before:
final controller = Get.put(HeavyController());

// After:
Get.lazyPut(() => HeavyController());
final controller = Get.find<HeavyController>();
```

### 2.3 Standardize Empty/Error States

**Create reusable widgets:**

- `lib/app/ui_v2/components/feedback/empty_state_v2.dart` - Standard empty state widget
- `lib/app/ui_v2/components/feedback/skeleton_loader_v2.dart` - Skeleton loader widget

**Files to update:**

- `lib/app/ui_v2/screens/search/search_screen_v2.dart` - Replace plain text empty state
- `lib/app/ui_v2/screens/bookings/booking_screen_v2.dart` - Add skeleton loaders
- `lib/app/ui_v2/screens/provider/provider_details_screen_v2.dart` - Improve error states
- Any list screens showing "No items" messages

### 2.4 Improve Error Handling

**File: `lib/network/supabase_api_services.dart`** (and split services)

- Standardize `_handleResponse()` and `_handleError()` to return:
  ```dart
  {
    'status': bool,
    'message': String?,
    'data': dynamic
  }
  ```

- Update all service methods to use this format
- Update repositories to handle standardized format
- Update controllers to check `status` field

---

## P3 – Growth, Provider Tools, Marketing

### 3.1 Provider KPI Dashboard

**File: `lib/app/ui_v2/screens/home/provider_home_screen_v2.dart`**

- Add KPI cards in dashboard section:
  - **Bookings this month** - Query bookings where `created_at >= start of month`
  - **Profile views** - Add `profile_views` column to providers table (if not exists) OR use existing metric
  - **Monthly earnings** - Sum of `total_amount` from completed bookings this month
  - **Average rating** - Already available in provider profile
- Use existing `_getDashboardItems()` pattern
- Add new dashboard items with appropriate icons and navigation

**File: `lib/app/modules/provider_homepage/controller/provider_home_screen_controller.dart`**

- Add methods to fetch:
  - Monthly bookings count
  - Monthly earnings
  - Profile views (if tracked)
- Store in reactive variables: `RxInt monthlyBookings`, `RxDouble monthlyEarnings`, etc.

### 3.2 In-App Nudges

**File: `lib/app/ui_v2/screens/home/provider_home_screen_v2.dart`**

- Add banner/nudge component at top of screen when:
  - Profile incomplete: Check if required fields (bio, business_name, avatar) are missing
  - Portfolio empty: Check if provider has any portfolio items (if portfolio feature exists)
  - Plans empty: Check if `provider.plans.isEmpty`
  - Low acceptance rate: Calculate from bookings (accepted / total requests)
- Use `StatusToastV2` or create new `NudgeBannerV2` component
- Show dismissible banners with action buttons ("Complete Profile", "Add Plans", etc.)

### 3.3 Marketing & Seasonal Campaigns

**File: `lib/app/ui_v2/screens/home/home_screen_v2.dart`**

- Enhance existing countdown offers (already has `CountdownController`)
- Ensure banners are localizable
- Add country-based campaign logic (if needed)

---

## Implementation Order

1. **P1.1** - Booking flow improvements (summary + success screen)
2. **P1.2** - Advanced search discoverability
3. **P1.3** - Trust signals in provider details
4. **P1.4** - Authentication guards
5. **P1.5** - RLS safety patterns
6. **P2.1** - Split SupabaseApiServices (incremental)
7. **P2.2** - Lazy load controllers
8. **P2.3** - Standardize empty/error states
9. **P2.4** - Error handling standardization
10. **P3.1** - Provider KPI dashboard
11. **P3.2** - In-app nudges
12. **P3.3** - Marketing enhancements

---

## Testing Checklist

After each phase:

- [ ] App builds without errors
- [ ] Booking flow works end-to-end
- [ ] Advanced search opens and filters work
- [ ] Trust signals display correctly
- [ ] Authentication guards block unauthorized access
- [ ] Provider KPIs calculate correctly
- [ ] No regressions in existing features

---

## Notes

- **DO NOT** modify Supabase schema
- **DO NOT** change brand colors or UI styling (except for clarity)
- **DO NOT** change existing navigation patterns (unless required for UX)
- Preserve all business logic
- Test incrementally after each major change

### To-dos

- [ ] Fix timer in home_screen_v2.dart to use GetX observables instead of setState
- [ ] Remove shrinkWrap: true from nested ListViews and replace with direct children
- [ ] Pre-compute reversed lists in ProviderController to avoid repeated operations
- [ ] Create image cache configuration utility for CachedNetworkImage
- [ ] Create logger utility to replace print statements
- [ ] Add const constructors where possible in home_screen_v2.dart
- [ ] Optimize GetX controller initialization to avoid duplicates
- [ ] Add RepaintBoundary for expensive widgets