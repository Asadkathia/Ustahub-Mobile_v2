<!-- f4e3c254-8abe-4c3e-a794-cbcd2edbdba9 efbbcd1c-cab4-473a-a8be-c96038d1e456 -->
# Roadmap B – UI/UX Enhancements

## 1. Finalize Design System Foundations

- Review and adjust colors/typography/spacing themes in [`lib/app/ui_v2/design_system`](lib/app/ui_v2/design_system) to ensure consistent radii, shadows, paddings, and text styles.
- Add any missing shared text styles (titles/subtitles/body/caption) and spacing constants so downstream screens can rely on them.

## 2. Normalize Core Components

- Audit `lib/app/ui_v2/components` for buttons, cards, inputs, feedback widgets.
- Create/extend reusable widgets (AppCard, AppSearchField, AppEmptyState, Skeleton loaders, etc.) so screens stop using ad‑hoc Containers.
- Ensure components consume AppColorsV2, AppTextStyles, AppSpacing.

## 3. Refactor Priority Screens (P1)

### 3.1 Home Screens

- Consumer: Rebuild sections in [`home_screen_v2.dart`](lib/app/ui_v2/screens/home/home_screen_v2.dart) using the standardized search field, cards, and spacing.
- Provider: Update [`provider_home_screen_v2.dart`](lib/app/ui_v2/screens/home/provider_home_screen_v2.dart) so KPIs, nudges, and lists share the same card/typography system.

### 3.2 Provider Details

- In [`provider_details_screen_v2.dart`](lib/app/ui_v2/screens/provider/provider_details_screen_v2.dart), wrap all sections (header, services, trust signals, reviews) with AppCards and consistent typography while keeping logic untouched.

### 3.3 Booking Summary

- Align [`booking_summary_screen_v2.dart`](lib/app/ui_v2/screens/booking/booking_summary_screen_v2.dart) sections (provider info, booking details, price breakdown) with shared cards and bottom CTA styling.

### 3.4 Search & Advanced Search

- Update [`search_screen_v2.dart`](lib/app/ui_v2/screens/search/search_screen_v2.dart) and [`advanced_search_screen_v2.dart`](lib/app/ui_v2/screens/search/advanced_search_screen_v2.dart) to use AppSearchField, chip/chip-like filters, and consistent empty states.

### 3.5 Chat UI

- Apply unified list/card styles in chat list/detail screens under `lib/app/ui_v2/screens/chat/`, ensuring message bubbles and list items follow the design system.

## 4. Refactor Secondary Screens (P2)

- Tidy account/profile/auth flows (e.g., [`account_screen_v2.dart`](lib/app/ui_v2/screens/account/account_screen_v2.dart), favourites, addresses) using the same components and spacing rules.

## 5. Polish Remaining Screens (P3)

- Apply design-system styling to onboarding, splash, help, and other auxiliary flows once core screens are complete.

Throughout all phases: keep navigation, controllers, and backend interactions unchanged; focus strictly on visual/structural consistency.

### To-dos

- [ ] Phase 1.1: Create database migration for provider_portfolios table
- [ ] Phase 1.2: Add portfolio API methods to SupabaseApiServices
- [ ] Phase 1.3: Create portfolio repository
- [ ] Phase 1.4: Create PortfolioModel class
- [ ] Phase 1.5: Create PortfolioController
- [ ] Phase 1.6: Create UI components (portfolio card, gallery screen, add/edit screen)
- [ ] Phase 1.7: Extend UploadFile class for portfolio bucket
- [ ] Phase 1.8: Integrate portfolio tab in provider details screen
- [ ] Phase 2.1: Create database migration for quote_requests and price_comparison
- [ ] Phase 2.2: Create database functions for price comparison
- [ ] Phase 2.3: Add quote and price comparison API methods
- [ ] Phase 2.4: Create quote repository
- [ ] Phase 2.5: Create quote controllers
- [ ] Phase 2.6: Create quote and price comparison UI components
- [ ] Phase 3.1: Create database migration for enhanced search
- [ ] Phase 3.2: Enhance getProviders() with advanced search parameters
- [ ] Phase 3.3: Extend search repository with filtering methods
- [ ] Phase 3.4: Update search controller with filter state
- [ ] Phase 3.5: Create advanced search UI components and filters
- [ ] Phase 4.1: Create database migration for enhanced reviews
- [ ] Phase 4.2: Enhance rating API methods with images and category ratings
- [ ] Phase 4.3: Update rating repository with new methods
- [ ] Phase 4.4: Update rating controller with image and category rating support
- [ ] Phase 4.5: Create enhanced review UI components
- [ ] Align colors/typography/spacing + theme constants
- [ ] Normalize buttons/cards/inputs/feedback widgets
- [ ] Refactor consumer/provider home screens
- [ ] Restyle provider details screen
- [ ] Align booking summary with new components
- [ ] Restyle search + chat flows
- [ ] Update account/profile/auth screens
- [ ] Polish onboarding/splash/help flows