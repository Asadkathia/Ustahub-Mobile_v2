import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/ui_v2/navigation/app_router_v2.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class EditProfileController extends GetxController {
  Future<void> editProfile() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final avatar =
        pickedImageURL.value.isNotEmpty
            ? pickedImageURL.value
            : profileImageUrl.value;

    try {
      String? token = await Sharedprefhelper.getToken();
      String? role = await Sharedprefhelper.getRole();

      final _api = SupabaseApiServices();
      print("👤 Consumer edit payload: name=$name, avatar=$avatar");
      
      final response = await _api.updateProfile({
        "name": name, 
        "phone": phone, 
        "avatar": avatar,
        "bio": bioController.text.trim(),
      });
      
      print("👤 Consumer edit response: $response");
      
      if (response['body']['status'] == true) {
        // Refresh profile before navigating
        try {
          await Get.find<ConsumerProfileController>().fetchProfile();
        } catch (_) {}
        
        CustomToast.success("Profile updated successfully");
        AppRouterV2.offNavBar(role: role ?? 'consumer');
      } else {
        CustomToast.error(
          response['body']['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  RxString profileImageUrl = ''.obs;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();
  Rx<File?> pickedImage = Rx<File?>(null);
  RxBool isUploadingImage = false.obs;
  final pickedImageURL = "".obs;

  Future<void> pickImage() async {
    // Prevent multiple simultaneous picks
    if (isUploadingImage.value) {
      return;
    }
    
    try {
      // Pick image - this will show the system picker which handles its own UI
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress image to reduce upload time
        maxWidth: 1024, // Limit image size to reduce processing time
        maxHeight: 1024,
      );
      
      if (picked != null) {
        // Set picked image immediately for UI feedback
        pickedImage.value = File(picked.path);
        
        // Upload in background without blocking UI
        // Use unawaited to prevent blocking the return
        _uploadImageInBackground(File(picked.path));
      }
    } catch (e) {
      print('[PICK_IMAGE] Exception: $e');
      Get.snackbar("Error", "Failed to pick image: ${e.toString()}");
      pickedImage.value = null;
      pickedImageURL.value = "";
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
        pickedImageURL.value = uploadedUrl;
        profileImageUrl.value = uploadedUrl; // Also update profileImageUrl
        print('[PICK_IMAGE] ✅ Upload successful: $uploadedUrl');
        
        // Auto-save avatar to profile immediately after upload
        await _saveAvatarToProfile(uploadedUrl);
      } else {
        // Reset picked image if upload failed
        pickedImage.value = null;
        pickedImageURL.value = "";
        Get.snackbar("Error", "Failed to upload image");
      }
    } catch (e) {
      print('[PICK_IMAGE] ❌ Upload error: $e');
      Get.snackbar("Error", "Failed to upload image: ${e.toString()}");
      pickedImage.value = null;
      pickedImageURL.value = "";
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> _saveAvatarToProfile(String avatarUrl) async {
    try {
      final _api = SupabaseApiServices();
      print('[PICK_IMAGE] 💾 Auto-saving avatar to profile: $avatarUrl');
      
      final response = await _api.updateProfile({
        "avatar": avatarUrl,
      });
      
      if (response['statusCode'] == 200 && response['body']['status'] == true) {
        print('[PICK_IMAGE] ✅ Avatar saved to profile successfully');
        
        // Refresh profile to update UI
        try {
          await Get.find<ConsumerProfileController>().fetchProfile();
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
  // void saveChanges() {
  //   // Handle profile update
  //   Get.snackbar("Success", "Profile updated");
  // }
}
