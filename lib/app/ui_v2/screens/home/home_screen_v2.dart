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
import '../search/search_screen_v2.dart';
import '../search/advanced_search_screen_v2.dart';
import '../../components/cards/recommendation_card_v2.dart';
import '../provider/provider_details_screen_v2.dart';
import '../../utils/service_icon_helper.dart';
import '../../components/cards/app_card.dart';
import '../../components/inputs/app_search_field.dart';
import '../../components/feedback/skeleton_loader_v2.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> {
  ConsumerHomepageController get controller {
    Get.lazyPut(() => ConsumerHomepageController());
    return Get.find<ConsumerHomepageController>();
  }
  
  BannerController get bannerController {
    Get.lazyPut(() => BannerController());
    return Get.find<BannerController>();
  }
  final CarouselSliderController carouselController = CarouselSliderController();
  late final CountdownController countdownController;
  int currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize countdown controller with GetX
    // Use Get.findOrPut to avoid creating multiple instances if already exists
    // Since this is a global limited offer countdown, we use a singleton
    if (Get.isRegistered<CountdownController>(tag: 'countdown')) {
      countdownController = Get.find<CountdownController>(tag: 'countdown');
    } else {
      countdownController = Get.put(CountdownController(), tag: 'countdown');
    }
    controller.providerController.initializeLocation();
    
    // Update countdown controller with country info when available
    _updateCampaignBasedOnLocation();
  }

  /// Update campaign based on user's location
  void _updateCampaignBasedOnLocation() {
    // Listen to banner controller's country changes
    ever(bannerController.currentCountry, (String country) {
      if (country.isNotEmpty) {
        countdownController.updateCountry(country);
      }
    });
    
    // Also check if country is already available
    if (bannerController.currentCountry.value.isNotEmpty) {
      countdownController.updateCountry(bannerController.currentCountry.value);
    }
  }

  @override
  void dispose() {
    // Note: CountdownController is a singleton for the global limited offer
    // It will be cleaned up when the app closes or explicitly deleted
    // We don't delete it here to maintain the countdown across navigation
    // The timer is properly managed in the controller's onClose method
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
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingHorizontal,
        AppSpacing.mdVertical,
        AppSpacing.screenPaddingHorizontal,
        AppSpacing.smVertical,
      ),
      child: AppSearchField(
        hintText: AppLocalizations.of(context)!.search,
        readOnly: true,
        onTap: () {
          if (UIConfig.useNewUI) {
            Get.to(() => SearchScreenV2());
          } else {
            Get.to(() => SearchView());
          }
        },
        onFilterTap: () => Get.to(() => const AdvancedSearchScreenV2()),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
      child: Obx(() {
      final List<BannerModelClass> banners = bannerController.bannersList;
      final bool isLoading = bannerController.isLoading.value;

      if (isLoading) {
          return AppCard(
            bordered: false,
            enableShadow: true,
            padding: EdgeInsets.zero,
            child: SkeletonLoaderV2(
              width: double.infinity,
              height: 200.h,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            ),
        );
      }

      if (banners.isEmpty) {
          return AppCard(
            bordered: false,
            enableShadow: true,
            child: SizedBox(
              height: 180.h,
              child: Center(
                child: Text(
                  'No banners available',
                  style: AppTextStyles.bodyMediumSecondary,
                ),
            ),
          ),
        );
      }

      // Filter out banners with invalid image URLs and deduplicate by image URL
      final Map<String, BannerModelClass> seenImages = {};
      final List<BannerModelClass> validBanners = [];
      
      for (var banner in banners) {
        final imageUrl = banner.image;
        if (imageUrl != null && 
            imageUrl.isNotEmpty && 
            Uri.tryParse(imageUrl) != null) {
          // Deduplicate by image URL to prevent visual duplicates
          if (!seenImages.containsKey(imageUrl)) {
            seenImages[imageUrl] = banner;
            validBanners.add(banner);
          }
        }
      }

      if (validBanners.isEmpty) {
        if (kDebugMode) {
          print('[BANNER] ⚠️ No valid banner images found. Total banners: ${banners.length}');
          for (var banner in banners) {
            print('[BANNER] Invalid banner: image=${banner.image}');
          }
        }
        return AppCard(
          bordered: false,
          enableShadow: true,
          child: SizedBox(
            height: 180.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: AppSpacing.iconXLarge,
                  color: AppColorsV2.textTertiary,
                ),
                SizedBox(height: AppSpacing.smVertical),
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

      return AppCard(
        bordered: false,
        enableShadow: true,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            CarouselSlider(
              carouselController: carouselController,
              items: validBanners.map((banner) {
                final imageUrl = banner.image ?? '';
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => SkeletonLoaderV2(
                      width: double.infinity,
                      height: 200.h,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColorsV2.surface,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: AppSpacing.iconXLarge,
                            color: AppColorsV2.textTertiary,
                          ),
                          SizedBox(height: AppSpacing.xsVertical),
                          Text(
                            'Failed to load',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColorsV2.textTertiary,
                            ),
                          ),
                        ],
                      ),
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
            Positioned(
              bottom: 16.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  totalBanners,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: currentBannerIndex == index ? 20.w : 8.w,
                    height: 6.h,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: currentBannerIndex == index
                          ? AppColorsV2.textOnPrimary
                          : AppColorsV2.textOnPrimary.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }),
    );
  }

  Widget _buildLimitedOfferSection() {
    return Obx(() {
      // Check if campaign is active
      if (!countdownController.isCampaignActive) {
        return const SizedBox.shrink();
      }

      final campaign = countdownController.currentCampaign.value;
      final campaignTitle = campaign?.title ?? _getLocalizedOfferTitle();
      final campaignDiscount = campaign?.discountText ?? _getLocalizedDiscountText();

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
                    campaignTitle,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColorsV2.textOnPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    campaignDiscount,
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
      );
    });
  }

  /// Get localized offer title (fallback if campaign doesn't provide one)
  String _getLocalizedOfferTitle() {
    try {
      // Try to get localized string, fallback to English
      final localizations = AppLocalizations.of(context);
      // If localization keys exist, use them
      // For now, return default English text
      // TODO: Add localization keys to ARB files if needed
      return 'LIMITED OFFER';
    } catch (e) {
      return 'LIMITED OFFER';
    }
  }

  /// Get localized discount text (fallback if campaign doesn't provide one)
  String _getLocalizedDiscountText() {
    try {
      // Try to get localized string, fallback to English
      final localizations = AppLocalizations.of(context);
      // If localization keys exist, use them
      // For now, return default English text
      // TODO: Add localization keys to ARB files if needed
      return 'Save up to 50%';
    } catch (e) {
      return 'Save up to 50%';
    }
  }

  Widget _buildCountdownSegment(String value, String label) {
    // Localize time unit labels
    final localizedLabel = _getLocalizedTimeUnit(label);
    
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
          localizedLabel,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColorsV2.textOnPrimary.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  /// Get localized time unit (days, hours, min, sec)
  String _getLocalizedTimeUnit(String unit) {
    try {
      final localizations = AppLocalizations.of(context);
      // Map English units to localized versions
      // For now, return as-is since we don't have specific localization keys
      // TODO: Add localization keys for time units if needed
      switch (unit.toLowerCase()) {
        case 'days':
          return 'days'; // Could be localized
        case 'hours':
          return 'hours'; // Could be localized
        case 'min':
          return 'min'; // Could be localized
        case 'sec':
          return 'sec'; // Could be localized
        default:
          return unit;
      }
    } catch (e) {
      return unit;
    }
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
                    childAspectRatio: 0.75,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) => const SkeletonGridItemV2(),
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
                    (index) => const SkeletonListItemV2(),
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

