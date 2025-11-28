import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/account/repository/account_respository.dart';
import 'package:ustahub/components/custom_toast.dart';

class DeleteAccountController extends GetxController {
  final AccountRespository _repository = AccountRespository();
  RxBool isLoading = false.obs;

  Future<void> deleteAccount() async {
    isLoading.value = true;
    try {
      final response = await _repository.deleteAccount();

      if(kDebugMode){
        print('Delete account response: $response');
      }

      if (response['statusCode'] == 200 && response['body']['status'] == true) {
        CustomToast.success('Account deleted successfully');


        // Clear all stored data
        await Sharedprefhelper.clearSharedPreferences();

        // Get user role for navigation
        String? role = await Sharedprefhelper.getRole() ?? 'consumer';

        // Navigate to login screen
        Get.offAll(() => OnboardingView());
      } else {
        CustomToast.error(response['body']['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
      print('Delete account error: $e');
      CustomToast.error('Failed to delete account. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
