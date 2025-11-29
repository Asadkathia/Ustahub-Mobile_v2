import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/common_model_class/ProviderListModelClass.dart';
import 'package:ustahub/app/modules/common_model_class/banner_model_class.dart';
import 'package:ustahub/app/modules/banners/controller/banner_controller.dart';
import 'package:ustahub/app/modules/providers_list/view/providers_list_view.dart';
import 'package:ustahub/app/modules/provider_details/view/provider_details_screen.dart';
import 'package:ustahub/app/modules/search/view/search_view.dart';
import 'package:ustahub/app/modules/consumer_homepage/view/all_services_view.dart';
import 'package:ustahub/app/ui_v2/screens/services/all_services_view_v2.dart';
import 'package:ustahub/app/ui_v2/config/ui_config.dart';
import 'package:ustahub/app/ui_v2/design_system/colors/app_colors_v2.dart';
import 'package:ustahub/app/ui_v2/design_system/typography/app_text_styles.dart';
import 'package:ustahub/app/ui_v2/design_system/spacing/app_spacing.dart';
import 'package:ustahub/app/modules/consumer_homepage/controller/consumer_homepage_controller.dart';
import '../search/search_screen_v2.dart';
import '../../components/cards/recommendation_card_v2.dart';
import '../provider/provider_details_screen_v2.dart';
import '../../utils/service_icon_helper.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> {
  final ConsumerHomepageController controller = Get.put(
    ConsumerHomepageController(),
  );
  final BannerController bannerController = Get.put(BannerController());
  final CarouselSliderController carouselController = CarouselSliderController();
  int currentBannerIndex = 0;
  
  // Countdown timer state
  int days = 7;
  int hours = 12;
  int minutes = 30;
  int seconds = 20;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    controller.providerController.initializeLocation();
    startCountdown();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else if (minutes > 0) {
        setState(() {
          minutes--;
          seconds = 59;
        });
      } else if (hours > 0) {
        setState(() {
          hours--;
          minutes = 59;
          seconds = 59;
        });
      } else if (days > 0) {
        setState(() {
          days--;
          hours = 23;
          minutes = 59;
          seconds = 59;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar
            _buildStatusBar(),
            
            // Search Bar
            _buildSearchBar(),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Banner
                    _buildHeroBanner(),
                    
                    // Limited Offer Section (no gap)
                    _buildLimitedOfferSection(),
                    
                    SizedBox(height: AppSpacing.lgVertical),
                    
                    // Services Section
                    _buildServicesSection(),
                    
                    SizedBox(height: AppSpacing.xsVertical),
                    
                    // Recommended Section
                    _buildRecommendedSection(),
                    
                    SizedBox(height: AppSpacing.xlVertical),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    // Status bar removed - return empty container
    return const SizedBox.shrink();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.only(
        left: 0,
        right: 0,
        bottom: 0,
      ),
      child: GestureDetector(
        onTap: () {
          if (UIConfig.useNewUI) {
            Get.to(() => SearchScreenV2());
          } else {
            Get.to(() => SearchView());
          }
        },
        child: Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: AppColorsV2.primary,
            borderRadius: BorderRadius.zero,
          ),
          child: Row(
            children: [
              SizedBox(width: AppSpacing.screenPaddingHorizontal),
              Icon(
                Icons.search,
                color: AppColorsV2.textOnPrimary,
                size: 22.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Center(
                  child: OverflowBox(
                    maxHeight: double.infinity,
                      child: Image.asset(
                      'images/Logo/Ustahub logo copy12.png',
                      height: 120.h,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'USTAHUB',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColorsV2.textOnPrimary,
                            letterSpacing: 1.2,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: AppSpacing.screenPaddingHorizontal + 22.w + 12.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Obx(() {
      final List<BannerModelClass> banners = bannerController.bannersList;
      final bool isLoading = bannerController.isLoading.value;

      if (isLoading) {
        return SizedBox(
          height: 200.h,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (banners.isEmpty) {
        return Container(
          height: 200.h,
          color: AppColorsV2.surface,
          child: Center(
            child: Text(
              'No banners available',
              style: AppTextStyles.bodyMediumSecondary,
            ),
          ),
        );
      }

      // Ensure current index is within range
      final totalBanners = banners.length;
      if (currentBannerIndex >= totalBanners) {
        currentBannerIndex = 0;
      }

      return Stack(
        children: [
          CarouselSlider(
            carouselController: carouselController,
            items: banners.map((banner) {
              final imageUrl = banner.image ?? '';
              return Container(
                margin: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        alignment: const Alignment(0.1, 0),
                        placeholder: (context, url) => Container(
                          color: AppColorsV2.surface,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColorsV2.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          debugPrint('Error loading banner image: $imageUrl');
                          return Container(
                            color: AppColorsV2.surface,
                            child: Icon(
                              Icons.image_not_supported,
                              size: AppSpacing.iconXLarge,
                              color: AppColorsV2.textTertiary,
                            ),
                          );
                        },
                        memCacheWidth: (400 * MediaQuery.of(context).devicePixelRatio).round(),
                        memCacheHeight: (200 * MediaQuery.of(context).devicePixelRatio).round(),
                      ),
                      Positioned(
                        bottom: AppSpacing.mdVertical,
                        right: AppSpacing.screenPaddingHorizontal,
                        child: Row(
                          children: List.generate(
                            totalBanners,
                            (index) => Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width:
                                  currentBannerIndex == index ? 8.w : 6.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: currentBannerIndex == index
                                    ? AppColorsV2.textOnPrimary
                                    : AppColorsV2.textOnPrimary
                                        .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: 200.h,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              onPageChanged: (index, reason) {
                setState(() {
                  currentBannerIndex = index;
                });
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLimitedOfferSection() {
    return Container(
      margin: EdgeInsets.only(
        left: 0,
        right: 0,
        top: 0,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingHorizontal,
        vertical: AppSpacing.smVertical,
      ),
      decoration: BoxDecoration(
        color: AppColorsV2.primary,
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LIMITED OFFER',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColorsV2.textOnPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Save up to 50%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColorsV2.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCountdownSegment(days.toString().padLeft(2, '0'), 'days'),
                    SizedBox(width: 12.w),
                    _buildCountdownSegment(hours.toString().padLeft(2, '0'), 'hours'),
                    SizedBox(width: 12.w),
                    _buildCountdownSegment(minutes.toString().padLeft(2, '0'), 'min'),
                    SizedBox(width: 12.w),
                    _buildCountdownSegment(seconds.toString().padLeft(2, '0'), 'sec'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownSegment(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: AppColorsV2.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColorsV2.textOnPrimary.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.services,
                style: AppTextStyles.heading3,
              ),
              TextButton(
                onPressed: () {
                  if (UIConfig.useNewServicesView) {
                    Get.to(
                      () => AllServicesViewV2(
                        services: controller.servicesController.serviceCategories,
                      ),
                    );
                  } else {
                    Get.to(
                      () => AllServicesView(
                        services: controller.servicesController.serviceCategories,
                      ),
                    );
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.viewAll,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColorsV2.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.mdVertical),
          Obx(
            () => controller.servicesController.isLoading.value
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.xs,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColorsV2.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColorsV2.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.xs,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: controller.servicesController.serviceCategories.length >= 4
                        ? 4
                        : controller.servicesController.serviceCategories.length,
                    itemBuilder: (context, index) {
                      final service = controller.servicesController.serviceCategories[index];
                      return _buildServiceCard(service);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServicesModelClass service) {
    final config = ServiceIconHelper.getConfig(service.name);
    
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ProvidersListView(
            providers: controller.providerController.providersList,
            serviceName: service.name!,
            serviceId: service.id.toString(),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: cardWidth * 0.85,
                height: cardWidth * 0.85,
                decoration: BoxDecoration(
                  color: config.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Icon(
                  config.icon,
                  color: config.iconColor,
                  size: cardWidth * 0.4,
                ),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: cardWidth,
                child: Text(
                  service.name ?? '',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 9.sp,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildRecommendedSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommended',
                style: AppTextStyles.heading3,
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all providers
                },
                child: Text(
                  AppLocalizations.of(context)!.viewAll,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColorsV2.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.mdVertical),
          Obx(
            () => controller.providerController.isLoading.value
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 120.h,
                        margin: EdgeInsets.only(bottom: AppSpacing.mdVertical),
                        decoration: BoxDecoration(
                          color: AppColorsV2.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColorsV2.primary,
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.providerController.providersList.length >= 5
                        ? 5
                        : controller.providerController.providersList.length,
                    itemBuilder: (context, index) {
                      final data = controller.providerController.providersList
                          .reversed
                          .toList()[index];
                      final servicesString = (data.services ?? [])
                          .map((s) => s.name ?? '')
                          .where((name) => name.isNotEmpty)
                          .join(', ');
                      return _buildRecommendedCard(
                        data: data,
                        servicesString: servicesString,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard({
    required ProvidersListModelClass data,
    required String servicesString,
  }) {
    final providerName =
        (data.name?.trim().isNotEmpty ?? false) ? data.name!.trim() : 'Provider';
    final primaryService = servicesString.isNotEmpty
        ? servicesString.split(',').first.trim()
        : AppLocalizations.of(context)!.services;

    return RecommendationCardV2(
      title: providerName,
      subtitle: primaryService,
      imageUrl: data.avatar ?? blankProfileImage,
      badgeText: AppLocalizations.of(context)!.recommendedService,
      rating: double.tryParse(data.averageRating?.toString() ?? '0') ?? 0,
      location: data.bio ?? '',
      onTap: () {
        if (UIConfig.useNewUI) {
          Get.to(() => ProviderDetailsScreenV2(id: data.id.toString()));
        } else {
          Get.to(() => ProviderDetailsScreen(id: data.id.toString()));
        }
      },
    );
  }
}

