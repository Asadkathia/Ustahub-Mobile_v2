import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/account/controller/account_controller.dart';
import 'package:ustahub/app/modules/account/controller/delete_account_controller.dart';
import 'package:ustahub/app/modules/consumer_profile/controller/consumer_profile_controller.dart';
import 'package:ustahub/app/modules/my_service/view/my_service_view.dart';
import 'package:ustahub/app/modules/provider_document/view/provider_document_view.dart';
import 'package:ustahub/app/modules/provider_edit_profile/view/provider_edit_profile_view.dart';
import 'package:ustahub/app/modules/provider_profile/controller/provider_profile_controller.dart';
import 'package:ustahub/components/confirm_dialog.dart';
import '../settings/language_screen_v2.dart';
import '../settings/rate_us_sheet_v2.dart';
import 'favourite_providers_screen_v2.dart';
import 'manage_address_screen_v2.dart';
import 'wallet_screen_v2.dart';
import '../../components/navigation/app_app_bar_v2.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';

class AccountScreenV2 extends StatelessWidget {
  final String role;
  const AccountScreenV2({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final ConsumerProfileController profileController = Get.put(
      ConsumerProfileController(),
    );
    final providerProfileController = Get.put(ProviderProfileController());

    // Fetch profile based on role
    if (role == "consumer") {
      profileController.fetchProfile();
    } else {
      providerProfileController.fetchProfile();
    }

    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: AppLocalizations.of(context)!.profile,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
          child: Column(
            children: [
              SizedBox(height: AppSpacing.lgVertical),
              // Profile section based on role
              _buildProfileSection(
                profileController,
                providerProfileController,
              ),
              SizedBox(height: AppSpacing.lgVertical),
              role == "consumer" 
                ? SettingsMenuV2() 
                : SettingsMenuForProviderV2(),
              SizedBox(height: AppSpacing.xlVertical),
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
    if (role == "consumer") {
      return _buildConsumerProfile(consumerController);
    } else {
      return _buildProviderProfile(providerController);
    }
  }

  Widget _buildConsumerProfile(ConsumerProfileController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: AppColorsV2.primary,
          ),
        );
      }

      final user = controller.userProfile.value;
      if (user == null) {
        return Center(
          child: Text(
            'Failed to load profile',
            style: AppTextStyles.bodyMediumSecondary,
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
        return Center(
          child: CircularProgressIndicator(
            color: AppColorsV2.primary,
          ),
        );
      }

      final user = controller.userProfile.value;
      if (user == null) {
        return Center(
          child: Text(
            'Failed to load profile',
            style: AppTextStyles.bodyMediumSecondary,
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
    String avatarUrl = '';
    if (user.avatar != null && user.avatar!.isNotEmpty) {
      avatarUrl = user.avatar!;
    } else {
      avatarUrl = blankProfileImage;
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColorsV2.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundColor: AppColorsV2.textSecondary.withOpacity(0.2),
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl.isEmpty
                ? Icon(
                    Icons.person,
                    size: 40.r,
                    color: AppColorsV2.textSecondary,
                  )
                : null,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? 'Unknown User',
                    style: AppTextStyles.heading4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xsVertical),
                  Text(
                    user.phone ?? user.email,
                    style: AppTextStyles.bodySmall,
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
                color: AppColorsV2.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: AppColorsV2.textOnPrimary,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsMenuV2 extends StatelessWidget {
  SettingsMenuV2({super.key});
  final controller = Get.put(AccountController());
  final deleteController = Get.put(DeleteAccountController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColorsV2.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.mdVertical),
        child: Column(
          children: [
            SettingsTileV2(
              icon: Icons.location_on_outlined,
              title: AppLocalizations.of(context)!.manageAddress,
              onTap: () => Get.to(() => ManageAddressScreenV2()),
            ),
            SettingsTileV2(
              icon: Icons.favorite_border,
              title: AppLocalizations.of(context)!.favouriteProviders,
              onTap: () => Get.to(() => FavouriteProvidersScreenV2()),
            ),
            SettingsTileV2(
              icon: Icons.language,
              title: AppLocalizations.of(context)!.languge,
              onTap: () => Get.to(() => LanguageScreenV2()),
            ),
            SettingsTileV2(
              icon: Icons.star_border,
              title: AppLocalizations.of(context)!.rateUs,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.radiusXLarge),
                    ),
                  ),
                  builder: (_) => const RateUsSheetV2(),
                );
              },
            ),
            SettingsTileV2(
              icon: Icons.wallet_rounded,
              title: AppLocalizations.of(context)!.wallet,
              onTap: () => Get.to(() => const WalletScreenV2()),
            ),
            SettingsTileV2(
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
            SettingsTileV2(
              icon: Icons.logout,
              title: AppLocalizations.of(context)!.logout,
              onTap: () {
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

class SettingsMenuForProviderV2 extends StatelessWidget {
  SettingsMenuForProviderV2({super.key});
  final controller = Get.put(AccountController());
  final deleteController = Get.put(DeleteAccountController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColorsV2.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.mdVertical),
        child: Column(
          children: [
            SettingsTileV2(
              icon: Icons.location_on_outlined,
              title: AppLocalizations.of(context)!.manageAddress,
              onTap: () => Get.to(() => ManageAddressScreenV2()),
            ),
            SettingsTileV2(
              icon: Icons.settings_input_svideo_sharp,
              title: AppLocalizations.of(context)!.myService,
              onTap: () {
                Get.to(() => MyServiceView());
              },
            ),
            SettingsTileV2(
              icon: Icons.edit_document,
              title: AppLocalizations.of(context)!.documents,
              onTap: () {
                Get.to(() => ProviderDocumentView());
              },
            ),
            SettingsTileV2(
              icon: Icons.wallet_rounded,
              title: AppLocalizations.of(context)!.wallet,
              onTap: () => Get.to(() => const WalletScreenV2()),
            ),
            SettingsTileV2(
              icon: Icons.language,
              title: AppLocalizations.of(context)!.languge,
              onTap: () => Get.to(() => LanguageScreenV2()),
            ),
            SettingsTileV2(
              icon: Icons.star_border,
              title: AppLocalizations.of(context)!.rateUs,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.radiusXLarge),
                    ),
                  ),
                  builder: (_) => const RateUsSheetV2(),
                );
              },
            ),
            SettingsTileV2(
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
            SettingsTileV2(
              icon: Icons.logout,
              title: AppLocalizations.of(context)!.logout,
              onTap: () {
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

class SettingsTileV2 extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SettingsTileV2({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xsVertical,
      ),
      leading: Icon(
        icon,
        color: AppColorsV2.textPrimary,
        size: AppSpacing.iconMedium,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium,
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 24.sp,
        color: AppColorsV2.textSecondary,
      ),
      onTap: onTap,
    );
  }
}

