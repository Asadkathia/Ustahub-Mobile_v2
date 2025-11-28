import 'package:ustahub/app/export/exports.dart';
// import 'package:ustahub/app/modules/Homepage/view/homepage.dart';

class ProviderProfileSetupView extends StatelessWidget {
  ProviderProfileSetupView({super.key});

  final controller = ProviderProfileSetupController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 13.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                30.ph,
                Text(
                  AppLocalizations.of(context)!.profileSetup,
                  style: GoogleFonts.ubuntu(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blackText,
                  ),
                ),
                5.ph,
                Text(
                  AppLocalizations.of(context)!.pleaseCarefully,
                  style: GoogleFonts.ubuntu(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey,
                  ),
                ),
                15.ph,
                ProfileSetupImageUploadContainer(controller: controller),
                15.ph,
                titleText(title: AppLocalizations.of(context)!.name),
                5.ph,
                buildFormField(
                  hint: AppLocalizations.of(context)!.enterName,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Name is required";
                    }
                    return null;
                  },
                  controller: controller.nameController,
                ),
                30.ph,
                titleText(title: "Passport"),
                10.ph,
                FileUploadBox(
                  imageFile: controller.passportFile,
                  onTap: () => controller.pickImageFor(controller.passportFile, 'passport'),
                ),
                10.ph,
                LinearProgressIndicator(
                  value: controller.uploadFileController.progress.value,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.green,
                ),
                20.ph,
                titleText(title: "National Identity Card (NIC)"),
                10.ph,
                FileUploadBox(
                  imageFile: controller.nicFile,
                  onTap: () => controller.pickImageFor(controller.nicFile, 'nic'),
                ),
                10.ph,
                LinearProgressIndicator(
                  value: controller.uploadFileController.progress.value,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.green,
                ),
                20.ph,
                titleText(title: "Temporary Identity Card (TIC)",),
                10.ph,
                FileUploadBox(
                  imageFile: controller.ticFile,
                  onTap: () => controller.pickImageFor(controller.ticFile, 'tic'),
                ),
                10.ph,
                LinearProgressIndicator(
                  value: controller.uploadFileController.progress.value,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.green,
                ),
                50.ph,
                Obx(() => controller.isLoading.value
                    ? Center(child: CircularProgressIndicator())
                    : BuildBasicButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (controller.nicFile.value == null) {
                              CustomToast.error(
                                "You must upload your National Identity Card (NIC) to proceed.",
                              );
                            } else {
                              // ✅ All validations passed – proceed with API call or navigation
                             // CustomToast.success("Document uploaded successfully");
                             // controller.uploadFileController.uploadFiles().then((value) {
                              controller.setupProfile();
                              // Get.offAll(() => const HomePage());
                            }
                          }
                        },
                        title: "Submit",
                      )),
                100.ph,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class FileUploadBox extends StatelessWidget {
  final Rx<File?> imageFile;
  final VoidCallback onTap;

  const FileUploadBox({
    super.key,
    required this.imageFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: onTap,
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: Radius.circular(17.r),
            color: AppColors.green.withOpacity(0.3),
            dashPattern: [8, 4],
            strokeWidth: 1.5,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
            ),
            width: double.infinity,
            height: 180,
            alignment: Alignment.center,
            child: imageFile.value == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.file_upload_outlined,
                        color: Colors.green,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Choose file to upload",
                        style: GoogleFonts.ubuntu(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Select PNG, JPG file type",
                        style: GoogleFonts.ubuntu(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(17.r),
                        child: Image.file(
                          imageFile.value!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: InkWell(
                          onTap:onTap ,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Change File',
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
