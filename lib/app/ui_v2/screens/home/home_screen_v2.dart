import 'dart:async';
import 'package:flutter/foundation.dart';
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
import 'package:ustahub/app/modules/countdown/controller/countdown_controller.dart';
import 'package:ustahub/utils/cache/image_cache_config.dart';
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
  late final CountdownController countdownController;
  int currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize countdown controller with GetX
    countdownController = Get.put(CountdownController());
    controller.providerController.initializeLocation();
  }

  @override
  void dispose() {
    // CountdownController will handle its own cleanup via onClose
    super.dispose();
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

      // Filter out banners with invalid image URLs
      final validBanners = banners.where((banner) {
        final imageUrl = banner.image;
        return imageUrl != null && 
               imageUrl.isNotEmpty && 
               Uri.tryParse(imageUrl) != null;
      }).toList();

      if (validBanners.isEmpty) {
        if (kDebugMode) {
          print('[BANNER] ⚠️ No valid banner images found. Total banners: ${banners.length}');
          for (var banner in banners) {
            print('[BANNER] Invalid banner: image=${banner.image}');
          }
        }
        return Container(
          height: 200.h,
          color: AppColorsV2.surface,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 48.w,
                  color: AppColorsV2.textTertiary,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Banner images unavailable',
                  style: AppTextStyles.bodyMediumSecondary,
                ),
              ],
            ),
          ),
        );
      }

      // Ensure current index is within range
      final totalBanners = validBanners.length;
      if (currentBannerIndex >= totalBanners) {
        currentBannerIndex = 0;
      }

      return Stack(
        children: [
          CarouselSlider(
            carouselController: carouselController,
            items: validBanners.map((banner) {
              final imageUrl = banner.image ?? '';
              
              if (kDebugMode) {
                print('[BANNER] Loading image: $imageUrl');
              }
              
              return Container(
                margin: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        cacheManager: getImageCacheManager(),
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
                          if (kDebugMode) {
                            print('[BANNER] ❌ Error loading image: $url');
                            print('[BANNER] Error: $error');
                          }
                          return Container(
                            color: AppColorsV2.surface,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: AppSpacing.iconXLarge,
                                  color: AppColorsV2.textTertiary,
                                ),
                                if (kDebugMode) ...[
                                  SizedBox(height: 8.h),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                                    child: Text(
                                      'Failed to load',
                                      style: AppTextStyles.captionSmall.copyWith(
                                        color: AppColorsV2.textTertiary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                        memCacheWidth: (400 * MediaQuery.of(context).devicePixelRatio).round(),
                        memCacheHeight: (200 * MediaQuery.of(context).devicePixelRatio).round(),
                        maxWidthDiskCache: 800,
                        maxHeightDiskCache: 600,
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
    return Obx(() => Container(
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
                    _buildCountdownSegment(
                      countdownController.days.value.toString().padLeft(2, '0'),
                      'days',
                    ),
                    SizedBox(width: 12.w),
                    _buildCountdownSegment(
                      countdownController.hours.value.toString().padLeft(2, '0'),
                      'hours',
                    ),
                    SizedBox(width: 12.w),
                    _buildCountdownSegment(
                      countdownController.minutes.value.toString().padLeft(2, '0'),
                      'min',
                    ),
                    SizedBox(width: 12.w),
                    _buildCountdownSegment(
                      countdownController.seconds.value.toString().padLeft(2, '0'),
                      'sec',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ));
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
            () {
              if (controller.servicesController.isLoading.value) {
                return GridView.builder(
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
                );
              }

              final services = controller.servicesController.serviceCategories;
              final itemCount = services.length >= 4 ? 4 : services.length;
              
              // Replace GridView with Wrap to avoid shrinkWrap performance issues
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: List.generate(
                  itemCount,
                  (index) {
                    final service = services[index];
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 
                              AppSpacing.screenPaddingHorizontal * 2 - 
                              AppSpacing.sm * 3) / 4,
                      child: _buildServiceCard(service),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServicesModelClass service) {
    final config = ServiceIconHelper.getConfig(service.name);
    
    return RepaintBoundary(
      child: GestureDetector(
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
            () {
              if (controller.providerController.isLoading.value) {
                return Column(
                  children: List.generate(
                    3,
                    (index) => Container(
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
                    ),
                  ),
                );
              }

              // Use pre-computed top providers instead of reversed list in itemBuilder
              final topProviders = controller.providerController.getTopProviders(5);
              
              // Replace ListView.builder with Column to avoid shrinkWrap performance issues
              return Column(
                children: topProviders.map((data) {
                  final servicesString = (data.services ?? [])
                      .map((s) => s.name ?? '')
                      .where((name) => name.isNotEmpty)
                      .join(', ');
                  return RepaintBoundary(
                    child: _buildRecommendedCard(
                      data: data,
                      servicesString: servicesString,
                    ),
                  );
                }).toList(),
              );
            },
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

