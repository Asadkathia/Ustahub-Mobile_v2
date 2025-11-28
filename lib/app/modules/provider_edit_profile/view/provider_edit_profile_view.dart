import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_edit_profile/controller/provider_edit_profile_controller.dart';
import 'package:ustahub/app/modules/provider_profile/model_class/provider_profile_model_class.dart';

class ProviderEditProfileView extends StatelessWidget {
  final ProviderProfieModelClass user;
  final controller = Get.put(ProviderEditProfileController());

  ProviderEditProfileView({super.key, required this.user}) {
    controller.nameController.text = user.name ?? '';
    controller.emailController.text = user.email ?? '';
    controller.phoneController.text = user.phone ?? '';
    controller.bioController.text = user.bio ?? '';
    controller.profileImageUrl.value = user.avatar ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        ),
        leading: BackButton(),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // Profile Picture
              Align(
                alignment: Alignment.center,
                child: Obx(
                  () => Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            controller.pickedImage.value != null
                                ? FileImage(controller.pickedImage.value!)
                                : (controller.profileImageUrl.value.isNotEmpty
                                    ? NetworkImage(
                                      controller.profileImageUrl.value,
                                    )
                                    : const AssetImage(
                                          "assets/images/avatar_placeholder.png",
                                        )
                                        as ImageProvider),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: controller.pickImage,
                          child: CircleAvatar(
                            radius: 14.r,
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.edit,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              30.ph,
              titleText(title: "Full Name"),
              5.ph,

              GreenUnderlineTextField(
                controller: controller.nameController,
                label: "name",
              ),
              10.ph,
              titleText(title: "Bio"),
              5.ph,
              GreenUnderlineTextField(
                controller: controller.bioController,
                label: "Bio/Introduction",
              ),
              titleText(title: "Email"),
              5.ph,
              GreenUnderlineTextField(
                controller: controller.emailController,
                label: "Email",
              ),
              10.ph,
              titleText(title: "Phone"),
              5.ph,
              GreenUnderlineTextField(
                keyboardType: TextInputType.number,
                controller: controller.phoneController,
                label: "phon",
              ),
              10.ph,

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.w),
        child: BuildBasicButton(
          title: AppLocalizations.of(context)!.saveChanges,
          onPressed: controller.editProfile,
        ),
      ),
    );
  }
}
