import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/booking_request/view/booking_request_view.dart';
import 'package:ustahub/app/modules/provider_homepage/controller/provider_home_screen_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../components/navigation/app_app_bar_v2.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../calendar/provider_calendar_screen_v2.dart';

class ProviderHomeScreenV2 extends StatelessWidget {
  const ProviderHomeScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProviderProfileController());
    final homeController = Get.put(ProviderHomeScreenController());

    profileController.fetchProfile();
    homeController.fetchProviderHomeScreenData();
    
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              profileController.fetchProfile(),
              homeController.fetchProviderHomeScreenData(),
            ]);
          },
          color: AppColorsV2.primary,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.mdVertical),
                // Profile Header
                Obx(() {
                  final user = profileController.userProfile.value;
                  if (user != null) {
                    return _buildProfileHeader(
                      name: user.name,
                      imageUrl: user.avatar,
                      isLoading: profileController.isLoading.value,
                    );
                  }
                  return _buildProfileHeader(
                    isLoading: profileController.isLoading.value,
                  );
                }),
                SizedBox(height: AppSpacing.xlVertical),
                // Overview Section
                Text(
                  AppLocalizations.of(context)!.overview,
                  style: AppTextStyles.heading3,
                ),
                SizedBox(height: AppSpacing.mdVertical),
                // Dashboard Cards
                Obx(
                  () => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: homeController.isLoading.value
                        ? 2
                        : _getDashboardItems(homeController).length,
                    itemBuilder: (context, index) {
                      if (homeController.isLoading.value) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColorsV2.surface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLarge,
                            ),
                          ),
                        ).withShimmerAi(loading: true);
                      }

                      final items = _getDashboardItems(homeController);
                      if (index >= items.length) return const SizedBox.shrink();

                      final item = items[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (item['route'] == 'requests') {
                              Get.to(() => BookingRequestView());
                            } else if (item['route'] == 'calendar') {
                              Get.to(() => const ProviderCalendarScreenV2());
                            }
                          },
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                          child: _buildDashboardCardV2(
                            icon: item['icon'],
                            label: item['label'],
                            value: item['value'],
                            iconColor: item['iconColor'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: AppSpacing.xlVertical),
                _buildRatingSummary(homeController),
                SizedBox(height: AppSpacing.xlVertical),
                // Reviews Widget
                ProviderReviewsWidget(homeController: homeController),
                SizedBox(height: AppSpacing.xlVertical),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader({
    String? name,
    String? imageUrl,
    bool isLoading = false,
  }) {
    if (isLoading) {
      return Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: AppColorsV2.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
      ).withShimmerAi(loading: true);
    }

    String avatarUrl = imageUrl ?? blankProfileImage;
    
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
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppColorsV2.textSecondary.withOpacity(0.2),
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl.isEmpty
                ? Icon(
                    Icons.person,
                    size: 30.r,
                    color: AppColorsV2.textSecondary,
                  )
                : null,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? 'Provider',
                  style: AppTextStyles.heading4,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.xsVertical),
                Text(
                  'Welcome back!',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCardV2({
    required String icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: SvgPicture.asset(
              icon,
              width: AppSpacing.iconLarge,
              height: AppSpacing.iconLarge,
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.smVertical),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColorsV2.primary,
                ),
                maxLines: 1,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xsVertical),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getDashboardItems(
    ProviderHomeScreenController controller,
  ) {
    final data = controller.homeScreenData.value;
    if (data == null) {
      return _getDefaultDashboardItems();
    }

    return [
      {
        'icon': AppVectors.svgBookingRequests,
        'label': AppLocalizations.of(Get.context!)!.bookingRequest,
        'value': "${data.overview.bookingRequest}",
        'iconColor': AppColorsV2.primary,
        'route': 'requests',
      },
      {
        'icon': AppVectors.svgCalendar,
        'label': AppLocalizations.of(Get.context!)!.calendar,
        'value': "${data.overview.calendar}",
        'iconColor': AppColorsV2.primary,
        'route': 'calendar',
      },
    ];
  }

  List<Map<String, dynamic>> _getDefaultDashboardItems() {
    return [
      {
        'icon': AppVectors.svgBookingRequests,
        'label': AppLocalizations.of(Get.context!)!.bookingRequest,
        'value': "0",
        'iconColor': AppColorsV2.primary,
        'route': 'requests',
      },
      {
        'icon': AppVectors.svgCalendar,
        'label': AppLocalizations.of(Get.context!)!.calendar,
        'value': "0",
        'iconColor': AppColorsV2.primary,
        'route': 'calendar',
      },
    ];
  }

  Widget _buildRatingSummary(ProviderHomeScreenController controller) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final count = controller.ratingCount.value;
      final average =
          double.tryParse(controller.averageRating.value)?.toStringAsFixed(1) ??
          '0.0';

      if (isLoading) {
        return Container(
          height: 90.h,
          decoration: BoxDecoration(
            color: AppColorsV2.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
        ).withShimmerAi(loading: true);
      }

      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColorsV2.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColorsV2.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColorsV2.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_rounded,
                color: AppColorsV2.primary,
                size: AppSpacing.iconLarge,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(Get.context!)!.rating,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColorsV2.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      average,
                      style: AppTextStyles.heading3,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      "($count)",
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: AppColorsV2.textSecondary,
            ),
          ],
        ),
      );
    });
  }
}

