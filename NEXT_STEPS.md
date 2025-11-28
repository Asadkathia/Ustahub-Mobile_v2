# Next Steps - Complete Supabase Migration

## Priority 1: Configure Flutter App with Supabase Credentials

### Step 1.1: Get Supabase API Keys
1. Go to: https://supabase.com/dashboard/project/pyezhaebfvitqkpsjsil/settings/api
2. Copy these values:
   - **Project URL**: `https://pyezhaebfvitqkpsjsil.supabase.co`
   - **anon public** key (starts with `eyJ...`)
   - **service_role** key (keep this secret - only for server-side)

### Step 1.2: Update Flutter App Configuration

**Option A: Update main.dart directly (Quick)**
```dart
// In lib/main.dart, replace the placeholder values:
const supabaseUrl = 'https://pyezhaebfvitqkpsjsil.supabase.co';
const supabaseAnonKey = 'your-actual-anon-key-here';
```

**Option B: Use environment variables (Recommended)**
1. Create `.env` file in project root:
   ```
   SUPABASE_URL=https://pyezhaebfvitqkpsjsil.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```
2. Add `flutter_dotenv` package to `pubspec.yaml`
3. Load in `main.dart`

### Step 1.3: Test Supabase Connection
Run the app and check logs for:
- `[SUPABASE] ✅ Connected successfully` (or similar)
- No errors about missing Supabase initialization

---

## Priority 2: Create Storage Buckets

### Step 2.1: Create Buckets in Supabase Dashboard
Go to: https://supabase.com/dashboard/project/pyezhaebfvitqkpsjsil/storage/buckets

Create these buckets:

1. **avatars** (Public)
   - Name: `avatars`
   - Public: ✅ Yes
   - File size limit: 5MB
   - Allowed MIME types: `image/jpeg, image/png, image/webp`

2. **documents** (Private)
   - Name: `documents`
   - Public: ❌ No
   - File size limit: 10MB
   - Allowed MIME types: `application/pdf, image/jpeg, image/png`

3. **banners** (Public)
   - Name: `banners`
   - Public: ✅ Yes
   - File size limit: 5MB
   - Allowed MIME types: `image/jpeg, image/png, image/webp`

4. **service-images** (Public)
   - Name: `service-images`
   - Public: ✅ Yes
   - File size limit: 5MB
   - Allowed MIME types: `image/jpeg, image/png, image/webp`

### Step 2.2: Set Storage Policies (Optional)
RLS policies are automatically applied, but you can verify in:
Dashboard > Storage > Policies

---

## Priority 3: Update Authentication Flow

### Step 3.1: Update Login Controller
**File**: `lib/app/modules/Auth/login/controller/login_controller.dart`

Replace the OTP send API call:
```dart
// OLD: Using Laravel API
final response = await _api.sendOtpToEmail(email, role);

// NEW: Using Supabase Edge Function
final response = await SupabaseApiServices().callEdgeFunction('otp-auth', {
  'action': 'send',
  'email': email,
  'role': role,
});
```

### Step 3.2: Update OTP Controller
**File**: `lib/app/modules/Auth/OTP/controller/otp_controller.dart`

Replace OTP verification:
```dart
// OLD: Using Laravel API
final response = await _api.emailLogin(data, role);

// NEW: Using Supabase Edge Function + Auth
final otpResponse = await SupabaseApiServices().callEdgeFunction('otp-auth', {
  'action': 'verify',
  'email': email,
  'otp': otp,
  'role': role,
});

if (otpResponse['statusCode'] == 200) {
  // Create Supabase session
  final supabase = SupabaseClientService.instance;
  final session = await supabase.auth.signInWithPassword(
    email: email,
    password: 'temp', // This needs to be handled differently
  );
  
  // Actually, better approach: Use passwordless auth
  // Or implement custom session creation
}
```

**Note**: The OTP Edge Function currently returns user info but doesn't create a session. You'll need to either:
- Modify the Edge Function to return a session token
- Use Supabase's passwordless auth flow
- Create a custom session after OTP verification

### Step 3.3: Update Session Management
**File**: `lib/utils/sharedPrefHelper/sharedPrefHelper.dart`

Add methods to work with Supabase sessions:
```dart
static Future<void> saveSupabaseSession() async {
  final supabase = SupabaseClientService.instance;
  final session = supabase.auth.currentSession;
  if (session != null) {
    await setSharedPrefHelper('supabase_access_token', session.accessToken);
    await setSharedPrefHelper('supabase_refresh_token', session.refreshToken);
  }
}

static Future<String?> getSupabaseAccessToken() async {
  return await getSharedPrefHelper('supabase_access_token');
}
```

---

## Priority 4: Update API Service Layer

### Step 4.1: Update Repositories
Replace all repository files to use `SupabaseApiServices` instead of `NetworkApiServices`.

**Example - Consumer Profile Repository**:
```dart
// OLD
final response = await NetworkApiServices().getApi(
  ApiConstants.authEndPoints.consumerProfile,
  headersData: {'Authorization': 'Bearer $token'},
);

// NEW
final response = await SupabaseApiServices().getProfile();
```

### Step 4.2: Update All Controllers
Go through each controller and replace API calls:

**Files to update**:
- `lib/app/modules/consumer_profile/controller/consumer_profile_controller.dart`
- `lib/app/modules/provider_profile/controller/provider_profile_controller.dart`
- `lib/app/modules/bookings/controller/booking_controller.dart`
- `lib/app/modules/provider_bookings/controller/provider_bookings_controller.dart`
- `lib/app/modules/banners/controller/banner_controller.dart`
- `lib/app/modules/favourite_providers/controller/favourite_provider_controller.dart`
- `lib/app/modules/wallet/controller/wallet_controller.dart`
- And all other controllers that make API calls

### Step 4.3: Update API Endpoints File
**File**: `lib/utils/apiEndPoints/apiEndPoints.dart`

You can keep this file for Edge Function endpoints, but remove Laravel URLs:
```dart
class ApiConstants {
  // Remove: static const String BASE_URL = 'https://api.ustahub.net/api/';
  
  // Keep Edge Function names
  static const String otpAuthFunction = 'otp-auth';
  static const String fcmTokenFunction = 'fcm-token';
  static const String bookingWorkflowFunction = 'booking-workflow';
  static const String walletFunction = 'wallet';
}
```

---

## Priority 5: Update File Uploads

### Step 5.1: Update Upload File Component
**File**: `lib/app/modules/upload_file/upload_file.dart`

Replace multipart upload with Supabase Storage:
```dart
// OLD: Multipart upload to Laravel
final response = await NetworkApiServices().uploadMultipart(
  url,
  fields,
  files,
  headers: {'Authorization': 'Bearer $token'},
);

// NEW: Supabase Storage
final supabase = SupabaseClientService.instance;
final file = File(imagePath);
final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

// Upload to Supabase Storage
await supabase.storage
  .from('avatars') // or 'documents', 'banners', etc.
  .upload(fileName, file);

// Get public URL
final publicUrl = supabase.storage
  .from('avatars')
  .getPublicUrl(fileName);
```

### Step 5.2: Update All Image Upload Points
Find all places where images are uploaded and update them:
- Profile picture uploads
- Document uploads (provider KYC)
- Banner uploads (admin)
- Service image uploads

---

## Priority 6: Update FCM Service

### Step 6.1: Update FCM Token Storage
**File**: `lib/app/modules/fcm/service/fcm_service.dart`

Replace Laravel API call:
```dart
// OLD
final response = await NetworkApiServices().postApi(
  {'fcm_token': token},
  ApiConstants.authEndPoints.storeFcmToken,
  headersData: {'Authorization': 'Bearer $token'},
);

// NEW
final response = await SupabaseApiServices().storeFcmToken(token);
```

---

## Priority 7: Test Everything

### Step 7.1: Test Authentication
- [ ] Send OTP
- [ ] Verify OTP
- [ ] Create user session
- [ ] Logout
- [ ] Session persistence

### Step 7.2: Test CRUD Operations
- [ ] Create profile
- [ ] Update profile
- [ ] Add address
- [ ] Create booking
- [ ] View bookings
- [ ] Add favorite
- [ ] Rate provider

### Step 7.3: Test File Uploads
- [ ] Upload profile picture
- [ ] Upload document
- [ ] View uploaded files

### Step 7.4: Test Edge Functions
- [ ] OTP send/verify
- [ ] FCM token storage
- [ ] Booking workflow (accept/reject/start/complete)
- [ ] Wallet operations

---

## Priority 8: Data Migration (If Needed)

### Step 8.1: Export Laravel Data
Export data from your Laravel database:
```bash
# Export users, bookings, etc. to CSV/JSON
```

### Step 8.2: Transform Data
Transform data to match Supabase schema:
- Map Laravel user IDs to Supabase auth.users
- Update foreign key references
- Convert data formats if needed

### Step 8.3: Import to Supabase
Use Supabase Dashboard SQL Editor or create a migration script to import data.

---

## Priority 9: Set Edge Function Secrets (Optional)

If you want to send emails via SMTP:

```bash
cd /Users/asadkathia/Desktop/Ustahub-1/Ustahub
supabase secrets set SMTP_HOST=smtp.sendgrid.net
supabase secrets set SMTP_PORT=587
supabase secrets set SMTP_USER=apikey
supabase secrets set SMTP_PASS=your-sendgrid-api-key
supabase secrets set SMTP_FROM_EMAIL=noreply@ustahub.net
supabase secrets set SMTP_FROM_NAME=Ustahub
```

---

## Priority 10: Cleanup

### Step 10.1: Remove Laravel Dependencies
Once everything is working:
- Remove Laravel API base URL references
- Update documentation
- Archive old Laravel codebase

### Step 10.2: Update Documentation
- Update API documentation
- Update setup instructions
- Update deployment guides

---

## Quick Reference

### Supabase Dashboard Links
- **Project**: https://supabase.com/dashboard/project/pyezhaebfvitqkpsjsil
- **API Settings**: https://supabase.com/dashboard/project/pyezhaebfvitqkpsjsil/settings/api
- **Database**: https://supabase.com/dashboard/project/pyezhaebfvitqkpsjsil/editor
- **Storage**: https://supabase.com/dashboard/project/pyezhaebfvitqkpsjsil/storage/buckets
- **Edge Functions**: https://supabase.com/dashboard/project/pyezhaebfvitqkpsjsil/functions
- **SQL Editor**: https://supabase.com/dashboard/project/pyezhaebfvitqkpsjsil/sql/new

### Important Files to Update
1. `lib/main.dart` - Supabase initialization
2. `lib/app/modules/Auth/login/controller/login_controller.dart`
3. `lib/app/modules/Auth/OTP/controller/otp_controller.dart`
4. `lib/app/modules/upload_file/upload_file.dart`
5. `lib/app/modules/fcm/service/fcm_service.dart`
6. All repository files in `lib/app/modules/*/repository/`
7. All controller files that make API calls

---

## Estimated Time

- **Priority 1-2** (Configuration): 15-30 minutes
- **Priority 3** (Authentication): 1-2 hours
- **Priority 4** (API Updates): 2-4 hours
- **Priority 5** (File Uploads): 1 hour
- **Priority 6** (FCM): 30 minutes
- **Priority 7** (Testing): 2-3 hours
- **Priority 8** (Data Migration): 1-2 hours (if needed)

**Total**: ~8-12 hours of development work

---

## Need Help?

- Check `SUPABASE_MIGRATION_PLAN.md` for detailed architecture
- Check `supabase/README.md` for Supabase setup guide
- Check `DEPLOYMENT_SUCCESS.md` for what's already done
- Supabase Docs: https://supabase.com/docs

