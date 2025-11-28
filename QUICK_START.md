# Quick Start Guide - Apply Migrations

Since the CLI commands are hanging, use the **Supabase Dashboard SQL Editor** method:

## Step 1: Apply Database Migrations

1. Open your Supabase project: https://supabase.com/dashboard/project/pyezhaebfvitqkpsjsil
2. Click on **SQL Editor** in the left sidebar
3. Click **New Query**
4. Open the file `supabase/combined_migration.sql` in this project
5. Copy the entire contents and paste into the SQL Editor
6. Click **Run** (or press Cmd/Ctrl + Enter)
7. Wait for all migrations to complete

## Step 2: Deploy Edge Functions

Run these commands in your terminal (one at a time):

```bash
cd /Users/asadkathia/Desktop/Ustahub-1/Ustahub

# Deploy each function
supabase functions deploy otp-auth
supabase functions deploy fcm-token  
supabase functions deploy booking-workflow
supabase functions deploy wallet
```

If those hang, you can also deploy via the Dashboard:
1. Go to **Edge Functions** in the left sidebar
2. Click **Deploy a new function**
3. Upload each function folder from `supabase/functions/`

## Step 3: Create Storage Buckets

1. Go to **Storage** in the left sidebar
2. Click **New bucket** and create:
   - `avatars` - Public bucket
   - `documents` - Private bucket  
   - `banners` - Public bucket
   - `service-images` - Public bucket

## Step 4: Get API Keys

1. Go to **Settings** > **API**
2. Copy:
   - **Project URL**: `https://pyezhaebfvitqkpsjsil.supabase.co`
   - **anon public** key
   - **service_role** key (keep secret!)

## Step 5: Update Flutter App

Update `lib/main.dart` with your actual Supabase credentials:

```dart
const supabaseUrl = 'https://pyezhaebfvitqkpsjsil.supabase.co';
const supabaseAnonKey = 'your-anon-key-here';
```

## Done! ✅

Your Supabase backend is now set up and ready to use.


