import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/booking_request/view/booking_request_view.dart';
import 'package:ustahub/app/modules/provider_homepage/controller/provider_home_screen_controller.dart';
import 'package:ustahub/app/modules/provider_edit_profile/view/provider_edit_profile_view.dart';
import 'package:ustahub/app/modules/my_service/view/my_service_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../components/navigation/app_app_bar_v2.dart';
import '../../components/feedback/nudge_banner_v2.dart';
import '../../components/cards/app_card.dart';
import '../../components/feedback/skeleton_loader_v2.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../calendar/provider_calendar_screen_v2.dart';
import '../../navigation/app_router_v2.dart';

class ProviderHomeScreenV2 extends StatelessWidget {
  const ProviderHomeScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.isRegistered<ProviderProfileController>()
        ? Get.find<ProviderProfileController>()
        : Get.put(ProviderProfileController());
    final homeController = Get.isRegistered<ProviderHomeScreenController>()
        ? Get.find<ProviderHomeScreenController>()
        : Get.put(ProviderHomeScreenController());

    profileController.fetchProfile();
    homeController.fetchProviderHomeScreenData();
    
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              profileController.fetchProfile(),
              homeController.refreshData(),
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
                SizedBox(height: AppSpacing.mdVertical),
                // Nudge Banners
                Obx(() => _buildNudgeBanners(
                  profileController: profileController,
                  homeController: homeController,
                )),
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
                        ? 4
                        : _getDashboardItems(homeController).length,
                    itemBuilder: (context, index) {
                      if (homeController.isLoading.value) {
                        return const SkeletonGridItemV2();
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
      return const SkeletonListItemV2(
        height: 90,
        padding: EdgeInsets.all(0),
      );
    }

    String avatarUrl = imageUrl ?? blankProfileImage;
    
    return AppCard(
      enableShadow: true,
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
    required dynamic icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return AppCard(
      enableShadow: true,
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
            child: icon is IconData
                ? Icon(
                    icon,
                    color: iconColor,
                    size: 24.sp,
                  )
                : SvgPicture.asset(
                    icon as String,
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
      {
        'icon': Icons.calendar_today,
        'label': 'Bookings This Month',
        'value': "${data.overview.monthlyBookings}",
        'iconColor': AppColorsV2.success,
        'route': null,
      },
      {
        'icon': Icons.attach_money,
        'label': 'Monthly Earnings',
        'value': "\$${data.overview.monthlyEarnings.toStringAsFixed(0)}",
        'iconColor': AppColorsV2.warning,
        'route': null,
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
      {
        'icon': Icons.calendar_today,
        'label': 'Bookings This Month',
        'value': "0",
        'iconColor': AppColorsV2.success,
        'route': null,
      },
      {
        'icon': Icons.attach_money,
        'label': 'Monthly Earnings',
        'value': "\$0",
        'iconColor': AppColorsV2.warning,
        'route': null,
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
        return const SkeletonListItemV2(height: 100);
      }

      return AppCard(
        enableShadow: true,
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

  Widget _buildNudgeBanners({
    required ProviderProfileController profileController,
    required ProviderHomeScreenController homeController,
  }) {
    final user = profileController.userProfile.value;
    final homeData = homeController.homeScreenData.value;
    
    if (profileController.isLoading.value || homeController.isLoading.value) {
      return const SizedBox.shrink();
    }

    final List<Widget> nudges = [];

    // 1. Check profile completeness
    if (user != null) {
      final isProfileIncomplete = 
          (user.bio == null || user.bio!.isEmpty) ||
          (user.businessName == null || user.businessName!.isEmpty) ||
          (user.avatar == null || user.avatar!.isEmpty || user.avatar == blankProfileImage);
      
      if (isProfileIncomplete) {
        nudges.add(
          NudgeBannerV2(
            title: 'Complete Your Profile',
            message: 'Add your bio, business name, and profile photo to attract more customers.',
            icon: Icons.person_outline,
            iconColor: AppColorsV2.warning,
            actionText: 'Complete Profile',
            onActionPressed: () {
              Get.to(() => ProviderEditProfileView(user: user));
            },
          ),
        );
      }
    }

    // 2. Check plans
    if (homeController.plansCount.value == 0) {
      nudges.add(
        NudgeBannerV2(
          title: 'No Service Plans',
          message: 'Add service plans to help customers book your services easily.',
          icon: Icons.add_business_outlined,
          iconColor: AppColorsV2.info,
          actionText: 'Add Plans',
            onActionPressed: () {
              Get.to(() => MyServiceView());
            },
        ),
      );
    }

    // 3. Check acceptance rate
    if (homeData != null) {
      final totalRequests = homeData.overview.bookingRequest + homeData.overview.calendar;
      if (totalRequests > 0) {
        final acceptanceRate = (homeData.overview.calendar / totalRequests) * 100;
        if (acceptanceRate < 50 && totalRequests >= 5) {
          nudges.add(
            NudgeBannerV2(
              title: 'Low Acceptance Rate',
              message: 'Your acceptance rate is ${acceptanceRate.toStringAsFixed(0)}%. Accepting more bookings can help grow your business.',
              icon: Icons.trending_down,
              iconColor: AppColorsV2.error,
              actionText: 'View Requests',
              onActionPressed: () {
                Get.to(() => BookingRequestView());
              },
            ),
          );
        }
      }
    }

    if (nudges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: nudges,
    );
  }
}

