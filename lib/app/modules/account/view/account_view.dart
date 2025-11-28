import 'package:url_launcher/url_launcher.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/account/controller/account_controller.dart';
import 'package:ustahub/app/modules/account/controller/delete_account_controller.dart';
import 'package:ustahub/app/modules/consumer_profile/controller/consumer_profile_controller.dart';
import 'package:ustahub/app/modules/my_service/view/my_service_view.dart';
import 'package:ustahub/app/modules/provider_document/view/provider_document_view.dart';
import 'package:ustahub/app/modules/provider_edit_profile/view/provider_edit_profile_view.dart';
import 'package:ustahub/app/modules/provider_profile/controller/provider_profile_controller.dart';
import 'package:ustahub/app/modules/wallet/view/wallet_view.dart';
import 'package:ustahub/components/confirm_dialog.dart';

class AccountView extends StatefulWidget {
  final String role;
  const AccountView({super.key, required this.role});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  late ConsumerProfileController profileController;
  late ProviderProfileController providerProfileController;

  @override
  void initState() {
    super.initState();
    profileController = Get.put(ConsumerProfileController());
    providerProfileController = Get.put(ProviderProfileController());
    
    // Fetch profile based on role
    if (widget.role == "consumer") {
      profileController.fetchProfile();
    } else {
      providerProfileController.fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.profile,
                style: GoogleFonts.ubuntu(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              15.ph,
              // Profile section based on role - each method handles its own Obx
              _buildProfileSection(
                profileController,
                providerProfileController,
              ),
              20.ph,
              widget.role == "consumer" ? SettingsMenu() : SettingsMenuForProvider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    ConsumerProfileController consumerController,
    ProviderProfileController providerController,
  ) {
    if (widget.role == "consumer") {
      return _buildConsumerProfile(consumerController);
    } else {
      return _buildProviderProfile(providerController);
    }
  }

  Widget _buildConsumerProfile(ConsumerProfileController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      final user = controller.userProfile.value;
      if (user == null) {
        return Center(
          child: Text(
            'Failed to load profile',
            style: GoogleFonts.ubuntu(fontSize: 16.sp, color: AppColors.grey),
          ),
        );
      }

      return _buildProfileRow(
        user: user,
        onEditTap: () => Get.to(() => EditProfileView(user: user)),
      );
    });
  }

  Widget _buildProviderProfile(ProviderProfileController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      final user = controller.userProfile.value;
      if (user == null) {
        return Center(
          child: Text(
            'Failed to load profile',
            style: GoogleFonts.ubuntu(fontSize: 16.sp, color: AppColors.grey),
          ),
        );
      }

      return _buildProfileRow(
        user: user,
        onEditTap: () {
          Get.to(() => ProviderEditProfileView(user: user));
        },
      );
    });
  }

  Widget _buildProfileRow({
    required dynamic user,
    required VoidCallback onEditTap,
  }) {
    // Handle different avatar field names
    final String avatarUrl =
        (user.avatar != null && user.avatar!.isNotEmpty) ? user.avatar! : '';
    final String displayName = user.name ?? 'Unknown User';
    final String secondaryText = user.phone ?? user.email ?? '';
    
    print("[ACCOUNT VIEW] Avatar URL: $avatarUrl");
    print("[ACCOUNT VIEW] User avatar field: ${user.avatar}");

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Use CachedNetworkImage instead of CircleAvatar for better reliability
        _buildAvatarWidget(avatarUrl),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                5.ph,
                Text(
                  secondaryText,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: onEditTap,
          child: Container(
            alignment: Alignment.center,
            height: 45.h,
            width: 45.h,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.edit_outlined, color: Colors.white, size: 20.sp),
          ),
        ),
      ],
    );
  }

  // Reusable avatar widget using the existing imageContainerCircle helper
  Widget _buildAvatarWidget(String avatarUrl) {
    return imageContainerCircle(
      image: avatarUrl,
      height: 80.r,
      width: 80.r,
    );
  }
}

class SettingsMenu extends StatelessWidget {
  SettingsMenu({super.key});
  final controller = Get.put(AccountController());
  final deleteController = Get.put(DeleteAccountController());

  @override
  Widget build(BuildContext context) {
    return Card(
      // margin: const EdgeInsets.all(16),
      color: Colors.white,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.h),
        child: Column(
          children: [
            SettingsTile(
              icon: Icons.location_on_outlined,
              title: AppLocalizations.of(context)!.manageAddress,
              onTap: () {
                Get.to(() => ManageAddressView());
              },
            ),
            5.ph,
            SettingsTile(
              icon: Icons.favorite_border,
              title: AppLocalizations.of(context)!.favouriteProviders,
              onTap: () {
                Get.to(() => FavouriteProvidersView());
              },
            ),
            5.ph,

            SettingsTile(
              icon: Icons.language,
              title: AppLocalizations.of(context)!.languge,
              onTap: () {
                Get.to(() => LanguageView());
              },
            ),
            5.ph,

            SettingsTile(
              icon: Icons.star_border,
              title: AppLocalizations.of(context)!.rateUs,
              onTap: ()async {
                if(Platform.isAndroid){
                  await launchUrl(Uri.parse("https://play.google.com/store/apps/details?id=com.brownfish.ustahubb"));

                  
                } else if(Platform.isIOS){
                  // LaunchReview.launch(iOSAppId: "6441851281");
                  await launchUrl(Uri.parse("https://apps.apple.com/in/app/ustahub/id6753018350"));
                  
                }
              },
            ),
            5.ph,
             SettingsTile(
              icon: Icons.delete,
              title: AppLocalizations.of(context)!.deleteAccount,
              onTap: () {
                showConfirmDialog(
                  context: context,
                  title: AppLocalizations.of(context)!.deleteAccount,
                  message: "Are you sure you want to delete your account? This action cannot be undone. All your data, files, bookings, and account information will be permanently deleted.",
                  onConfirm: () {
                    deleteController.deleteAccount();
                  },
                );
              },
            ),
            5.ph,

            SettingsTile(
              icon: Icons.logout,
              title: AppLocalizations.of(context)!.logout,
              onTap: () {
                print("Logout tapped");

                try {
                  showConfirmDialog(
                    context: context,
                    title: AppLocalizations.of(context)!.logout,
                    message: "Are you sure you want to logout?",
                    onConfirm: () {
                      controller.logout();
                    },
                  );
                } catch (e) {
                  print("Error: $e");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.black, size: 24.r),
      title: Text(
        title,
        style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 16.sp),
      ),
      trailing: Icon(Icons.chevron_right, size: 30.r),
      onTap: onTap,
    );
  }
}

// For Provider screen
class SettingsMenuForProvider extends StatelessWidget {
  SettingsMenuForProvider({super.key});
  final controller = Get.put(AccountController());
  final deleteController = Get.put(DeleteAccountController());

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.h),
        child: Column(
          children: [
            SettingsTile(
              icon: Icons.location_on_outlined,
              title: AppLocalizations.of(context)!.manageAddress,
              onTap: () {
                Get.to(() => ManageAddressView());
              },
            ),
            5.ph,
            // SettingsTile(
            //   icon: Icons.video_settings_outlined,
            //   title: AppLocalizations.of(context)!.createPlan,
            //   onTap: () {
            //     // Get.to(() => CreatePlanScreen());
            //     Get.to(() => ServiceSelectionForPlanView());
            //   },
            // ),
            // 5.ph,
            // SettingsTile(
            //   icon: Icons.video_settings_outlined,
            //   title: AppLocalizations.of(context)!.managePlan,
            //   onTap: () {
            //     Get.to(() => ServiceSelectionForPlanView());
            //   },
            // ),
            // 5.ph,
            SettingsTile(
              icon: Icons.settings_input_svideo_sharp,
              title: AppLocalizations.of(context)!.myService,
              onTap: () {
                Get.to(() => MyServiceView());
              },
            ),
            5.ph,
            SettingsTile(
              icon: Icons.edit_document,
              title: AppLocalizations.of(context)!.documents,
              onTap: () {
                Get.to(() => ProviderDocumentView());
              },
            ),
            5.ph,
            SettingsTile(
              icon: Icons.wallet_rounded,
              title: AppLocalizations.of(context)!.wallet,
              onTap: () {
                Get.to(() => WalletView());
              },
            ),
            5.ph,
            SettingsTile(
              icon: Icons.language,
              title: AppLocalizations.of(context)!.languge,
              onTap: () {
                Get.to(() => LanguageView());
              },
            ),
            5.ph,

            SettingsTile(
              icon: Icons.star_border,
              title: AppLocalizations.of(context)!.rateUs,
              onTap: () {
                // Handle rate us tap
              },
            ),
            5.ph,
            SettingsTile(
              icon: Icons.delete,
              title: AppLocalizations.of(context)!.deleteAccount,
              onTap: () {
                showConfirmDialog(
                  context: context,
                  title: AppLocalizations.of(context)!.deleteAccount,
                  message: "Are you sure you want to delete your account? This action cannot be undone. All your data, files, services, bookings, documents, and account information will be permanently deleted.",
                  onConfirm: () {
                    deleteController.deleteAccount();
                  },
                );
              },
            ),
            5.ph,

            SettingsTile(
              icon: Icons.logout,
              title: AppLocalizations.of(context)!.logout,
              onTap: () {
                print("Logout tapped");

                try {
                  showConfirmDialog(
                    context: context,
                    title: AppLocalizations.of(context)!.logout,
                    message: "Are you sure you want to logout?",
                    onConfirm: () {
                      controller.logout();
                    },
                  );
                } catch (e) {
                  print("Error: $e");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
