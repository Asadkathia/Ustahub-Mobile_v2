# Google Authentication Setup Guide

This guide explains how to set up Google OAuth authentication using Supabase's built-in Google provider.

## Overview

The app now supports Google sign-in alongside the existing OTP-based email authentication. When users sign in with Google:

1. They authenticate via Google OAuth
2. The app creates/updates their profile with the selected role (consumer/provider)
3. They're navigated to the appropriate screen (profile setup for new users, home for existing users)

## Prerequisites

- Supabase project with Google OAuth configured
- Google Cloud Console project with OAuth 2.0 credentials
- Flutter app configured with proper redirect URLs

## Step 1: Configure Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create a new one)
3. Navigate to **APIs & Services** > **Credentials**
4. Click **Create Credentials** > **OAuth client ID**
5. Configure OAuth consent screen if prompted:
   - User Type: External (or Internal if using Google Workspace)
   - App name: Ustahub
   - Support email: Your email
   - Scopes: `email`, `profile`, `openid`
   - Test users: Add test emails if needed
6. Create OAuth client ID:
   - Application type: **Web application**
   - Name: Ustahub Web Client
   - Authorized redirect URIs: 
     - `https://YOUR_SUPABASE_PROJECT_REF.supabase.co/auth/v1/callback`
     - Add your Supabase project's callback URL
   - Click **Create**
7. Copy the **Client ID** and **Client Secret**

## Step 2: Configure Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to **Authentication** > **Providers**
3. Find **Google** in the list and click to configure
4. Enable Google provider
5. Enter your Google OAuth credentials:
   - **Client ID (for OAuth)**: Paste the Client ID from Google Cloud Console
   - **Client Secret (for OAuth)**: Paste the Client Secret from Google Cloud Console
6. Click **Save**

## Step 3: Configure Redirect URLs

1. In Supabase dashboard, go to **Authentication** > **URL Configuration**
2. Add your app's redirect URL to **Redirect URLs**:
   - For iOS: `io.supabase.ustahub://login-callback/`
   - For Android: `io.supabase.ustahub://login-callback/`
   - For web: `http://localhost:3000/auth/callback` (or your web URL)
3. Click **Save**

## Step 4: Configure iOS (Info.plist)

1. Open `ios/Runner/Info.plist`
2. Add URL scheme for deep linking:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>io.supabase.ustahub</string>
    </array>
  </dict>
</array>
```

## Step 5: Configure Android (AndroidManifest.xml)

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add intent filter to your main activity:

```xml
<activity
    android:name=".MainActivity"
    ...>
    <!-- Existing intent filters -->
    
    <!-- Add this for OAuth callback -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="io.supabase.ustahub"
            android:host="login-callback" />
    </intent-filter>
</activity>
```

## Step 6: Deploy Edge Function

Deploy the `google-auth-handler` Edge Function:

```bash
cd /Users/asadkathia/Desktop/Ustahub-1/Ustahub
supabase functions deploy google-auth-handler --project-ref YOUR_PROJECT_REF
```

Replace `YOUR_PROJECT_REF` with your actual Supabase project reference.

## Step 7: Test the Integration

1. Build and run the app
2. Navigate to the login screen
3. Select a role (consumer or provider)
4. Click "Sign in with Google"
5. Complete the Google OAuth flow
6. Verify that:
   - New users are directed to profile setup
   - Existing users are directed to the home screen
   - User profile is created/updated with the correct role

## Troubleshooting

### "Redirect URI mismatch" error

- Ensure the redirect URL in Google Cloud Console matches exactly with Supabase's callback URL
- Check that the app's redirect URL (`io.supabase.ustahub://login-callback/`) is added in Supabase dashboard

### "Invalid client" error

- Verify that Client ID and Client Secret are correctly entered in Supabase dashboard
- Ensure the OAuth consent screen is properly configured in Google Cloud Console

### Session not created after OAuth

- Check that the redirect URL is properly configured in iOS/Android
- Verify that the app can handle deep links
- Check Supabase logs for any errors

### Profile not created

- Check Edge Function logs: `supabase functions logs google-auth-handler`
- Verify that the `user_profiles` table exists and has the correct schema
- Ensure the Edge Function has proper permissions (uses service role key)

## Architecture

### Flow Diagram

```
User clicks "Sign in with Google"
    ↓
LoginController.signInWithGoogle()
    ↓
Supabase OAuth flow (browser/webview)
    ↓
Google authentication
    ↓
OAuth callback → App deep link
    ↓
Session created automatically by Supabase SDK
    ↓
LoginController.handleGoogleAuthCallback()
    ↓
google-auth-handler Edge Function
    ↓
Create/update profile with role
    ↓
Navigate to appropriate screen
```

### Key Components

1. **LoginController** (`lib/app/modules/Auth/login/controller/login_controller.dart`)
   - Initiates Google OAuth flow
   - Handles post-auth profile setup
   - Manages navigation based on user state

2. **google-auth-handler Edge Function** (`supabase/functions/google-auth-handler/index.ts`)
   - Creates user profile if new user
   - Updates role if existing user
   - Creates provider record if role is provider

3. **Login View** (`lib/app/modules/Auth/login/view/login_view.dart`)
   - Displays Google sign-in button
   - Shows loading state during authentication

## Security Notes

- Never commit OAuth credentials to version control
- Use environment variables for sensitive configuration
- Regularly rotate OAuth client secrets
- Monitor Supabase logs for suspicious activity
- Implement rate limiting for authentication endpoints

## Additional Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)

