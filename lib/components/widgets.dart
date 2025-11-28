import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:readmore/readmore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:ustahub/app/modules/booking_request/controller/booking_request_controller.dart';
import 'package:ustahub/app/modules/booking_request/model_class/BookingRequestModel.dart';
import 'package:ustahub/app/modules/consumer_homepage/view/all_services_view.dart';
import 'package:ustahub/app/modules/filter/controller/filter_controller.dart';
import 'package:ustahub/app/modules/filter/view/filter_view.dart';
import 'package:ustahub/app/modules/provider_completed_booking_details/controller/provider_complete_work_controller.dart';
import 'package:ustahub/app/modules/provider_details/model_class/provider_details_model_class.dart';
import 'package:ustahub/app/modules/provider_homepage/controller/provider_home_screen_controller.dart';
import 'package:ustahub/app/modules/providers_list/view/providers_list_view.dart';

import 'package:ustahub/app/modules/search/view/search_view.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/components/confirm_dialog.dart';

// Tab Button for Login Page

class TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const TabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.all(3.r),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(32.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.ubuntu(
              color: isSelected ? Colors.green : Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class TermsAndPrivacyPolicyText extends StatelessWidget {
  const TermsAndPrivacyPolicyText({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: AppLocalizations.of(context)!.termsFirstLine,
              style: GoogleFonts.ubuntu(
                fontSize: 12.sp,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: AppLocalizations.of(context)!.termsSecondLine,
              style: GoogleFonts.ubuntu(
                fontSize: 12.sp,
                color: AppColors.green,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: AppLocalizations.of(context)!.termsThirdLine,
              style: GoogleFonts.ubuntu(
                fontSize: 12.sp,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: AppLocalizations.of(context)!.termsFourthLine,
              style: GoogleFonts.ubuntu(
                fontSize: 12.sp,
                color: AppColors.green,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Homepage Search bar

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 13.w),
      child: Column(
        children: [
          10.ph,
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => SearchView());
                  },
                  child: buildFormField(
                    fillColor: Colors.white,
                    enabled: false,
                    suffixIcon: Icon(
                      Icons.filter_list_sharp,
                      color: AppColors.green,
                      size: 27.h,
                    ),
                    hint: AppLocalizations.of(context)!.search,
                    prefixIcon: Icon(
                      Icons.search,
                      size: 27.h,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ),
              // IconButton(
              //   onPressed: () {},
              //   icon: Icon(
              //     Icons.account_balance_wallet_rounded,
              //     color: AppColors.green,
              //     size: 27.h,
              //   ),
              // ),
            ],
          ),
          20.ph,
        ],
      ),
    );
  }
}

// Homepage Carosal Dot Indicator

class CarousalDotIndicator extends StatelessWidget {
  const CarousalDotIndicator({
    super.key,
    required this.controller,
    required this.bannerList,
  });

  final ConsumerHomepageController controller;
  final List<String> bannerList;

  @override
  Widget build(BuildContext context) {
    // Safety check for empty banner list
    if (bannerList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      // Safety check for controller and currentIndex
      final currentIndexValue = controller.currentIndex.value;

      // Ensure currentIndex is valid
      final safeIndex = currentIndexValue.clamp(0, bannerList.length - 1);

      return SafeAnimatedSmoothIndicator(
        activeIndex: safeIndex,
        count: bannerList.length,
        effect: ExpandingDotsEffect(
          dotHeight: 8.h,
          dotWidth: 8.w,
          activeDotColor: AppColors.green,
          dotColor: Colors.grey[300]!,
        ),
        onDotClicked: (index) {
          // carouselController.animateTo(1.0, duration: Duration(seconds: 1), curve: );
        },
      );
    });
  }
}

// Homepage Categories GridView

class CategoriesGridView extends StatelessWidget {
  final List<ServicesModelClass> data;
  final void Function(ServicesModelClass)? onCategoryTap;
  bool? showFull;
  CategoriesGridView({
    super.key,
    required this.data,
    this.showFull = false,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: showFull! ? double.infinity : 250.h,
      child: GridView.builder(
        physics: showFull! ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
        itemCount: data.length, // 7 categories + 1 'View All'
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 1.w,
          mainAxisSpacing: 20.h,
          mainAxisExtent: 135.h,
        ),
        itemBuilder: (context, index) {
          final item = data[index];
          if (!showFull!) {
            if (index == 7) {
              // 8th item - View All Categories
              return GestureDetector(
                onTap: () {
                  Get.to(() => AllServicesView(services: data));
                },
                child: Column(
                  children: [
                    Container(
                      height: 72.h,
                      width: 72.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        // color: AppColors.green.withOpacity(0.1),
                        color: Colors.white,
                      ),
                      child: SvgPicture.asset(
                        AppVectors.svgViewAll,
                        height: 30.h,
                        fit: BoxFit.scaleDown,
                        width: 30.h,
                      ),
                    ),
                    8.ph,
                    SizedBox(
                      width: 85.w,
                      height: 35.h,
                      child: Text(
                        AppLocalizations.of(context)!.viewAll,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.green,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }
          // Regular category item
          return GestureDetector(
            onTap: onCategoryTap != null ? () => onCategoryTap!(item) : null,
            child: HomepagServicesContainer(data: item),
          );
        },
      ),
    );
  }
}

// Homepage Services Container
class HomepagServicesContainer extends StatelessWidget {
  ServicesModelClass? data;
  HomepagServicesContainer({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 72.h,
          width: 72.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: Colors.white,
          ),
          child: Icon(
            color: AppColors.green,
            size: 30.sp,
            getServiceIcon(data?.name ?? ""))
        ),
        8.ph,
        SizedBox(
          width: 85.w,
          height: 35.h,
          child: Text(
            data?.name ?? "Appliances Repair",
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

// Provider Card Container on Homepage and List page

class ServiceProviderCard extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String category;
  // final int amount;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;
  final bool? isShowFavourite;

  final double? starValue;

  const ServiceProviderCard({
    super.key,
    this.imageUrl,
    required this.name,
    required this.category,
    // required this.amount,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.starValue,
    this.onTap,
    this.isShowFavourite = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        height: 110.h,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [

            // Profile Image
            imageContainer(image: imageUrl!), 
            SizedBox(width: 10.w),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.rating,
                        style: GoogleFonts.ubuntu(
                          fontSize: 11.sp,
                          color: AppColors.grey,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      RatingBar.readOnly(
                        size: 16.r,
                        isHalfAllowed: true,
                        halfFilledIcon: Icons.star_half_outlined,
                        filledIcon: Icons.star,
                        emptyIcon: Icons.star_border,
                        halfFilledColor: AppColors.darkGreen,
                        initialRating: starValue!,
                        maxRating: 5,
                        emptyColor: AppColors.grey,
                        filledColor: AppColors.darkGreen,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        starValue.toString(),
                        style: GoogleFonts.ubuntu(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),

                  // Name + Verified
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.ubuntu(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.verified, size: 14.sp, color: Colors.green),
                    ],
                  ),

                  SizedBox(height: 2.h),
                  // Category
                  Text(
                    category,
                    style: GoogleFonts.ubuntu(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            // Price + Heart
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                isShowFavourite!
                    ? IconButton(
                      onPressed: onFavoriteTap,
                      padding: EdgeInsets.all(4.r),
                      constraints: BoxConstraints(
                        minWidth: 32.w,
                        minHeight: 32.h,
                      ),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20.sp,
                      ),
                      color: isFavorite ? Colors.red : AppColors.grey,
                    )
                    : SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

bool _isSvgUrl(String url) {
  return url.endsWith('.svg') || url.contains('ui-avatars.com/api');
}

Widget imageContainer({
  required String image,
  double? height,
  double? width,
  double? borderRadius,
}) {
  // Clean the image URL using the helper function
  String safeImageUrl = cleanImageUrl(image);

  return Container(
    height: height ?? 64.h,
    width: width ?? 64.h,
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(borderRadius?.r ?? 10.r),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child:
          _isSvgUrl(safeImageUrl)
              ? SvgPicture.network(
                safeImageUrl,
                fit: BoxFit.cover,
                placeholderBuilder:
                    (BuildContext context) => Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
              )
              : CachedNetworkImage(
                imageUrl: safeImageUrl,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 30.sp,
                        color: Colors.grey[600],
                      ),
                    ),
              ),
    ),
  );
}

Widget imageContainerCircle({
  required String image,
  double? height,
  double? width,
}) {
  // Clean the image URL using the helper function
  String safeImageUrl = cleanImageUrl(image);

  return Container(
    height: height ?? 64.h,
    width: width ?? 64.h,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.red.withOpacity(0.1),
    ),
    child: ClipOval(
      child:
          _isSvgUrl(safeImageUrl)
              ? SvgPicture.network(
                safeImageUrl,
                fit: BoxFit.cover,
                placeholderBuilder:
                    (BuildContext context) => Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
              )
              : CachedNetworkImage(
                imageUrl: safeImageUrl,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 30.sp,
                        color: Colors.grey[600],
                      ),
                    ),
              ),
    ),
  );
}

// Provider detils screen header

class ProviderDetailsScreenHeader extends StatelessWidget {
  final String name, category, rating, imageUrl;
  final bool? isFavourite;
  final VoidCallback? onFavoriteTap;
  const ProviderDetailsScreenHeader({
    super.key,
    required this.name,
    required this.category,
    required this.rating,
    required this.imageUrl,
    this.isFavourite,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GestureDetector(
        //   onTap: () {
        //     Get.back();
        //   },
        //   child: Padding(
        //     padding: EdgeInsets.only(right: 10.w),
        //     child: SvgPicture.asset(AppVectors.back, height: 24.h, width: 24.h),
        //   ),
        // ),
        imageContainer(image: imageUrl),
        10.pw,
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              7.ph,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: GoogleFonts.ubuntu(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.verified, size: 14.sp, color: Colors.green),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onFavoriteTap,
                    child: Icon(
                      (isFavourite ?? false)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          (isFavourite ?? false) ? Colors.red : AppColors.grey,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.rating,
                      style: GoogleFonts.ubuntu(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blackText,
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      category,
                      style: GoogleFonts.ubuntu(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        rating,
                        style: GoogleFonts.ubuntu(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(Icons.star, color: AppColors.darkGreen, size: 16.sp),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Provider Details Screen Overview Container

class ProviderDetailsOverviewContainer extends StatelessWidget {
  final ProviderDetailsModelClass providerDetails;
  const ProviderDetailsOverviewContainer({
    super.key,
    required this.providerDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.overview,
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
            ),
          ),
          10.ph,
          IconTextRow(
            svgAssetPath: AppVectors.svgHired,
            text: "${providerDetails.overview?.totalBookings ?? 0} Times hired",
          ),
          5.ph,
          IconTextRow(
            svgAssetPath: AppVectors.svgBackgrounCheck,
            text: providerDetails.overview?.backgroundCheckStatus ?? "Background Check",
          ),
          5.ph,
          IconTextRow(
            svgAssetPath: AppVectors.svgLocation,
            text: providerDetails.overview?.city ?? "Location not available",
          ),
          5.ph,
          IconTextRow(
            svgAssetPath: AppVectors.svgTime,
            text: providerDetails.overview?.registeredSince != null
                ? "${providerDetails.overview!.registeredSince} in business"
                : "Recently in business",
          ),
        ],
      ),
    );
  }
}

class IconTextRow extends StatelessWidget {
  final String svgAssetPath;
  final String text;

  const IconTextRow({
    super.key,
    required this.svgAssetPath,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(svgAssetPath, height: 16.h, width: 16.h),
        SizedBox(width: 10.w),
        Text(
          text,
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w400,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}

// Provider Details view Introduction container

class IntroductionContainerProviderDetailsPage extends StatelessWidget {
  final String introTitle;
  const IntroductionContainerProviderDetailsPage({
    super.key,
    required this.introTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.introduction,
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
            ),
          ),
          3.ph,
          ReadMoreText(
            introTitle,
            trimMode: TrimMode.Line,
            style: GoogleFonts.ubuntu(
              fontSize: 12.sp,
              color: AppColors.grey,
              fontWeight: FontWeight.w400,
            ),
            trimLines: 3,
            colorClickableText: AppColors.green,
            trimCollapsedText: AppLocalizations.of(context)!.showMore,
            trimExpandedText: AppLocalizations.of(context)!.showLess,
            moreStyle: GoogleFonts.ubuntu(
              color: AppColors.green,
              fontSize: 13.sp,

              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class PlanRadioButtons extends StatelessWidget {
  final List<Plan> plansss;
  final PlanSelectionController controller =
      Get.find<PlanSelectionController>(); // <-- NOTICE: Get.find
  final ProviderDetailsController controlle;
  PlanRadioButtons({super.key, required this.plansss, required this.controlle});

  String _capitalizeLabel(String? str) {
    if (str == null || str.isEmpty) return "";
    final lower = str.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () =>
          controlle.isLoading.value
              ? Center(child: SizedBox.shrink())
              : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      plansss.map((plan) {
                        final isSelected =
                            controller.selectedPlan.value?.planType ==
                            plan.planType;
                        final label = _capitalizeLabel(plan.planType);
                        return GestureDetector(
                          onTap: () => controller.selectPlan(plan),
                          child: Container(
                            height: 42.h,
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            margin: EdgeInsets.only(right: 8.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.green
                                        : AppColors.green.withOpacity(0.2),
                                width: 1.5,
                              ),
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Radio<Plan>(
                                    value: plan,
                                    groupValue: controller.selectedPlan.value,
                                    onChanged:
                                        (val) => controller.selectPlan(val!),
                                    activeColor: AppColors.green,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  Text(
                                    label,
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 12.sp,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                      color:
                                          isSelected
                                              ? AppColors.green
                                              : AppColors.blackText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
    );
  }
}

// Plan Features Tick widget

class PlanFeaturesTickWidget extends StatelessWidget {
  final String title;
  const PlanFeaturesTickWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check, size: 20.r, color: AppColors.green),
        10.pw,
        Text(
          title,
          style: GoogleFonts.ubuntu(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.blackText,
          ),
        ),
      ],
    );
  }
}

// Provider Details Screen Plan Features Container

class PlansFeaturesContainer extends StatelessWidget {
  final String title, amount;
  final List<String> features;
  const PlansFeaturesContainer({
    super.key,
    required this.title,
    required this.amount,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.green, width: 2),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "\$$amount",
            style: GoogleFonts.ubuntu(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.green,
            ),
          ),
          10.ph,
          Text(
            title,
            style: GoogleFonts.ubuntu(
              fontSize: 14.sp,
              fontWeight: FontWeight.w300,
              // color: AppColors.green,
            ),
          ),
          10.ph,
          Text(
            AppLocalizations.of(context)!.including,
            style: GoogleFonts.ubuntu(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.blackText,
            ),
          ),
          10.ph,
          Column(
            children: List.generate(features.length, (index) {
              return Column(
                children: [
                  7.ph,
                  PlanFeaturesTickWidget(title: features[index]),
                ],
              );
            }),
          ),
          // PlanFeaturesTickWidget(title: "Leak Repair"),
          // 7.ph,
          // PlanFeaturesTickWidget(title: "Pipe fitting"),
          // 7.ph,
          // PlanFeaturesTickWidget(title: "Maintenance"),
        ],
      ),
    );
  }
}

// Dot indicator for PRovider Deatils screen

class ProviderCarousalDotIndicator extends StatelessWidget {
  const ProviderCarousalDotIndicator({
    super.key,
    required this.controller,
    required this.bannerList,
  });

  final ProviderDetailsController controller;
  final List<String> bannerList;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Safety check for empty banner list
      if (bannerList.isEmpty) {
        return const SizedBox.shrink();
      }

      // Ensure currentIndex is valid
      final safeIndex = controller.currentIndex.value.clamp(
        0,
        bannerList.length - 1,
      );

      return SafeAnimatedSmoothIndicator(
        activeIndex: safeIndex,
        count: bannerList.length,
        effect: ExpandingDotsEffect(
          dotHeight: 8.h,
          dotWidth: 8.w,
          activeDotColor: AppColors.green,
          dotColor: Colors.grey[300]!,
        ),
        onDotClicked: (index) {
          // carouselController.animateTo(1.0, duration: Duration(seconds: 1), curve: );
        },
      );
    });
  }
}

// Providers details screen Rating container

class ProvidersDetailsScreenReview extends StatelessWidget {
  final double rating;
  final String review, imageUrl, time, name;
  const ProvidersDetailsScreenReview({
    super.key,
    required this.rating,
    required this.review,
    required this.imageUrl,
    required this.time,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: CachedNetworkImage(
              height: 48.h,
              width: 48.h,
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Center(child: CircularProgressIndicator(strokeWidth: 2)),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          10.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                5.ph,
                Row(
                  children: [
                    RatingBar.readOnly(
                      size: 18.r,
                      isHalfAllowed: true,
                      halfFilledIcon: Icons.star_half_outlined,
                      filledIcon: Icons.star,
                      emptyIcon: Icons.star_border,
                      halfFilledColor: AppColors.darkGreen,
                      initialRating: rating,
                      maxRating: 5,
                      emptyColor: AppColors.grey,
                      filledColor: AppColors.darkGreen,
                    ),
                    5.pw,
                    Text(
                      rating.toString(),
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                5.ph,
                Text(
                  review,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final List<String> bannerList = ['text 1', 'text 2', 'text 3'];

// Booking Summary Address Card

class AddressCard extends StatelessWidget {
  final String address, dateTime, phoneNumber;
  final String? serviceName;
  const AddressCard({
    super.key,
    required this.address,
    required this.dateTime,
    required this.phoneNumber,
    this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            icon: Icons.home_outlined,
            title: "Home",
            subtitle: address,
            onEdit: () {
              Get.back();
            },
          ),
          12.ph,
          if (serviceName != null && serviceName!.isNotEmpty)
            _infoRow(
              icon: Icons.miscellaneous_services,
              title: "Service",
              subtitle: serviceName!,
              onEdit: () {
                Get.back();
              },
            ),
          12.ph,
          _infoRow(
            icon: Icons.access_time,
            subtitle: dateTime,
            onEdit: () {
              Get.back();

              // handle date edit
            },
          ),
          10.ph,
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    String? title,
    required String subtitle,
    required VoidCallback onEdit,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(icon, size: 20.sp, color: Colors.black),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    color: Colors.black,
                  ),
                ),
              Text(
                subtitle,
                style: GoogleFonts.ubuntu(
                  fontSize: 12.sp,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onEdit,
          icon: Icon(Icons.edit_outlined, size: 18.sp, color: AppColors.green),
        ),
      ],
    );
  }
}

// Booking Summary (Payment Summary Container)

class PaymentSummaryWidget extends StatelessWidget {
  bool? isPaid;
  final int visitingCharge;

  PaymentSummaryWidget({
    super.key,
    this.isPaid = false,
    required this.visitingCharge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.paymentSummary,
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 16.h),
          // _row(
          //   AppLocalizations.of(context)!.itemTotal,
          //   "\$${itemTotal.toStringAsFixed(0)}",
          // ),
          _row(
            AppLocalizations.of(context)!.visitingCharg,
            "\$${visitingCharge.toStringAsFixed(0)}",
          ),
          // discount == 0
          //     ? SizedBox.shrink()
          //     : _row(
          //       AppLocalizations.of(context)!.itemDiscount,
          //       "-\$${discount.toStringAsFixed(0)}",
          //       color: Colors.green,
          //     ),
          // _row(
          //   AppLocalizations.of(context)!.serviceFee,
          //   "\$${serviceFee.toStringAsFixed(0)}",
          // ),
          Divider(height: 32, color: AppColors.green.withOpacity(0.2)),
          // _row(
          //   AppLocalizations.of(context)!.grandTotal,
          //   "\$${grandTotal.toStringAsFixed(0)}",
          //   isBold: true,
          // ),
          isPaid!
              ? _row(
                AppLocalizations.of(context)!.paymentStatus,
                "Paid",
                color: AppColors.green,
                isBold: true,
              )
              : SizedBox(),
          // : discount == 0
          // ? SizedBox.shrink()
          // : SizedBox.shrink(),
          16.ph,
          // if (discount > 0 && isPaid == false)
          //   Container(
          //     width: double.infinity,
          //     padding: const EdgeInsets.all(12),
          //     decoration: BoxDecoration(
          //       color: Colors.green.shade100,
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: Text(
          //       "${AppLocalizations.of(context)!.hurray}\$${discount.toStringAsFixed(0)} ${AppLocalizations.of(context)!.finalBill}",
          //       style: GoogleFonts.ubuntu(
          //         color: AppColors.green,
          //         fontWeight: FontWeight.w500,
          //         fontSize: 12.sp,
          //       ),
          //       textAlign: TextAlign.center,
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _row(String title, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.ubuntu(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.ubuntu(
              fontSize: 18.sp,
              color: color ?? Colors.black,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// Profile Setup Image upload Container

class ProfileSetupImageUploadContainer extends StatelessWidget {
  const ProfileSetupImageUploadContainer({super.key, required this.controller});

  final controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            Obx(
              () => GestureDetector(
                onTap: controller.pickImage,
                child: Container(
                  width: 80.r, // 2 * radius
                  height: 80.r, // 2 * radius
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green,
                  ),
                  child: ClipOval(
                    child:
                        controller.pickedImage.value != null
                            ? Image.file(
                              controller.pickedImage.value!,
                              fit: BoxFit.cover,
                            )
                            : _isSvgUrl(
                              "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png",
                            )
                            ? SvgPicture.network(
                              "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png",
                              fit: BoxFit.cover,
                              placeholderBuilder:
                                  (BuildContext context) => Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                            )
                            : CachedNetworkImage(
                              imageUrl:
                                  "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png",
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Icon(Icons.error),
                            ),
                  ),
                ),
              ),
            ),
            30.pw,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Profile Image",
                  style: GoogleFonts.ubuntu(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blackText,
                  ),
                ),
                8.ph,
                GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    alignment: Alignment.center,
                    height: 24.h,
                    width: 78.w,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      "+ Upload",
                      style: GoogleFonts.ubuntu(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          left: 48.w,
          bottom: 0,
          child: CircleAvatar(
            radius: 10.r,
            backgroundColor: AppColors.green,
            child: const Icon(Icons.add, color: Colors.white, size: 14),
          ),
        ),
      ],
    );
  }
}

// Bookings page [ Upcoming and Booking Tab ]

class CustomTabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomTabButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: title == "Ongoing bookings" ? 131.w : 140.w,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        height: 38.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: isSelected ? Colors.green.withOpacity(0.2) : Colors.white,
          border: isSelected ? Border.all(color: Colors.green) : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.ubuntu(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          overflow: TextOverflow.ellipsis, // optional
          maxLines: 1,
        ),
      ),
    );
  }
}

// Booking Details View Address Card

class BookingDetailsAddressCard extends StatelessWidget {
  final String date;
  final String time;
  final String address;

  const BookingDetailsAddressCard({
    super.key,
    required this.date,
    required this.time,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 117.h,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date row
          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: AppColors.grey,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                date,
                style: GoogleFonts.ubuntu(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Time row
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: AppColors.grey,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                time,
                style: GoogleFonts.ubuntu(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Address row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.grey,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  address,
                  style: GoogleFonts.ubuntu(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Booking Summary (Selected Plan Card)

class SelectedPlanForBookingSummary extends StatelessWidget {
  SelectedPlanForBookingSummary({super.key, this.planSelectionController});

  PlanSelectionController? planSelectionController;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 10.ph,
          Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 15.h),
                child: SvgPicture.asset(
                  AppVectors.svgSelectedPlan,
                  height: 15.h,
                  width: 15.h,
                ),
              ),
              10.pw,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.selectedPlan,
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    planSelectionController?.selectedPlan.value?.planType ?? "",
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.edit_outlined, color: AppColors.green),
              ),
            ],
          ),
          15.ph,
        ],
      ),
    );
  }
}

// Selected Plan for Booking Details

class SelectedPlanForBookingDetails extends StatelessWidget {
  final bool isBookingDetails;
  const SelectedPlanForBookingDetails({
    super.key,
    this.isBookingDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 10.ph,
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 15.h),
                child: SvgPicture.asset(
                  AppVectors.svgSelectedPlan,
                  height: 15.h,
                  width: 15.h,
                ),
              ),
              10.pw,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.selectedPlan,
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Basic",
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              !isBookingDetails
                  ? IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.edit_outlined, color: AppColors.green),
                  )
                  : SizedBox.shrink(),
            ],
          ),
          15.ph,
        ],
      ),
    );
  }
}

// Booking Page Card

class BookingCard extends StatelessWidget {
  final String imageUrl;
  final String serviceTitle;
  final String providerName;
  final String date;
  final String time;
  // final String price;
  final VoidCallback greyButtonOnTap;
  final VoidCallback greenButtonOnTap;
  final String greyButtonText, greenButtonText;
  final bool isShowCompleted;
  bool? isShowCancelButton;

  BookingCard({
    super.key,
    required this.imageUrl,
    required this.serviceTitle,
    required this.providerName,
    required this.date,
    required this.time,
    // required this.price,
    required this.greyButtonOnTap,
    required this.greenButtonOnTap,
    required this.greyButtonText,
    required this.greenButtonText,
    required this.isShowCompleted,
    this.isShowCancelButton = true,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      // margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Image, Title, and Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 95.h,
                width: 78.w,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceTitle,
                      style: GoogleFonts.ubuntu(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    2.ph,
                    Text(
                      "Provider: $providerName",
                      style: GoogleFonts.ubuntu(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 14.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          date,
                          style: GoogleFonts.ubuntu(
                            fontSize: 12.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          time,
                          style: GoogleFonts.ubuntu(
                            fontSize: 12.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              Text(
                isShowCompleted
                    ? "Completed"
                    : isShowCancelButton! && !isShowCompleted
                    ? ""
                    : "",
                style: GoogleFonts.ubuntu(
                  fontSize: isShowCompleted ? 14.sp : 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Divider(height: 24.h, thickness: 2.h),
          // Bottom row: Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cancel button
              !isShowCancelButton!
                  ? SizedBox.shrink()
                  : Expanded(
                    child: ElevatedButton(
                      onPressed: greyButtonOnTap,
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(110.w, 33.h),
                        foregroundColor: Colors.green,
                        backgroundColor: Colors.green.withOpacity(0.2),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        greyButtonText,
                        style: GoogleFonts.ubuntu(
                          fontSize: 14.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              !isShowCancelButton! ? SizedBox.shrink() : 40.pw,
              // View details button
              Expanded(
                child: ElevatedButton(
                  onPressed: greenButtonOnTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 8.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    greenButtonText,
                    style: GoogleFonts.ubuntu(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Rating page Header

class RatingHeader extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String subtitle;

  const RatingHeader({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          Container(
            width: 70.h,
            height: 70.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.1), // Placeholder color
            ),
            child: ClipOval(
              child:
                  _isSvgUrl(imageUrl)
                      ? SvgPicture.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        placeholderBuilder:
                            (BuildContext context) => Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                      )
                      : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
            ),
          ),

          SizedBox(width: 12.w),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.ubuntu(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: GoogleFonts.ubuntu(
                    fontSize: 12.sp,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Search Text Field for Search page

class SearchField extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  final searchCtrl = Get.find<SearchDBController>();

  SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTapOutside: (val) {
        FocusScope.of(context).unfocus();
      },
      controller: controller,
      onSubmitted: (value) async {
        if (value.trim().isNotEmpty) {
          // Save to local database for history
          searchCtrl.addSearch(value.trim());

          // Search providers and navigate to results
          await _performSearch(value.trim());

          controller.clear();
        }
      },
      style: GoogleFonts.ubuntu(fontSize: 14.sp),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: '${AppLocalizations.of(context)!.search}...',
        hintStyle: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 13.sp),
        prefixIcon: Icon(Icons.search, color: Colors.grey, size: 22.sp),
        suffixIcon: InkWell(
          onTap: () {
            Get.to(
              () => FilterView(),
              binding: BindingsBuilder(() => Get.put(FilterController())),
            );
          },
          child: Icon(
            Icons.filter_list_sharp,
            color: AppColors.green,
            size: 22.sp,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(
            color: AppColors.green.withOpacity(0.2),
            //const Color.fromARGB(255, 219, 240, 219)
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(
            color: AppColors.green.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
    );
  }

  Future<void> _performSearch(String keyword) async {
    try {
      // Get or create provider controller
      ProviderController providerController;
      if (Get.isRegistered<ProviderController>()) {
        providerController = Get.find<ProviderController>();
      } else {
        providerController = Get.put(ProviderController());
      }

      // Call search API
      await providerController.searchProviders(keyword: keyword);

      // Navigate to providers list view with search results
      Get.to(
        () => ProvidersListView(
          providers: providerController.providersList.toList(),
          serviceName: 'Search Results for "$keyword"',
          serviceId: null, // No service ID for search results
          isSearchResult: true, // Mark as search result
        ),
      );
    } catch (e) {
      print('Search error: $e');
      // Show error message to user
      Get.snackbar(
        'Search Error',
        'Failed to search providers. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

// Title text for Text Fileds title

Text titleText({required String title}) {
  return Text(
    title,
    style: GoogleFonts.ubuntu(fontSize: 14.sp, fontWeight: FontWeight.w500),
  );
}

// Manage address, Addreess Card

class AddressCardForManageAddress extends StatelessWidget {
  final String title;
  final String address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDefault;

  final VoidCallback? onSetDefault;

  const AddressCardForManageAddress({
    super.key,
    required this.title,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.isDefault,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isDefault ? AppColors.green : Colors.transparent,
          width: isDefault ? 2 : 0,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 24.w, bottom: isDefault ? 28.h : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.ubuntu(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  address,
                  style: GoogleFonts.ubuntu(
                    fontSize: 14.sp,
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(height: 1.h, color: AppColors.green.withOpacity(0.3)),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.green, size: 20.sp),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                } else if (value == 'set_default') {
                  // This callback should be handled in the parent via onEdit/onDelete or a new callback if needed
                  if (onSetDefault != null) onSetDefault!();
                }
              },
              itemBuilder: (context) {
                final items = <PopupMenuEntry<String>>[
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.black, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          "Edit",
                          style: GoogleFonts.ubuntu(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          "Delete",
                          style: GoogleFonts.ubuntu(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                ];
                if (!isDefault && onSetDefault != null) {
                  items.add(
                    PopupMenuItem(
                      value: 'set_default',
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.green,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "Set Default",
                            style: GoogleFonts.ubuntu(fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return items;
              },
            ),
          ),
          if (isDefault)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(16.r),
                    topLeft: Radius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Default address',
                  style: GoogleFonts.ubuntu(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Green Underlined Text field for Profile

class GreenUnderlineTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
   bool ?enabled = true;

   GreenUnderlineTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus(); // Keyboard hide karega
      },
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.ubuntu(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.blackText,
      ),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: 8.h,
          horizontal: 8.w,
        ), // Reduce vertical padding
        labelStyle: GoogleFonts.ubuntu(fontSize: 14.sp, color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.green.withOpacity(0.2)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.green, width: 2),
        ),
      ),
    );
  }
}

// COnsumer Homepage Header

class ConsumerHomepageHeader extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  const ConsumerHomepageHeader({super.key, this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    // Derive a short display name if an email is provided
    final String displayName = (name != null && name!.contains('@'))
        ? name!.split('@').first
        : (name ?? 'Azad Ali!');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $displayName',
                style: GoogleFonts.ubuntu(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Welcome back',
                style: GoogleFonts.ubuntu(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        imageContainerCircle(
          image: imageUrl ?? blankProfileImage,
          height: 60.h,
          width: 60.h,
        ),
      ],
    );
  }
}

class ReviewsWidgetCustom extends StatelessWidget {
  const ReviewsWidgetCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "${AppLocalizations.of(context)!.rating} (73)",
                style: GoogleFonts.ubuntu(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(Icons.star, color: AppColors.darkGreen, size: 20.sp),
              4.pw,
              Text(
                "4.5",
                style: GoogleFonts.ubuntu(
                  color: AppColors.grey,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          20.ph,
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ProvidersDetailsScreenReview(
                rating: 3.5,
                imageUrl:
                    "https://www.shutterstock.com/image-photo/head-shot-portrait-close-smiling-600nw-1714666150.jpg",
                name: "Abdul Rojak",
                review: "Good Service",
                time: "Today",
              );
            },
            separatorBuilder: (context, index) {
              return 10.ph;
            },
            itemCount: 3,
          ),
          70.ph,
        ],
      ),
    );
  }
}

// Provider homepage Container

Widget dashboardCard({
  required String icon,
  required String label,
  required String value,
  Color iconColor = Colors.grey,
}) {
  return Container(
    height: 100.h,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.green.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.05),
          spreadRadius: 1,
          blurRadius: 4,
        ),
      ],
    ),
    padding: EdgeInsets.all(18),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              icon,
              color: AppColors.green,
              height: 20.h,
              width: 20.h,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.blackText,
            ),
          ),
        ),
      ],
    ),
  );
}

// Provider Booking request card

class ProviderBookingRequestCard extends StatelessWidget {
  final bool isShowButtons;
  final BookingRequestModel? data;

  const ProviderBookingRequestCard({
    super.key,
    required this.isShowButtons,
    this.data,
  });

  /// Helper method to format address with proper null checks
  String _formatAddress(AddressModel address) {
    final parts = <String>[];
    
    // Check each field and add if not null/empty
    final addressLine = address.address.trim();
    if (addressLine.isNotEmpty && addressLine != 'null') {
      parts.add(addressLine);
    }
    
    final city = address.city.trim();
    if (city.isNotEmpty && city != 'null') {
      parts.add(city);
    }
    
    final state = address.state.trim();
    if (state.isNotEmpty && state != 'null') {
      parts.add(state);
    }
    
    final country = address.country.trim();
    if (country.isNotEmpty && country != 'null') {
      parts.add(country);
    }
    
    final postalCode = address.postalCode.trim();
    if (postalCode.isNotEmpty && postalCode != 'null') {
      parts.add(postalCode);
    }
    
    if (parts.isEmpty) {
      return "Address not available";
    }
    
    // Format: "address, city, state, country - postalCode"
    if (parts.length == 1) {
      return parts[0];
    }
    
    // If postal code is last, separate it with " - "
    if (postalCode.isNotEmpty && postalCode != 'null' && parts.last == postalCode) {
      final mainAddress = parts.take(parts.length - 1).join(", ");
      return "$mainAddress - $postalCode";
    }
    
    return parts.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingRequestController());
    return Card(
      //  margin: EdgeInsets.all(16.w),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top Row (Icon, Title, Tag)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    color: Colors.green.withOpacity(0.3),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.home_repair_service,
                      color: AppColors.green,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data?.service?.name ?? "Service",
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                if (data?.bookingId != null && data!.bookingId.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      "#${data!.bookingId.length > 15 ? data!.bookingId.substring(0, 15) + '...' : data!.bookingId}",
                      style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 12.h),

            /// Address
            if (data?.address != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 20.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      _formatAddress(data!.address!),
                      style: GoogleFonts.ubuntu(fontSize: 13.sp),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 20.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      "Address not available",
                      style: GoogleFonts.ubuntu(
                        fontSize: 13.sp,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),

            SizedBox(height: 8.h),

            /// Date & Time
            isShowButtons
                ? Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 18.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "${data?.bookingDate} - ${convertTo12HourFormat(data!.bookingTime)}",
                      style: GoogleFonts.ubuntu(fontSize: 13.sp),
                    ),
                  ],
                )
                : SizedBox.shrink(),

            SizedBox(height: 8.h),

            /// Person
            Row(
              children: [
                Icon(
                  Icons.person_outline_outlined,
                  size: 18.sp,
                  color: Colors.grey,
                ),
                SizedBox(width: 8.w),
                Text(
                  "${data?.consumer?.name}",
                  style: GoogleFonts.ubuntu(fontSize: 13.sp),
                ),
              ],
            ),

            /// Buttons
            if (isShowButtons)
              Column(
                children: [
                  Divider(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.acceptOrRejectBooking(
                              bookingId: data!.id.toString(),
                              status: 'accepted',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.accept,
                            style: GoogleFonts.ubuntu(fontSize: 14.sp),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            showConfirmDialog(
                              context: context,
                              title: "Reject",
                              message:
                                  "Are you sure you want to reject this request?",
                              onConfirm: () {
                                controller.acceptOrRejectBooking(
                                  bookingId: data!.id.toString(),
                                  status: 'rejected',
                                );
                              },
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.grey.withOpacity(0.1),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.r),
                              side: BorderSide(
                                color: AppColors.grey.withOpacity(0.3),
                              ),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.decline,
                            style: GoogleFonts.ubuntu(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// service card tile for provider booking page

class ServiceCardTile extends StatelessWidget {
  final String serviceName;
  final String userName;
  final String date;
  final String status;
  final Color statusColor;
  final Widget icon;

  const ServiceCardTile({
    super.key,
    required this.serviceName,
    required this.userName,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    print("Date $date");
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 0.w),

      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Icon or image
          Container(
            height: 40.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F5EC),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(child: icon),
          ),
          12.horizontalSpace,
          // Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        serviceName,
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        status == "start"
                            ? "In Progress"
                            : status.capitalizeFirst!,
                        style: GoogleFonts.ubuntu(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                6.verticalSpace,
                Row(
                  children: [
                    Icon(Icons.person, size: 14.sp, color: Colors.grey),
                    4.horizontalSpace,
                    Flexible(
                      child: Text(
                        userName,
                        style: GoogleFonts.ubuntu(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        date,
                        style: GoogleFonts.ubuntu(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showCompleteBookingConfirmation(BuildContext context, String bookingId) {
  final controller = Get.find<ProviderCompleteWorkController>();
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Complete Booking",
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          "Are you sure you want to mark this booking as completed?",
          style: GoogleFonts.ubuntu(
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Cancel",
              style: GoogleFonts.ubuntu(
                color: Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
          ),
          Obx(
            () => controller.isLoading.value
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.green,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: () async {
                      await controller.completeWork(bookingId: bookingId);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      "Complete",
                      style: GoogleFonts.ubuntu(
                        color: AppColors.green,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      );
    },
  );
}

// This is comment section for booking details custom widgets

// Booking Details Custom Widgets

class BookingStatusBadge extends StatelessWidget {
  final String status;

  const BookingStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: AppColors.green, size: 16.sp),
          SizedBox(width: 4.w),
          Text(
            status,
            style: GoogleFonts.ubuntu(color: AppColors.green, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}

class BookingInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const BookingInfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.grey, size: 20.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.ubuntu(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class BookingSectionTitle extends StatelessWidget {
  final String title;

  const BookingSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.ubuntu(fontSize: 18.sp, fontWeight: FontWeight.bold),
    );
  }
}

class ProviderActionButtons extends StatelessWidget {
  final VoidCallback? onDirectionsPressed;
  final VoidCallback? onWayPressed;

  const ProviderActionButtons({
    super.key,
    this.onDirectionsPressed,
    this.onWayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onDirectionsPressed,
            icon: const Icon(Icons.directions),
            label: Text(
              'Directions',
              style: GoogleFonts.ubuntu(
                color: AppColors.green,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.green,
              side: BorderSide(color: AppColors.green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onWayPressed,
            icon: const Icon(Icons.local_shipping_outlined),
            label: Text(
              'On my way',
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WorkControlButtons extends StatelessWidget {
  final bool isStarted;
  final bool isComplete;
  final bool canStart;
  final bool canComplete;
  final VoidCallback? onStartWork;
  final VoidCallback? onMarkComplete;

  const WorkControlButtons({
    super.key,
    required this.isStarted,
    required this.isComplete,
    required this.canStart,
    required this.canComplete,
    this.onStartWork,
    this.onMarkComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canStart ? onStartWork : null,
            icon:
                isStarted
                    ? Icon(Icons.check, size: 20.sp)
                    : const SizedBox.shrink(),
            label: Text(
              isStarted ? 'Work Started' : 'Start Work',
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isStarted
                      ? AppColors.green.withOpacity(0.8)
                      : AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canComplete ? onMarkComplete : null,
            icon:
                isComplete
                    ? Icon(Icons.check, size: 20.sp)
                    : const SizedBox.shrink(),
            label: Text(
              isComplete ? 'Work Completed' : 'Mark Complete',
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isComplete
                      ? AppColors.green.withOpacity(0.8)
                      : (isStarted ? AppColors.green : Colors.grey),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NoteItem extends StatelessWidget {
  final String name;
  final String date;
  final String note;
  final List<String> imageUrls;

  const NoteItem({
    super.key,
    required this.name,
    required this.date,
    required this.note,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: Theme.of(context).textTheme.titleMedium),
          Text(
            date,
            style: GoogleFonts.ubuntu(fontSize: 12.sp, color: AppColors.grey),
          ),
          SizedBox(height: 8.h),
          Text(note),
          if (imageUrls.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              'Attached files',
              style: GoogleFonts.ubuntu(
                fontSize: 14.sp,
                color: AppColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return imageContainer(image: imageUrls[index]);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class AddNoteSection extends StatelessWidget {
  final VoidCallback? onAddNote;
  final VoidCallback? onAddPhoto;

  const AddNoteSection({super.key, this.onAddNote, this.onAddPhoto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  onAddNote ??
                  () {
                    // Import the NoteViewModal at the top of the file where this widget is used
                    // NoteViewModal.show(context);
                    if (onAddNote != null) {
                      onAddNote!();
                    }
                  },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.green,
                side: BorderSide(color: AppColors.green),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add Note'),
            ),
          ),
          SizedBox(width: 16.w),
          IconButton(
            onPressed:
                onAddPhoto ??
                () {
                  // Import the NoteViewModal at the top of the file where this widget is used
                  // NoteViewModal.show(context);
                  if (onAddPhoto != null) {
                    onAddPhoto!();
                  }
                },
            style: IconButton.styleFrom(
              backgroundColor: AppColors.green.withOpacity(0.1),
              foregroundColor: AppColors.green,
            ),
            icon: const Icon(Icons.camera_alt_outlined),
          ),
        ],
      ),
    );
  }
}

class ConsumerBookingHeader extends StatelessWidget {
  final BookingDetailsModelClass? bookingDetails;
  final VoidCallback? onFavoriteTap;

  const ConsumerBookingHeader({
    super.key,
    required this.bookingDetails,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProviderDetailsScreenHeader(
          onFavoriteTap: onFavoriteTap,
          isFavourite: bookingDetails?.provider?.isFavorite ?? false,
          name: bookingDetails?.provider?.name ?? '-',
          rating: bookingDetails?.provider?.averageRating ?? '0',
          category: bookingDetails?.service?.name ?? '-',
          imageUrl:
              bookingDetails?.provider?.avatar ?? blankProfileImage,
        ),
        SizedBox(height: 24.h),
        BookingSectionTitle(title: 'Scheduled Time'),
        SizedBox(height: 16.h),
        BookingInfoRow(
          icon: Icons.calendar_today_outlined,
          text:
              '${formatDate(bookingDetails?.bookingDate)} - ${convertTo12HourFormat(bookingDetails?.bookingTime)}',
        ),
      ],
    );
  }
}

class ProviderBookingHeader extends StatelessWidget {
  final BookingDetailsModelClass? bookingDetails;
  final VoidCallback? onDirections;
  final VoidCallback? onWay;

  const ProviderBookingHeader({
    super.key,
    required this.bookingDetails,
    this.onDirections,
    this.onWay,
  });

  /// Build formatted address string, handling empty values gracefully
  String _buildAddressText() {
    final address = bookingDetails?.address;
    if (address == null) return 'Address not available';
    
    final parts = <String>[];
    
    // First line: street address
    final streetAddress = address.address;
    if (streetAddress != null && streetAddress.isNotEmpty && streetAddress != 'null') {
      parts.add(streetAddress);
    }
    
    // Second line: city, country, postal code
    final secondLineParts = <String>[];
    
    final city = address.city;
    if (city != null && city.isNotEmpty && city != 'null') {
      secondLineParts.add(city);
    }
    
    final country = address.country;
    if (country != null && country.isNotEmpty && country != 'null') {
      secondLineParts.add(country);
    }
    
    final postalCode = address.postalCode;
    if (postalCode != null && postalCode.isNotEmpty && postalCode != 'null') {
      secondLineParts.add(postalCode);
    }
    
    if (secondLineParts.isNotEmpty) {
      parts.add(secondLineParts.join(', '));
    }
    
    if (parts.isEmpty) {
      return 'Address not available';
    }
    
    return parts.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visit for ${bookingDetails?.consumer?.name ?? 'N/A'}',
          style: GoogleFonts.ubuntu(
            color: AppColors.blackText,
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        BookingInfoRow(
          icon: Icons.location_on_outlined,
          text: _buildAddressText(),
        ),
        SizedBox(height: 24.h),
        ProviderActionButtons(
          onDirectionsPressed: onDirections,
          onWayPressed: onWay,
        ),
        SizedBox(height: 24.h),
        BookingSectionTitle(title: 'Scheduled Time'),
        SizedBox(height: 16.h),
        BookingInfoRow(
          icon: Icons.calendar_today_outlined,
          text:
              '${formatDate(bookingDetails?.bookingDate)} - ${convertTo12HourFormat(bookingDetails?.bookingTime)}',
        ),
      ],
    );
  }
}

class ProviderReviewsWidget extends StatelessWidget {
  final ProviderHomeScreenController homeController;

  const ProviderReviewsWidget({super.key, required this.homeController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Obx(() {
            final ratingCount = homeController.ratingCount.value;
            final averageRating = homeController.averageRating.value;

            return Row(
              children: [
                Text(
                  "${AppLocalizations.of(context)!.rating} (${ratingCount.toStringAsFixed(0)})",
                  style: GoogleFonts.ubuntu(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Icon(Icons.star, color: AppColors.darkGreen, size: 20.sp),
                4.pw,
                Text(
                  double.parse(averageRating).toStringAsFixed(1),
                  style: GoogleFonts.ubuntu(
                    color: AppColors.grey,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            );
          }),
          20.ph,
          Obx(() {
            final ratings = homeController.ratings;
            final isLoading = homeController.isLoading.value;

            if (isLoading) {
              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ).withShimmerAi(loading: true);
                },
                separatorBuilder: (context, index) => 10.ph,
                itemCount: 3,
              );
            }

            if (ratings.isEmpty) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  "No reviews yet",
                  style: GoogleFonts.ubuntu(
                    color: AppColors.grey,
                    fontSize: 14.sp,
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final rating = ratings[index];
                return ProvidersDetailsScreenReview(
                  rating: rating.stars.toDouble(),
                  imageUrl:
                      rating.consumer.avatar ??
                      "https://www.shutterstock.com/image-photo/head-shot-portrait-close-smiling-600nw-1714666150.jpg",
                  name: rating.consumer.name,
                  review: rating.review,
                  time:
                      "Today", // Since we don't have createdAt in the model, using placeholder
                );
              },
              separatorBuilder: (context, index) => 10.ph,
              itemCount: ratings.length > 3 ? 3 : ratings.length,
            );
          }),
          70.ph,
        ],
      ),
    );
  }
}




// Icon data

