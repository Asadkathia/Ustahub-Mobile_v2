import 'package:ustahub/app/export/exports.dart';

class NoteViewModal {
  static void show(BuildContext context, {required String bookingId}) {
    print(bookingId);
    // Ensure we create a fresh controller instance
    Get.delete<NoteViewController>();
    final NoteViewController controller = Get.put(NoteViewController());

    // Set the booking ID and tag for finding NotesController
    controller.setBookingId(bookingId);
    controller.setNotesControllerTag('booking_$bookingId');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: EdgeInsets.only(top: 8.h),
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Header
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add Note',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed:
                                      () => controller.showImageSourceDialog(),
                                  icon: Icon(
                                    Icons.camera_alt_outlined,
                                    color: AppColors.green,
                                    size: 24.sp,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    controller.clearAll();
                                    Get.back();
                                  },
                                  icon: Icon(Icons.close, size: 24.sp),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Note TextField
                              buildFormField(
                                controller: controller.noteController,
                                hint: 'Write your note here...',
                                maxLines: 4,
                                minLines: 4,
                                fillColor: AppColors.textFieldFillColor,
                                radius: 12,
                                contentPadding: EdgeInsets.all(16.w),
                              ),

                              SizedBox(height: 16.h),

                              // Images Section
                              Expanded(
                                child: Obx(() {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (controller
                                          .selectedImages
                                          .isNotEmpty) ...[
                                        Text(
                                          'Selected Images (${controller.selectedImages.length})',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        Expanded(
                                          child: GridView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  crossAxisSpacing: 8.w,
                                                  mainAxisSpacing: 8.h,
                                                  childAspectRatio: 1,
                                                ),
                                            itemCount:
                                                controller
                                                    .selectedImages
                                                    .length,
                                            itemBuilder: (context, index) {
                                              return _ImageTile(
                                                image:
                                                    controller
                                                        .selectedImages[index],
                                                onRemove:
                                                    () => controller
                                                        .removeImage(index),
                                              );
                                            },
                                          ),
                                        ),
                                      ] else ...[
                                        Expanded(
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.photo_library_outlined,
                                                  size: 48.sp,
                                                  color: Colors.grey[400],
                                                ),
                                                SizedBox(height: 16.h),
                                                Text(
                                                  'No images selected',
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                SizedBox(height: 8.h),
                                                TextButton.icon(
                                                  onPressed:
                                                      () =>
                                                          controller
                                                              .showImageSourceDialog(),
                                                  icon: const Icon(
                                                    Icons.add_a_photo,
                                                  ),
                                                  label: const Text(
                                                    'Add Photos',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Save Button
                      Container(
                        padding: EdgeInsets.all(16.w),
                        child: SizedBox(
                          width: double.infinity,
                          child: Obx(
                            () => ElevatedButton(
                              onPressed:
                                  controller.isLoading.value
                                      ? null
                                      : () => controller.saveNote(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  controller.isLoading.value
                                      ? SizedBox(
                                        height: 20.h,
                                        width: 20.w,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text(
                                        'Save Note',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    ).whenComplete(() {
      // Clean up controller when modal is closed
      Get.delete<NoteViewController>();
    });
  }
}

class _ImageTile extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _ImageTile({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                image.existsSync()
                    ? Image.file(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error, color: Colors.red),
                        );
                      },
                    )
                    : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.close, color: Colors.white, size: 16.sp),
            ),
          ),
        ),
      ],
    );
  }
}
