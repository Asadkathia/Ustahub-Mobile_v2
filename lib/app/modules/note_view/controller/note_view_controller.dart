import 'package:ustahub/app/export/exports.dart';

class NoteViewController extends GetxController {
  final TextEditingController noteController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Observable list for selected images
  RxList<File> selectedImages = <File>[].obs;

  // Loading state
  RxBool isLoading = false.obs;

  // Booking ID (to be set when opening the modal)
  RxString bookingId = ''.obs;

  // Tag for finding the NotesController
  String? notesControllerTag;

  @override
  void onClose() {
    super.onClose();
    noteController.clear();
    selectedImages.clear();
  }

  // Method to pick multiple images from gallery
  Future<void> pickImagesFromGallery() async {
    try {
      isLoading.value = true;
      final List<XFile> images = await _picker.pickMultiImage(limit: 5);

      for (XFile image in images) {
        selectedImages.add(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick images',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method to pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      isLoading.value = true;
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        selectedImages.add(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method to show image source selection dialog
  void showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Select Image Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                pickImagesFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  // Method to remove image from list
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  // Method to clear all data
  void clearAll() {
    noteController.clear();
    selectedImages.clear();
  }

  // Method to save note with API call and refresh notes list
  Future<void> saveNote() async {
    if (noteController.text.trim().isEmpty) {
      CustomToast.error("Note cannot be empty");
      return;
    }

    if (bookingId.value.isEmpty) {
      CustomToast.error("Booking ID not found");
      return;
    }

    try {
      isLoading.value = true;

      // Get the NotesController with the correct tag
      final NotesController notesController;
      if (notesControllerTag != null) {
        notesController = Get.find<NotesController>(tag: notesControllerTag);
      } else {
        notesController = Get.find<NotesController>();
      }

      // Use the NotesController's addNoteAndRefresh method to add note and refresh list
      await notesController.addNoteAndRefresh(
        bookingId: bookingId.value,
        note: noteController.text.trim(),
        images: selectedImages,
      );

      // Clear form and close modal
      clearAll();
      Get.back(); // Close the modal
    } catch (e) {
      // Error handling is done in NotesController
      print('Error in saveNote: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to set booking ID
  void setBookingId(String id) {
    bookingId.value = id;
  }

  // Method to set notes controller tag
  void setNotesControllerTag(String tag) {
    notesControllerTag = tag;
  }
}
