import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class FcmController extends GetxController {
  final _api = SupabaseApiServices();
  RxBool isLoading = false.obs;

  /// Store FCM token to server using Supabase Edge Function
  Future<bool> storeFcmToken({required String fcmToken}) async {
    try {
      isLoading.value = true;

      // Check if user is authenticated with Supabase
      if (!SupabaseClientService.isAuthenticated) {
        print('[FCM] No Supabase session found');
        return false;
      }

      final response = await _api.storeFcmToken(fcmToken);

      if (response['statusCode'] == 200 && response['body']['success'] == true) {
        print('[FCM] ✅ Token stored successfully');
        return true;
      } else {
        print('[FCM] ❌ Failed to store token: ${response['body']}');
        return false;
      }
    } catch (e) {
      print('[FCM] ❌ Error storing FCM token: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get FCM token and store it to server
  /// Note: You'll need to implement the actual FCM token retrieval based on your Firebase setup
  Future<void> initializeAndStoreFcmToken() async {
    try {
      // TODO: Replace this with actual Firebase messaging token retrieval
      // Example:
      // FirebaseMessaging messaging = FirebaseMessaging.instance;
      // String? token = await messaging.getToken();

      // For now, this is a placeholder method
      String? fcmToken = await _getFcmTokenFromFirebase();

      if (fcmToken != null && fcmToken.isNotEmpty) {
        await storeFcmToken(fcmToken: fcmToken);
      } else {
        print('Failed to get FCM token');
      }
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  /// Get FCM token from Firebase
  Future<String?> _getFcmTokenFromFirebase() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      
      // Request permission for notifications
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        String? token = await messaging.getToken();
        print('[FCM] ✅ Token retrieved from Firebase: ${token?.substring(0, 20)}...');
        return token;
      } else {
        print('[FCM] ⚠️ Notification permission not granted: ${settings.authorizationStatus}');
        return null;
      }
    } catch (e) {
      print('[FCM] ❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Refresh FCM token and store to server
  Future<void> refreshAndStoreFcmToken() async {
    try {
      String? newToken = await _getFcmTokenFromFirebase();

      if (newToken != null && newToken.isNotEmpty) {
        await storeFcmToken(fcmToken: newToken);
      }
    } catch (e) {
      print('Error refreshing FCM token: $e');
    }
  }
}
