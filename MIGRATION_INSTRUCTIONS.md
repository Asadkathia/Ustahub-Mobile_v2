# Manual Migration Instructions

Since the Supabase CLI commands are hanging, here are alternative ways to apply the migrations:

## Option 1: Use Supabase Dashboard SQL Editor

1. Go to your Supabase project: https://supabase.com/dashboard/project/pyezhaebfvitqkpsjsil
2. Navigate to **SQL Editor** in the left sidebar
3. Copy and paste each migration file content in order:
   - `supabase/migrations/20240101000001_initial_schema.sql`
   - `supabase/migrations/20240101000002_rls_policies.sql`
   - `supabase/migrations/20240101000003_database_functions.sql`
   - `supabase/migrations/20240101000004_indexes.sql`
4. Run each migration by clicking "Run" button

## Option 2: Use Supabase CLI with Manual Confirmation

Run these commands in your terminal (you'll need to type 'y' when prompted):

```bash
cd /Users/asadkathia/Desktop/Ustahub-1/Ustahub
supabase db push
# When prompted, type 'y' and press Enter
```

## Option 3: Deploy Edge Functions

After migrations are applied, deploy Edge Functions:

```bash
cd /Users/asadkathia/Desktop/Ustahub-1/Ustahub

# Deploy all functions
supabase functions deploy otp-auth
supabase functions deploy fcm-token
supabase functions deploy booking-workflow
supabase functions deploy wallet
```

Or deploy all at once:
```bash
supabase functions deploy
```

## Option 4: Use psql Directly

If you have the database connection string:

```bash
# Get connection string from Supabase Dashboard > Settings > Database
# Then run:
psql "your-connection-string" -f supabase/migrations/20240101000001_initial_schema.sql
psql "your-connection-string" -f supabase/migrations/20240101000002_rls_policies.sql
psql "your-connection-string" -f supabase/migrations/20240101000003_database_functions.sql
psql "your-connection-string" -f supabase/migrations/20240101000004_indexes.sql
```

## What's Already Done

✅ Project is linked to: `pyezhaebfvitqkpsjsil`
✅ All migration files are created and ready
✅ All Edge Functions are created and ready
✅ Flutter app integration is complete

## Next Steps After Migrations

1. **Create Storage Buckets** in Supabase Dashboard:
   - Go to Storage > Create Bucket
   - Create: `avatars` (public), `documents` (private), `banners` (public), `service-images` (public)

2. **Set Edge Function Secrets**:
   ```bash
   supabase secrets set SMTP_HOST=smtp.sendgrid.net
   supabase secrets set SMTP_PASS=your-api-key
   # Add other email config as needed
   ```

3. **Update Flutter App**:
   - Get Supabase URL and anon key from Dashboard > Settings > API
   - Update `lib/main.dart` with actual values
   - Or use environment variables

4. **Test the Setup**:
   - Test database queries in SQL Editor
   - Test Edge Functions via Dashboard > Edge Functions
   - Test Flutter app connection


