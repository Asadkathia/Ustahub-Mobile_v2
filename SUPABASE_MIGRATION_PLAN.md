# Supabase Backend Migration Plan

## Overview
Complete replacement of Laravel backend with Supabase, using PostgREST for direct database access, custom OTP authentication via Edge Functions, Supabase Storage for files, and maintaining FCM for push notifications.

## Migration Decisions

1. **Migration Scope**: Complete replacement (1a) - Remove Laravel entirely
2. **Authentication**: Supabase Auth + custom OTP via Edge Functions (2a)
3. **API Layer**: Supabase PostgREST for direct database access (3a)
4. **Database**: Start fresh with new schema optimized for Supabase (4c)
5. **File Storage**: Migrate to Supabase Storage (5a)
6. **Push Notifications**: Keep Firebase FCM (6a)

---

## Phase 1: Supabase Project Setup

### 1.1 Initialize Supabase CLI and Project
- Install Supabase CLI if not present
- Create `supabase/` directory in project root
- Initialize Supabase project: `supabase init`
- Link to Supabase project: `supabase link --project-ref <project-id>`
- Create new Supabase project via CLI or dashboard

### 1.2 Directory Structure
```
supabase/
├── config.toml          # Supabase local config
├── migrations/          # Database migrations
├── functions/           # Edge Functions
│   ├── otp-auth/       # Custom OTP authentication
│   ├── fcm-token/      # FCM token management
│   └── booking-notes/   # Booking notes management
├── seed.sql            # Seed data
└── .env.example        # Environment variables template
```

---

## Phase 2: Database Schema Design

### 2.1 Core Tables (Fresh Schema)
Create migrations for:

#### User Management
- `users` - Unified user table (consumers + providers) - extends Supabase auth.users
- `user_profiles` - Extended profile data (name, avatar, role, phone, etc.)
- `addresses` - User addresses with default flag
- `fcm_tokens` - FCM token storage per user

#### Service & Provider
- `services` - Service categories (appliances, plumbing, etc.)
- `providers` - Provider-specific data (business info, verification status)
- `provider_services` - Provider-service relationships (many-to-many)
- `plans` - Service plans (Basic/Standard/Premium) linked to provider_services
- `provider_documents` - Provider KYC documents

#### Booking System
- `bookings` - Booking records with status workflow
- `booking_notes` - Notes added to bookings
- `booking_slots` - Available time slots per provider

#### Engagement
- `ratings` - Provider ratings by consumers
- `favorites` - Consumer favorite providers
- `banners` - Homepage banners

#### Financial
- `wallet_transactions` - Provider wallet transactions
- `wallet_balance` - Current wallet balance per provider

### 2.2 Row Level Security (RLS) Policies

#### Users & Profiles
- Users can only read/update their own profile
- Public read access to provider profiles (for discovery)
- Providers can update their own profile

#### Addresses
- Users can only manage their own addresses
- Users can set one default address

#### Services
- Public read access to services
- Only admins can create/update services

#### Providers
- Public read access to provider public data
- Providers can only update their own data

#### Bookings
- Consumers can read their own bookings
- Providers can read bookings assigned to them
- Consumers can create bookings
- Providers can update booking status (accept/reject/start/complete)

#### Ratings
- Consumers can create ratings for completed bookings
- Public read access to ratings
- Users can only update their own ratings

#### Favorites
- Users can only manage their own favorites
- Public read access to favorite counts

### 2.3 Database Functions

#### Booking Functions
- `get_booking_slots(provider_id, booking_date)` - Returns available time slots
- `calculate_booking_total(service_id, plan_id, visiting_charge)` - Calculates total price
- `get_provider_dashboard_data(provider_id)` - Returns dashboard metrics

#### Search Functions
- `search_providers(search_term, service_id, filters)` - Provider search with filters
- `get_top_providers(limit, service_id)` - Top rated providers

---

## Phase 3: Authentication Migration

### 3.1 Edge Function: OTP Authentication

#### Create `supabase/functions/otp-auth/index.ts`

**Send OTP Flow:**
1. Receive email/phone from request
2. Generate 4-digit OTP
3. Store OTP in `otp_verifications` table with expiration (10 min)
4. Send OTP via email (using Supabase email or external service)
5. Return success response

**Verify OTP Flow:**
1. Receive email/phone + OTP from request
2. Check OTP validity and expiration
3. If valid:
   - Check if user exists in Supabase Auth
   - If new user: Create user in Supabase Auth
   - If existing: Sign in user
   - Create/update user profile with role
   - Return session token
4. If invalid: Return error

### 3.2 Supabase Auth Configuration
- Enable email provider in Supabase dashboard
- Configure email templates for OTP (optional, if using Supabase email)
- Set up custom auth hooks if needed
- Configure JWT expiration settings (default 1 hour, refresh tokens)

### 3.3 Role-Based Access
- Store role (consumer/provider) in `user_profiles.role`
- Use Supabase user metadata for quick role access
- Create database function to get user role: `get_user_role(user_id)`

### 3.4 Google Authentication (Future)
- Can use Supabase's built-in Google OAuth
- Or keep custom Google token verification in Edge Function

---

## Phase 4: API Migration to PostgREST

### 4.1 Flutter Supabase Client Setup

#### Add to `pubspec.yaml`:
```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

#### Create `lib/network/supabase_client.dart`:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClient {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
  }
  
  static SupabaseClient get instance => Supabase.instance.client;
}
```

### 4.2 Endpoint Mapping

#### Public Endpoints (No Auth Required)
| Laravel Route | Supabase PostgREST |
|--------------|-------------------|
| `GET /api/get-services` | `supabase.from('services').select()` |
| `GET /api/banners` | `supabase.from('banners').select().eq('is_active', true)` |
| `GET /api/user/get-providers` | `supabase.from('providers').select().eq('is_verified', true)` |
| `GET /api/user/get-provider-by-id/{id}` | `supabase.from('providers').select().eq('id', id).single()` |

#### Consumer Endpoints (Auth Required)
| Laravel Route | Supabase PostgREST |
|--------------|-------------------|
| `GET /api/user/profile` | `supabase.from('user_profiles').select().eq('user_id', userId).single()` |
| `POST /api/user/profile-update` | `supabase.from('user_profiles').upsert(data).eq('user_id', userId)` |
| `GET /api/user/addresses` | `supabase.from('addresses').select().eq('user_id', userId)` |
| `POST /api/user/addresses` | `supabase.from('addresses').insert(data)` |
| `POST /api/user/favorite-provider` | `supabase.from('favorites').upsert(data)` |
| `POST /api/user/book-service` | `supabase.from('bookings').insert(data)` |
| `GET /api/user/get-bookings` | `supabase.from('bookings').select().eq('consumer_id', userId)` |
| `POST /api/user/rate-provider` | `supabase.from('ratings').insert(data)` |

#### Provider Endpoints (Auth Required)
| Laravel Route | Supabase PostgREST |
|--------------|-------------------|
| `GET /api/provider/profile` | `supabase.from('user_profiles').select().eq('user_id', userId).single()` |
| `POST /api/provider/add-service` | `supabase.from('provider_services').insert(data)` |
| `GET /api/provider/get-booking-request` | `supabase.from('bookings').select().eq('provider_id', userId).eq('status', 'pending')` |
| `POST /api/provider/accept-or-reject-booking` | `supabase.from('bookings').update(data).eq('id', bookingId)` |
| `GET /api/provider/get-home-screen-data` | Use database function `get_provider_dashboard_data()` |

### 4.3 Edge Functions for Complex Logic

#### Booking Workflow Edge Function
- `accept-booking`: Accept booking request
- `reject-booking`: Reject booking with reason
- `start-booking`: Start work on booking
- `complete-booking`: Complete booking and trigger payment

#### Wallet Edge Function
- `add-funds`: Add funds to provider wallet
- `get-balance`: Get current wallet balance
- `get-transactions`: Get transaction history

#### Search Edge Function
- `search-providers`: Complex search with filters (location, rating, price, etc.)

---

## Phase 5: File Storage Migration

### 5.1 Supabase Storage Setup

#### Create Storage Buckets:
1. **avatars** - User profile pictures
   - Public read access
   - Authenticated write access (own files only)
   
2. **documents** - Provider KYC documents
   - Private bucket
   - Provider can only access their own documents
   
3. **banners** - Homepage banners
   - Public read access
   - Admin write access only
   
4. **service-images** - Service category images
   - Public read access
   - Admin write access only

### 5.2 Storage RLS Policies
- Users can upload to their own folder: `{user_id}/filename`
- Users can read public buckets
- Users can only delete their own files

### 5.3 Flutter Storage Integration

#### Update `lib/app/modules/upload_file/upload_file.dart`:
```dart
// Replace multipart upload with:
final file = File(imagePath);
final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

await supabase.storage
  .from('avatars')
  .upload(fileName, file);

final publicUrl = supabase.storage
  .from('avatars')
  .getPublicUrl(fileName);
```

### 5.4 Migration Script
- Export files from Laravel storage
- Upload to Supabase Storage maintaining folder structure
- Update database URLs to point to Supabase Storage

---

## Phase 6: Flutter App Updates

### 6.1 Authentication Flow Updates

#### Update `lib/app/modules/Auth/login/controller/login_controller.dart`:
- Replace OTP send API call with Edge Function: `supabase.functions.invoke('otp-auth', body: {'action': 'send', 'email': email})`

#### Update `lib/app/modules/Auth/OTP/controller/otp_controller.dart`:
- Replace OTP verify API call with Edge Function: `supabase.functions.invoke('otp-auth', body: {'action': 'verify', 'email': email, 'otp': otp})`
- On success, use Supabase session: `supabase.auth.setSession(accessToken, refreshToken)`
- Store session instead of custom token

#### Update `lib/utils/sharedPrefHelper/sharedPrefHelper.dart`:
- Add methods to get Supabase session
- Keep role storage in SharedPreferences
- Remove custom token storage

### 6.2 API Service Layer Updates

#### Create `lib/network/supabase_api_services.dart`:
```dart
class SupabaseApiServices {
  final supabase = Supabase.instance.client;
  
  // Replace all HTTP calls with Supabase queries
  Future<Map<String, dynamic>> getProfile() async {
    final response = await supabase
      .from('user_profiles')
      .select()
      .eq('user_id', supabase.auth.currentUser!.id)
      .single();
    return {'statusCode': 200, 'body': {'status': true, 'user': response}};
  }
  
  // Similar methods for all endpoints
}
```

#### Update All Repositories:
- `lib/app/modules/Auth/login/repository/login_repository.dart`
- `lib/app/modules/consumer_profile/controller/consumer_profile_controller.dart`
- All other repositories to use Supabase client

### 6.3 Update API Endpoints File
- Update `lib/utils/apiEndPoints/apiEndPoints.dart` to remove Laravel URLs
- Keep endpoint constants for Edge Functions
- Document PostgREST queries

### 6.4 Real-time Features
- Use Supabase Realtime subscriptions for:
  - Booking status updates
  - New booking requests (for providers)
  - Chat messages (if migrating from Zego)

---

## Phase 7: FCM Integration

### 7.1 FCM Token Storage

#### Create `fcm_tokens` table:
```sql
CREATE TABLE fcm_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  device_type TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, token)
);
```

#### Create Edge Function `fcm-token`:
- `store-token`: Store/update FCM token for user
- `remove-token`: Remove token on logout

### 7.2 Push Notifications

#### Keep Firebase Setup:
- Maintain `firebase_messaging` package
- Keep Firebase Cloud Messaging configuration
- Use Edge Function to send notifications via FCM Admin SDK

#### Edge Function for Notifications:
- `send-notification`: Send push notification via FCM
- Triggered by database events (booking status change, etc.)

---

## Phase 8: Testing & Migration

### 8.1 Local Development
1. Run Supabase locally: `supabase start`
2. Apply migrations: `supabase db reset`
3. Test all endpoints locally
4. Verify RLS policies work correctly
5. Test Edge Functions locally: `supabase functions serve`

### 8.2 Data Migration Script
1. Export data from Laravel database (MySQL/PostgreSQL dump)
2. Transform data to match new Supabase schema
3. Create migration script to import data
4. Verify data integrity after import
5. Test with sample data first

### 8.3 Environment Configuration

#### Create `.env` file:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
FIREBASE_PROJECT_ID=your-firebase-project-id
```

#### Update Flutter app:
- Add Supabase initialization in `main.dart`
- Update API base URL references
- Configure environment-specific settings

### 8.4 Deployment
1. Push migrations to Supabase: `supabase db push`
2. Deploy Edge Functions: `supabase functions deploy`
3. Update Flutter app with production Supabase URLs
4. Test in staging environment
5. Deploy to production

---

## Files to Create/Modify

### New Files:
- `supabase/config.toml` - Supabase configuration
- `supabase/migrations/0001_initial_schema.sql` - Initial database schema
- `supabase/migrations/0002_rls_policies.sql` - RLS policies
- `supabase/migrations/0003_functions.sql` - Database functions
- `supabase/functions/otp-auth/index.ts` - OTP authentication
- `supabase/functions/fcm-token/index.ts` - FCM token management
- `supabase/functions/booking-workflow/index.ts` - Booking operations
- `supabase/functions/wallet/index.ts` - Wallet operations
- `lib/network/supabase_client.dart` - Supabase client initialization
- `lib/network/supabase_api_services.dart` - Supabase API service layer
- `.env.example` - Environment variables template
- `SUPABASE_MIGRATION_PLAN.md` - This file

### Modified Files:
- `pubspec.yaml` - Add `supabase_flutter` dependency
- `lib/main.dart` - Initialize Supabase client
- `lib/utils/apiEndPoints/apiEndPoints.dart` - Update endpoint references
- `lib/utils/sharedPrefHelper/sharedPrefHelper.dart` - Add Supabase session methods
- `lib/network/network_api_services.dart` - Deprecate or replace with Supabase
- All repository files in `lib/app/modules/*/repository/` - Replace HTTP calls
- All controller files - Update API calls to use Supabase
- `lib/app/modules/upload_file/upload_file.dart` - Use Supabase Storage
- `lib/app/modules/Auth/login/controller/login_controller.dart` - Use Edge Function
- `lib/app/modules/Auth/OTP/controller/otp_controller.dart` - Use Edge Function
- `lib/app/modules/fcm/service/fcm_service.dart` - Update to use Supabase

---

## Implementation Order

1. ✅ Create Supabase project and directory structure
2. Design and create database schema (migrations)
3. Set up RLS policies for security
4. Create database functions for complex queries
5. Set up authentication with OTP Edge Function
6. Migrate core CRUD operations to PostgREST
7. Create Edge Functions for complex business logic
8. Migrate file storage to Supabase Storage
9. Update Flutter app authentication flow
10. Update Flutter app API service layer
11. Update all repositories and controllers
12. Test locally with Supabase
13. Migrate existing data
14. Deploy to production

---

## Key Considerations

### Security
- Always use RLS policies - never disable them
- Use service role key only in Edge Functions (server-side)
- Use anon key in Flutter app (client-side)
- Validate all inputs in Edge Functions
- Use Supabase Auth for all authentication

### Performance
- Use database functions for complex queries
- Implement proper indexing on frequently queried columns
- Use PostgREST filters instead of fetching all data
- Cache static data (services, banners) in Flutter app

### Data Integrity
- Use foreign keys and constraints
- Implement soft deletes where appropriate
- Use transactions for multi-step operations
- Add proper error handling

### Migration Strategy
- Start with read-only operations
- Migrate write operations gradually
- Keep Laravel backend running during transition
- Use feature flags to switch between backends
- Monitor error rates and performance

---

## Rollback Plan

If issues arise:
1. Keep Laravel backend running in parallel
2. Use feature flags to switch back to Laravel
3. Maintain data sync between both systems during transition
4. Document all changes for easy rollback

---

## Success Criteria

- [ ] All authentication flows working
- [ ] All CRUD operations migrated
- [ ] File uploads working with Supabase Storage
- [ ] RLS policies properly configured
- [ ] Edge Functions deployed and working
- [ ] Flutter app fully functional
- [ ] Performance equal or better than Laravel
- [ ] All existing data migrated
- [ ] Production deployment successful

---

## Notes

- This is a complete backend replacement - Laravel will be removed
- Supabase provides automatic API generation via PostgREST
- Real-time features can be added easily with Supabase Realtime
- Edge Functions use Deno runtime (TypeScript)
- Database is PostgreSQL (Supabase managed)
- Storage is S3-compatible (Supabase managed)

---

## Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [PostgREST API](https://postgrest.org/)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)


