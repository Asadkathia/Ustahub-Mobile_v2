# Push Notifications Setup Guide

This guide explains how to set up push notifications for messages and booking status updates.

## Overview

The notification system uses:
- **Firebase Cloud Messaging (FCM)** for sending push notifications
- **Supabase Edge Functions** to handle notification logic
- **FCM tokens** stored in the `fcm_tokens` table

## Notification Types

### 1. Booking Notifications
- **New Booking Request**: Sent to provider when consumer creates a booking
- **Booking Accepted**: Sent to consumer when provider accepts booking
- **Booking Rejected**: Sent to consumer when provider rejects booking
- **On My Way**: Sent to consumer when provider taps "On My Way"
- **Work Started**: Sent to consumer when provider starts work
- **Work Completed**: Sent to consumer when provider completes work
- **Booking Cancelled**: Sent to provider when consumer cancels booking

### 2. Message Notifications
- **New Message**: Sent to recipient when a new message is sent in a booking chat

## Setup Steps

### 1. Get Firebase Server Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (gear icon)
4. Click on **Cloud Messaging** tab
5. Under **Cloud Messaging API (Legacy)**, copy the **Server key**
   - Note: If you don't see the legacy API, you may need to enable it or use the newer API with service account

### 2. Set Environment Variable in Supabase

1. Go to your Supabase project dashboard
2. Navigate to **Project Settings** > **Edge Functions** > **Secrets**
3. Add a new secret:
   - **Name**: `FIREBASE_SERVER_KEY`
   - **Value**: Your Firebase Server Key from step 1

### 3. Deploy Edge Functions

Deploy the notification-related Edge Functions:

```bash
# Deploy send-notification function
supabase functions deploy send-notification

# Deploy send-message function (handles messages + notifications)
supabase functions deploy send-message

# Update existing functions
supabase functions deploy booking-actions
supabase functions deploy booking-create
```

### 4. Verify FCM Token Storage

The app automatically stores FCM tokens when:
- User logs in
- App starts and user is authenticated
- FCM token is refreshed

Tokens are stored via the `fcm-token` Edge Function.

## How It Works

### Booking Notifications Flow

1. **Provider Action** (e.g., "Start Work"):
   - User taps button in app
   - App calls `booking-actions` Edge Function
   - Edge Function updates booking status
   - Edge Function calls `send-notification` to notify consumer
   - Consumer receives push notification

2. **New Booking**:
   - Consumer creates booking
   - `booking-create` Edge Function creates booking
   - Edge Function calls `send-notification` to notify provider
   - Provider receives push notification

### Message Notifications Flow

1. **User Sends Message**:
   - User types message and taps send
   - App calls `send-message` Edge Function
   - Edge Function inserts message into database
   - Edge Function determines recipient (other participant)
   - Edge Function calls `send-notification` to notify recipient
   - Recipient receives push notification

## Testing

### Test Booking Notifications

1. Create a booking as a consumer
2. Check provider's device for "New Booking Request" notification
3. As provider, accept the booking
4. Check consumer's device for "Booking Accepted" notification
5. As provider, tap "On My Way"
6. Check consumer's device for "Provider is on the way" notification
7. As provider, start work
8. Check consumer's device for "Work Started" notification
9. As provider, complete work
10. Check consumer's device for "Work Completed" notification

### Test Message Notifications

1. Open a booking chat
2. Send a message
3. Check the other user's device for "New Message" notification

## Troubleshooting

### Notifications Not Received

1. **Check FCM Token Storage**:
   - Verify token is stored in `fcm_tokens` table
   - Check app logs for FCM token initialization

2. **Check Firebase Server Key**:
   - Verify `FIREBASE_SERVER_KEY` is set in Supabase Edge Function secrets
   - Ensure the key is from the correct Firebase project

3. **Check Device Permissions**:
   - Ensure notification permissions are granted
   - Check device notification settings

4. **Check Edge Function Logs**:
   - Go to Supabase Dashboard > Edge Functions > Logs
   - Look for errors in `send-notification` function

### Common Issues

- **"No FCM tokens found"**: User hasn't logged in or FCM token wasn't stored
- **"Firebase Server Key not configured"**: Missing `FIREBASE_SERVER_KEY` environment variable
- **Notifications work on one device but not another**: Check if FCM token is stored for that user/device

## Edge Functions

### send-notification
- **Purpose**: Sends push notification to a user's devices
- **Input**: `userId`, `title`, `body`, `data` (optional)
- **Uses**: Firebase Server Key (legacy FCM API)

### send-message
- **Purpose**: Sends a chat message and notifies recipient
- **Input**: `booking_id`, `text`
- **Output**: Message object
- **Side Effect**: Sends notification to recipient

### booking-actions (updated)
- **Purpose**: Handles booking status changes
- **Side Effect**: Sends notifications for status changes (accept, reject, start, complete, on-my-way)

### booking-create (updated)
- **Purpose**: Creates new bookings
- **Side Effect**: Sends notification to provider about new booking request

## Database Schema

### fcm_tokens Table
```sql
CREATE TABLE public.fcm_tokens (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    token TEXT NOT NULL,
    device_type TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    UNIQUE(user_id, token)
);
```

## Future Enhancements

- Add notification preferences (users can opt-out of certain notification types)
- Add notification history/logs
- Support for notification categories and actions
- Rich notifications with images
- Notification badges and counts


