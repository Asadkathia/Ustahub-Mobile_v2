//

import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_profile_setup/repository/provider_profile_setup_repository.dart';

class ProviderProfileSetupController extends GetxController {
  final Rx<File?> pickedImage = Rx<File?>(null); // Profile image
  final Rx<File?> passportFile = Rx<File?>(null);
  final Rx<File?> nicFile = Rx<File?>(null);
  final Rx<File?> ticFile = Rx<File?>(null);

  final RxString pickedImageUrl = ''.obs;
  final RxString passportFileUrl = ''.obs;
  final RxString nicFileUrl = ''.obs;
  final RxString ticFileUrl = ''.obs;
  final RxString profileImageUrl = ''.obs;

  final nameController = TextEditingController();

  final UploadFile uploadFileController = Get.put(UploadFile());

  Future<void> pickImageFor(Rx<File?> target, String type) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final File selectedFile = File(image.path);
      target.value = selectedFile;

      final UploadFile uploader = Get.put(UploadFile());
      final String? uploadedUrl = await uploader.uploadFile(
        file: selectedFile,
        type: type,
      );

      if (uploadedUrl != null) {
        switch (type) {
          case 'profile':
            pickedImageUrl.value = uploadedUrl;
            break;
          case 'passport':
            passportFileUrl.value = uploadedUrl;
            break;
          case 'nic':
            nicFileUrl.value = uploadedUrl;
            break;
          case 'tic':
            ticFileUrl.value = uploadedUrl;
            break;
        }
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      pickedImage.value = File(image.path);
      final UploadFile uploader = Get.put(UploadFile());
      final String? uploadedUrl = await uploader.uploadFile(
        file: pickedImage.value!,
        type: 'profile',
      );
      if (uploadedUrl != null) {
        profileImageUrl.value = uploadedUrl;
        print("Profile image uploaded: $profileImageUrl");
      }
    }
  }

  final _api = ProviderProfileSetupRepository();
  final SupabaseApiServices _supabaseApi = SupabaseApiServices();

  RxBool isLoading = false.obs;

  void setupProfile() async {
    isLoading.value = true;
    final profileData = <String, dynamic>{
      "name": nameController.text,
      if (profileImageUrl.value.isNotEmpty) "avatar": profileImageUrl.value,
    };

    final documents = <Map<String, dynamic>>[
      if (passportFileUrl.value.isNotEmpty)
        {
          "document_type": "PASSPORT",
          "document_image": passportFileUrl.value,
        },
      if (nicFileUrl.value.isNotEmpty)
        {"document_type": "NIC", "document_image": nicFileUrl.value},
      if (ticFileUrl.value.isNotEmpty)
        {"document_type": "TIC", "document_image": ticFileUrl.value},
    ];

    try {
      final response = await _api.setupProfile(data: profileData);

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        if (documents.isNotEmpty) {
          final docResponse =
              await _supabaseApi.upsertProviderDocuments(documents);
          if (docResponse['statusCode'] != 200 &&
              docResponse['statusCode'] != 201) {
            CustomToast.error(
              docResponse['body']['message'] ?? 'Failed to upload documents',
            );
            isLoading.value = false;
            return;
          }
        }

        CustomToast.success("Profile setup successfully");
        Get.offAll(() => ProviderAddressSetupView(
              role: "provider",
            ));
      } else {
        CustomToast.error(
          response['body']['message'] ?? "Failed to setup profile",
        );
      }
    } catch (e) {
      CustomToast.error("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
