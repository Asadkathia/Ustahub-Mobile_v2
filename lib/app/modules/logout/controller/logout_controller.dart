
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/logout/repository/logout_repository.dart';

class LogoutController extends GetxController {
  final _api = LogoutRepository();

  RxBool isLoading = false.obs;

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    isLoading.value = true;
    try {
      _api.logout().then((value) {
        if (value['statusCode'] == 200 || value['statusCode'] == 201) {
          Get.offAll(() => OnboardingView());
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
