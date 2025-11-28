# Location-Based Images Guide

This guide explains how to add images to onboarding slides and banners, and how the app uses location-based image selection.

## Overview

The app now supports location-based content for:
- **Banners**: Display different banner images based on user's city/country
- **Onboarding Slides**: Show location-specific onboarding content

## Database Schema

Both `banners` and `onboarding_slides` tables now have location fields:
- `city` (TEXT, nullable): City name for location-specific content
- `country` (TEXT, default: 'all'): Country code for location-specific content

## How Location-Based Filtering Works

1. **Location Detection**: The app automatically detects the user's location using `LocationController`
2. **Priority Order**: 
   - First, tries to find content matching the user's city and country
   - If not found, falls back to content with `city = null` or `city = 'all'`
   - If still not found, falls back to content with `country = 'all'` or `country = null`
3. **Default Behavior**: Content with `city = null` and `country = 'all'` is shown to all users

## Adding Images to Supabase

### Method 1: Via Supabase Dashboard

1. Go to your Supabase project: https://supabase.com/dashboard/project/pyezhaebfvitqkpsjsil
2. Navigate to **Table Editor** > **banners** or **onboarding_slides**
3. Click **Insert** > **Insert row**
4. Fill in the fields:
   - `image`: URL to the image (can be Supabase Storage URL or external URL)
   - `title`: Banner/slide title
   - `city`: (Optional) City name for location-specific content (e.g., "Tashkent", "Dubai")
   - `country`: (Optional) Country code (e.g., "UZ", "AE", "all" for global)
   - `is_active`: true
   - `display_order`: Order number (lower numbers appear first)

### Method 2: Via SQL Editor

```sql
-- Add a location-specific banner for Tashkent, Uzbekistan
INSERT INTO public.banners (
  image,
  title,
  city,
  country,
  is_active,
  display_order
) VALUES (
  'https://your-storage-url.com/banners/tashkent-banner.jpg',
  'Welcome to Tashkent',
  'Tashkent',
  'UZ',
  true,
  1
);

-- Add a global banner (shown to all users)
INSERT INTO public.banners (
  image,
  title,
  city,
  country,
  is_active,
  display_order
) VALUES (
  'https://your-storage-url.com/banners/global-banner.jpg',
  'Welcome to Ustahub',
  NULL,
  'all',
  true,
  2
);

-- Add a location-specific onboarding slide
INSERT INTO public.onboarding_slides (
  banner_id,
  title,
  subtitle,
  description,
  city,
  country,
  audience,
  is_active,
  display_order
) VALUES (
  (SELECT id FROM banners WHERE title = 'Welcome to Tashkent' LIMIT 1),
  'Local Services in Tashkent',
  'Find trusted providers near you',
  'Connect with verified service providers in your area',
  'Tashkent',
  'UZ',
  'all',
  true,
  1
);
```

## Image Storage Options

### Option 1: Supabase Storage (Recommended)

1. Go to **Storage** in Supabase Dashboard
2. Create/use a bucket (e.g., `banners`, `onboarding-images`)
3. Upload your images
4. Copy the public URL and use it in the `image` field

Example URL format:
```
https://pyezhaebfvitqkpsjsil.supabase.co/storage/v1/object/public/banners/tashkent-banner.jpg
```

### Option 2: External URLs

You can use any publicly accessible image URL:
```
https://example.com/images/banner.jpg
```

## Controllers

### OnboardingControllerV2

Located at: `lib/app/modules/onboarding/controller/onboarding_controller_v2.dart`

**Features:**
- Automatically detects user location
- Fetches location-based onboarding slides
- Falls back to default slides if location-specific content isn't available

**Usage:**
```dart
final controller = Get.put(OnboardingControllerV2());
await controller.fetchSlides(); // Fetches slides based on location
await controller.refreshSlides(); // Refreshes location and slides
```

### BannerController

Located at: `lib/app/modules/banners/controller/banner_controller.dart`

**Features:**
- Automatically detects user location
- Fetches location-based banners
- Falls back to global banners if location-specific content isn't available

**Usage:**
```dart
final controller = Get.put(BannerController());
await controller.getBanners(); // Fetches banners based on location
await controller.refreshBanners(); // Refreshes location and banners
```

## Location Detection

The app uses `LocationController` to:
1. Get user's current GPS coordinates
2. Reverse geocode to get city and country
3. Use this information to filter banners and onboarding slides

**Location Properties:**
- `currentCity`: User's current city (e.g., "Tashkent")
- `currentCountry`: User's current country code (e.g., "UZ")

## Example: Adding Location-Specific Content

### For Tashkent, Uzbekistan:

```sql
-- Banner for Tashkent
INSERT INTO public.banners (image, title, city, country, is_active, display_order)
VALUES (
  'https://storage-url.com/tashkent-banner.jpg',
  'Welcome to Tashkent Services',
  'Tashkent',
  'UZ',
  true,
  1
);

-- Onboarding slide for Tashkent
INSERT INTO public.onboarding_slides (
  banner_id,
  title,
  subtitle,
  description,
  city,
  country,
  audience,
  is_active,
  display_order
)
SELECT 
  b.id,
  'Local Services in Tashkent',
  'Trusted providers in your city',
  'Find verified service providers near you',
  'Tashkent',
  'UZ',
  'all',
  true,
  1
FROM banners b
WHERE b.city = 'Tashkent' AND b.country = 'UZ'
LIMIT 1;
```

### For Global Content (All Locations):

```sql
-- Global banner (shown to all users)
INSERT INTO public.banners (image, title, city, country, is_active, display_order)
VALUES (
  'https://storage-url.com/global-banner.jpg',
  'Welcome to Ustahub',
  NULL,
  'all',
  true,
  0
);
```

## Testing Location-Based Images

1. **On Simulator**: 
   - Go to Simulator > Features > Location
   - Set a custom location (e.g., Tashkent, Uzbekistan)
   - Restart the app to see location-specific content

2. **On Physical Device**:
   - The app will automatically detect your location
   - Ensure location permissions are granted

3. **Verify in Database**:
   - Check that banners/slides have correct `city` and `country` values
   - Ensure `is_active = true` for content you want to display

## Migration Status

✅ Migration applied: `20251128000000_add_location_fields_to_banners_and_onboarding.sql`
- Added `city` and `country` fields to `banners` table
- Added `city` and `country` fields to `onboarding_slides` table
- Created indexes for location-based queries
- Set default `country = 'all'` for existing records

## Next Steps

1. Upload banner images to Supabase Storage
2. Add banner records with location information
3. Link onboarding slides to banners
4. Test with different locations to verify location-based filtering works

