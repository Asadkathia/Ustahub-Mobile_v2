import 'package:ustahub/app/export/exports.dart';

class FcmService {
  static FcmController get _fcmController {
    if (Get.isRegistered<FcmController>()) {
      return Get.find<FcmController>();
    } else {
      return Get.put(FcmController());
    }
  }

  /// Initialize FCM and store token to server
  /// Call this method in main.dart or after user login
  static Future<void> initializeFcm() async {
    await _fcmController.initializeAndStoreFcmToken();
  }

  /// Store a specific FCM token to server
  /// Use this if you have the token from Firebase directly
  static Future<bool> storeFcmToken(String fcmToken) async {
    print("Token received in FcmService: $fcmToken");
    print("Storing FCM Token: $fcmToken");
    return await _fcmController.storeFcmToken(fcmToken: fcmToken);
  }

  /// Refresh and store FCM token
  /// Call this when token is refreshed by Firebase
  static Future<void> refreshFcmToken() async {
    await _fcmController.refreshAndStoreFcmToken();
  }
  /// Check if FCM service is currently loading
  static bool get isLoading => _fcmController.isLoading.value;
}
