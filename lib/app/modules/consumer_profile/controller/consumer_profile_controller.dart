import 'package:get/get.dart';
import 'package:ustahub/app/modules/consumer_profile/model/user_profile_model.dart';
import 'package:ustahub/network/supabase_api_services.dart';
import 'package:ustahub/utils/contstants/constants.dart';
import 'package:ustahub/utils/sharedPrefHelper/sharedPrefHelper.dart';

class ConsumerProfileController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);
  final _api = SupabaseApiServices();

  Future<void> fetchProfile() async {
    print("[PROFILE] Consumer Profile Called");
    isLoading.value = true;
    try {
      final response = await _api.getProfile();
      if (response['statusCode'] == 200 && response['body']['data'] != null) {
        final userData = response['body']['data']['user'] ?? response['body']['data'];
        
        print("[PROFILE] Avatar URL from API: ${userData['avatar']}");
        
        Sharedprefhelper.setSharedPrefHelper("avatar", userData['avatar'] ?? blankProfileImage);
        Sharedprefhelper.setSharedPrefHelper("name", userData['name'] ?? "User");
        Sharedprefhelper.setSharedPrefHelper("id", userData['id']?.toString() ?? "");
        
        print("[PROFILE] ✅ Profile fetched: ${userData['name']}, Avatar: ${userData['avatar']}");
        userProfile.value = UserProfileModel.fromJson(userData);
        print("[PROFILE] ✅ Model avatar: ${userProfile.value?.avatar}");
      }
    } catch (e) {
      print("[PROFILE] ❌ Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
