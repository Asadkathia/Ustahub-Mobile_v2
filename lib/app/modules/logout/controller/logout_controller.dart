
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/logout/repository/logout_repository.dart';
import 'package:ustahub/app/ui_v2/config/ui_config.dart';
import 'package:ustahub/app/ui_v2/screens/onboarding/onboarding_screen_v2.dart';

class LogoutController extends GetxController {
  final _api = LogoutRepository();

  RxBool isLoading = false.obs;

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    isLoading.value = true;
    try {
      _api.logout().then((value) {
        if (value['statusCode'] == 200 || value['statusCode'] == 201) {
          // Use new onboarding screen
          if (UIConfig.useNewOnboarding) {
            Get.offAll(() => OnboardingScreenV2());
          } else {
            Get.offAll(() => OnboardingView());
          }
          if(kDebugMode) {
            print("Logout successful: $value");
          }
          prefs.clear();
        } else {
          Get.snackbar(
            'Error',
            'Logout failed: ${value['message']}',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
