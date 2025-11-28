import 'package:ustahub/app/export/exports.dart';

Future<void> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onConfirm,
  String confirmText = "Confirm",
  String cancelText = "Cancel",
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: GoogleFonts.ubuntu(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.blackText,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.ubuntu(
            fontSize: 14.sp,
            color: AppColors.blackText.withOpacity(0.7),
          ),
        ),
        actionsPadding: EdgeInsets.only(bottom: 10.h, right: 10.w),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              cancelText,
              style: GoogleFonts.ubuntu(
                fontSize: 14.sp,
                color: AppColors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              Get.back(); // close dialog
              onConfirm(); // execute callback
            },
            child: Text(
              confirmText,
              style: GoogleFonts.ubuntu(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}
