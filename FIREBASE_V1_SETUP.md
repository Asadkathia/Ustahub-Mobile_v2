# Firebase V1 API Setup Guide

Since the Legacy API is not available, we need to use the V1 API with service account authentication.

## Step 1: Create Service Account in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **ustahub-92de1**
3. Click the **gear icon** → **Project settings**
4. Go to the **Service accounts** tab
5. Click **Generate new private key**
6. A JSON file will download - **keep this file secure!**

## Step 2: Extract Values from Service Account JSON

Open the downloaded JSON file. It will look like this:

```json
{
  "type": "service_account",
  "project_id": "ustahub-92de1",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@ustahub-92de1.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  ...
}
```

You need these 3 values:
- **`project_id`** → This is your `FIREBASE_PROJECT_ID`
- **`private_key`** → This is your `FIREBASE_PRIVATE_KEY` (keep the entire key including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`)
- **`client_email`** → This is your `FIREBASE_CLIENT_EMAIL`

## Step 3: Set Secrets in Supabase

1. Go to your [Supabase Dashboard](https://supabase.com/dashboard/project/pyezhaebfvitqkpsjsil)
2. Navigate to **Project Settings** → **Edge Functions** → **Secrets**
3. Add these 3 secrets:

   **Secret 1:**
   - **Name**: `FIREBASE_PROJECT_ID`
   - **Value**: `ustahub-92de1` (or the project_id from your JSON)

   **Secret 2:**
   - **Name**: `FIREBASE_PRIVATE_KEY`
   - **Value**: The entire `private_key` value from JSON (including BEGIN/END lines)
     - Example: `-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n`

   **Secret 3:**
   - **Name**: `FIREBASE_CLIENT_EMAIL`
   - **Value**: The `client_email` from JSON
     - Example: `firebase-adminsdk-xxxxx@ustahub-92de1.iam.gserviceaccount.com`

## Step 4: Redeploy Edge Function

After setting the secrets, redeploy the send-notification function:

```bash
supabase functions deploy send-notification
```

## Step 5: Test

1. Make sure FCM tokens are stored (app should do this automatically on login)
2. Create a booking or send a message
3. Check if notifications are received

## Troubleshooting

### "Failed to get access token"
- Check that `FIREBASE_PRIVATE_KEY` includes the full key with BEGIN/END lines
- Verify `FIREBASE_CLIENT_EMAIL` is correct
- Ensure the service account has proper permissions

### "No FCM tokens found"
- User needs to log in to the app
- Check `fcm_tokens` table in Supabase database
- Verify FCM token is being stored on app startup

### "Invalid credentials"
- Double-check all 3 secrets are set correctly
- Make sure private key is not corrupted (copy entire key including newlines)

## Security Note

⚠️ **Never commit the service account JSON file to git!**
- The service account has admin access to your Firebase project
- Keep it secure and only use it in Supabase Edge Function secrets


