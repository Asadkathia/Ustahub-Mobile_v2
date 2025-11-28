import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/ui_v2/navigation/app_router_v2.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class ProviderEditProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();
  Rx<File?> pickedImage = Rx<File?>(null);
  RxBool isUploadingImage = false.obs;
  RxString profileImageUrl = ''.obs;

  Future<void> pickImage() async {
    // Prevent multiple simultaneous picks
    if (isUploadingImage.value) {
      return;
    }
    
    try {
      // Pick image - this will show the system picker which handles its own UI
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress image to reduce upload time
        maxWidth: 1024, // Limit image size to reduce processing time
        maxHeight: 1024,
      );
      
      if (pickedFile != null) {
        // Set picked image immediately for UI feedback
        pickedImage.value = File(pickedFile.path);
        
        // Upload in background without blocking UI
        // Use unawaited to prevent blocking the return
        _uploadImageInBackground(File(pickedFile.path));
      }
    } catch (e) {
      print('[PICK_IMAGE] Exception: $e');
      Get.snackbar("Error", "Failed to pick image: ${e.toString()}");
      pickedImage.value = null;
      isUploadingImage.value = false;
    }
  }

  Future<void> _uploadImageInBackground(File file) async {
    isUploadingImage.value = true;
    try {
      // Get or create UploadFile controller
      UploadFile uploader;
      try {
        uploader = Get.find<UploadFile>();
      } catch (e) {
        uploader = Get.put(UploadFile());
      }
      
      final uploadedUrl = await uploader.uploadFile(
        file: file,
        type: "avatar",
      );
      
      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        profileImageUrl.value = uploadedUrl;
        print('[PICK_IMAGE] ✅ Upload successful: $uploadedUrl');
        
        // Auto-save avatar to profile immediately after upload
        await _saveAvatarToProfile(uploadedUrl);
      } else {
        // Reset picked image if upload failed
        pickedImage.value = null;
        Get.snackbar("Error", "Failed to upload image");
      }
    } catch (e) {
      print('[PICK_IMAGE] ❌ Upload error: $e');
      Get.snackbar("Error", "Failed to upload image: ${e.toString()}");
      pickedImage.value = null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> _saveAvatarToProfile(String avatarUrl) async {
    try {
      final _api = SupabaseApiServices();
      print('[PICK_IMAGE] 💾 Auto-saving avatar to profile: $avatarUrl');
      
      final response = await _api.updateProfile({
        "profile_image": avatarUrl, // Provider uses profile_image key
      });
      
      if (response['statusCode'] == 200 && response['body']['status'] == true) {
        print('[PICK_IMAGE] ✅ Avatar saved to profile successfully');
        
        // Refresh profile to update UI
        try {
          await Get.find<ProviderProfileController>().fetchProfile();
        } catch (e) {
          print('[PICK_IMAGE] ⚠️ Could not refresh profile: $e');
        }
      } else {
        print('[PICK_IMAGE] ⚠️ Failed to save avatar: ${response['body']['message']}');
      }
    } catch (e) {
      print('[PICK_IMAGE] ❌ Error saving avatar: $e');
      // Don't show error to user - they can still save manually
    }
  }

  Future<void> editProfile() async {
    print("Editing profile...");
    try {
      String? token = await Sharedprefhelper.getToken();

      // Build request payload
      final data = {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'bio': bioController.text,
      };

      // Only include image when available and use correct key expected by API
      if (profileImageUrl.value.isNotEmpty) {
        data['profile_image'] = profileImageUrl.value; // NOT 'avatar'
      }

      print("👤 Provider edit payload: $data");

      final _api = SupabaseApiServices();
      print("👤 Provider edit payload: $data");
      print("👤 Avatar URL being saved: ${data['profile_image'] ?? data['avatar']}");
      
      final response = await _api.updateProfile(data);
      print("Edit Profile Response: $response");
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        if (response['body']['status'] == true) {
          // Refresh profile before navigating
          try {
            await Get.find<ProviderProfileController>().fetchProfile();
          } catch (_) {}
          
          CustomToast.success("Profile updated successfully");
          AppRouterV2.offNavBar(role: 'provider');
        } else {
          CustomToast.error(response['body']['message'] ?? 'Failed to update profile');
        }
      } else {
        CustomToast.error(response['body']['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print(e);
    }
  }
}
