# FCM Controller Usage

## Overview
The FCM (Firebase Cloud Messaging) controller handles storing FCM tokens to the server using the API endpoint: `https://ustahub.net/api/store-fcm-token`

## Files Created
1. `lib/app/modules/fcm/controller/fcm_controller.dart` - Main controller
2. `lib/app/modules/fcm/service/fcm_service.dart` - Helper service class
3. Updated `lib/utils/apiEndPoints/apiEndPoints.dart` - Added FCM endpoint

## Usage

### Method 1: Using FcmService (Recommended)
```dart
import 'package:ustahub/app/export/exports.dart';

// Initialize FCM after user login or in main.dart
await FcmService.initializeFcm();

// Store a specific FCM token
bool success = await FcmService.storeFcmToken("your_fcm_token_here");

// Refresh token when Firebase provides a new one
await FcmService.refreshFcmToken();

// Check loading state
bool isLoading = FcmService.isLoading;
```

### Method 2: Using Controller Directly
```dart
// Get or create controller
FcmController fcmController = Get.put(FcmController());

// Store FCM token
bool success = await fcmController.storeFcmToken(
  fcmToken: "your_fcm_token_here"
);

// Check loading state
Obx(() => fcmController.isLoading.value 
  ? CircularProgressIndicator() 
  : YourWidget()
);
```

## Integration with Firebase

To complete the implementation, you need to:

1. **Add Firebase configuration** to your project
2. **Update the `_getFcmTokenFromFirebase()` method** in `fcm_controller.dart`:

```dart
Future<String?> _getFcmTokenFromFirebase() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    // Request permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      return token;
    }
    return null;
  } catch (e) {
    print('Error getting FCM token: $e');
    return null;
  }
}
```

3. **Listen for token refresh**:
```dart
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  FcmService.storeFcmToken(newToken);
});
```

## API Endpoint
- **URL**: `https://ustahub.net/api/store-fcm-token`
- **Method**: POST
- **Headers**: 
  - `Content-Type: application/json`
  - `Authorization: Bearer {token}`
- **Body**: 
  ```json
  {
    "fcm_token": "your_fcm_token"
  }
  ```

## Notes
- The controller automatically handles authentication using stored user tokens
- Loading states are managed reactively using GetX observables
- Error handling is included with console logging
- The service class provides a clean interface for the controller
