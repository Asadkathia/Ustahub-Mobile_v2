import 'package:get/get.dart';
import 'package:ustahub/app/modules/provider_profile/model_class/provider_profile_model_class.dart';
import 'package:ustahub/components/custom_toast.dart';
import 'package:ustahub/network/supabase_api_services.dart';
import 'package:ustahub/utils/contstants/constants.dart';
import 'package:ustahub/utils/sharedPrefHelper/sharedPrefHelper.dart';

class ProviderProfileController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<ProviderProfieModelClass?> userProfile = Rx<ProviderProfieModelClass?>(
    null,
  );
  final _api = SupabaseApiServices();

  Future<void> fetchProfile() async {
    print("Provider Profile Called");

    isLoading.value = true;
    try {
      final response = await _api.getProviderProfile();
      print("[PROVIDER PROFILE] Response: $response");
      
      if (response['statusCode'] == 200 &&
          response['body'] != null &&
          response['body']['status'] == true &&
          response['body']['details'] != null) {
        final details = response['body']['details'] as Map<String, dynamic>;
        print("[PROVIDER PROFILE] Details: $details");
        
        try {
          print("[PROVIDER PROFILE] Avatar URL from API: ${details['avatar']}");
          
          userProfile.value = ProviderProfieModelClass.fromJson(details);

          // Store profile data safely
          Sharedprefhelper.setSharedPrefHelper("avatar", details['avatar'] ?? blankProfileImage);
          Sharedprefhelper.setSharedPrefHelper("name", details['name'] ?? "Provider");
          if (details['id'] != null) {
            Sharedprefhelper.setSharedPrefHelper("id", details['id'].toString());
          }
          
          print("[PROVIDER PROFILE] ✅ Profile loaded successfully, Avatar: ${userProfile.value?.avatar}");
        } catch (parseError) {
          print("[PROVIDER PROFILE] ❌ Parse error: $parseError");
          CustomToast.error('Error parsing profile data: $parseError');
        }
      } else {
        final message = response['body']?['message'] ?? 'Failed to fetch profile';
        print("[PROVIDER PROFILE] ❌ API Error: $message");
        CustomToast.error(message);
      }
    } catch (e) {
      print("[PROVIDER PROFILE] ❌ Exception: $e");
      CustomToast.error('Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
