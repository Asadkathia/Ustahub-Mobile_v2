import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/manage_address/controller/manage_address_controller.dart';
import 'package:ustahub/app/modules/provider_details/model_class/provider_details_model_class.dart';
import 'package:ustahub/components/service_radio_buttons.dart';

class ProviderDetailsScreen extends StatefulWidget {
  final String id;
  const ProviderDetailsScreen({super.key, required this.id});

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  // Use tag to create unique instance per provider ID
  late final ProviderDetailsController controller;
  final plansController = Get.put(PlanSelectionController(), permanent: true);
  final manageAddresas = Get.put(ManageAddressController(), permanent: true);

  @override
  void initState() {
    super.initState();
    // Create or find controller with provider-specific tag
    final tag = 'provider_${widget.id}';
    if (Get.isRegistered<ProviderDetailsController>(tag: tag)) {
      controller = Get.find<ProviderDetailsController>(tag: tag);
      // Clear old data and reload
      controller.providerDetails.value = null;
    } else {
      controller = Get.put(ProviderDetailsController(), tag: tag);
    }
    controller.getProviderById(widget.id);
  }

  @override
  void dispose() {
    // Clean up provider-specific controller when leaving
    final tag = 'provider_${widget.id}';
    if (Get.isRegistered<ProviderDetailsController>(tag: tag)) {
      Get.delete<ProviderDetailsController>(tag: tag);
    }
    super.dispose();
  }

  final favouriteProvider = Get.put(FavouriteProviderController());

  void _toggleFavorite() async {
    final details = controller.providerDetails.value;
    if (details?.provider == null) return;
    // Update UI instantly
    final current = details?.provider;
    if (current == null || details == null) return;
    controller.providerDetails.value = ProviderDetailsModelClass(
      provider: ProviderModel(
        id: current.id,
        name: current.name,
        email: current.email,
        phone: current.phone,
        avatar: current.avatar,
        bio: current.bio,
        isFavorite: !(current.isFavorite ?? false),
        isVerified: current.isVerified,
        businessName: current.businessName,
        averageRating: current.averageRating,
        services: current.services,
        plans: current.plans,
        addresses: current.addresses,
      ),
      overview: details.overview,
    );
    // Call API
    await favouriteProvider.favouriteToggle(id: current.id?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: InkWell(
        onTap: () async {
          final bool isLoggedIn = SupabaseClientService.isAuthenticated ||
              await Sharedprefhelper.hasSupabaseSession();
          if (!mounted) return;
          if (!isLoggedIn) {
              CustomToast.error("Please login to continue");
            Get.to(() => OnboardingView());
            return;
          }

          final provider = controller.providerDetails.value?.provider;
          final services = provider?.services ?? [];
          if (services.isEmpty) {
            CustomToast.error("No services available for this provider yet.");
            return;
          }

              showModalBottomSheet(
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
            ),
            context: context,
            builder: (context) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.9, 
                minChildSize: 0.3,
                maxChildSize: 1.0,
                builder: (_, controll) => CheckoutModalBottomSheet(
                      providerId: widget.id,
                  serviceId: services.first.id ?? '',
                    ),
              );
            },
          );
        },
        child: Obx(
          () => Container(
            height: 50.h,
            width: double.infinity,
            color: AppColors.green,
            alignment: Alignment.center,
            child: Text(
              () {
                final serviceName =
                    plansController.selectedService.value?.name ?? "";

                if (serviceName.isNotEmpty) {
                  return '${AppLocalizations.of(context)!.book} - $serviceName';
                } else {
                  return AppLocalizations.of(context)!.book;
                }
              }(),
              style: GoogleFonts.ubuntu(
                fontSize: 20.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final servicesString =
            (controller.providerDetails.value?.provider?.services ?? [])
                .map((s) => s.name ?? '')
                .where((name) => name.isNotEmpty)
                .join(', ');
        return controller.isLoading.value
            ? Center(child: CircularProgressIndicator(color: AppColors.green))
            : SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 13.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              5.ph,
                              ProviderDetailsScreenHeader(
                                isFavourite:
                                    controller
                                        .providerDetails
                                        .value
                                        ?.provider
                                        ?.isFavorite ??
                                    false,
                                name:
                                    controller
                                        .providerDetails
                                        .value
                                        ?.provider
                                        ?.name ??
                                    "Provider Name",
                                rating:
                                    double.tryParse(
                                      controller
                                              .providerDetails
                                              .value
                                              ?.provider
                                              ?.averageRating ??
                                          "0.0",
                                    ).toString(),
                                category: servicesString,
                                imageUrl:
                                    controller
                                        .providerDetails
                                        .value
                                        ?.provider
                                        ?.avatar ??
                                    blankProfileImage,
                                onFavoriteTap: _toggleFavorite,
                              ),
                              20.ph,
                              IntroductionContainerProviderDetailsPage(
                                introTitle:
                                    controller
                                        .providerDetails
                                        .value
                                        ?.provider
                                        ?.bio ??
                                    "Not Available",
                              ),

                              15.ph,
                              if (controller.providerDetails.value != null)
                              ProviderDetailsOverviewContainer(
                                providerDetails:
                                    controller.providerDetails.value!,
                              ),
                              15.ph,

                              Text(
                                "Select Service",
                                style: GoogleFonts.ubuntu(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              15.ph,
                              // Service radio buttons here
                              Obx(() {
                                return ServiceRadioButtons(
                                  services:
                                      controller
                                          .providerDetails
                                          .value
                                          ?.provider
                                          ?.services ??
                                      [],
                                  controlle: controller,
                                );
                              }),
                              15.ph,
                              // Text(
                              //   AppLocalizations.of(context)!.choosePlan,
                              //   style: GoogleFonts.ubuntu(
                              //     fontSize: 14.sp,
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
                              // 15.ph,

                              // Obx(() {
                              //   final allPlans =
                              //       controller
                              //           .providerDetails
                              //           .value
                              //           ?.provider
                              //           ?.plans ??
                              //       [];
                              //   final filteredPlans = plansController
                              //       .getPlansForSelectedService(allPlans);
                              //   return PlanRadioButtons(
                              //     plansss: filteredPlans,
                              //     controlle: controller,
                              //   );
                              // }),
                              // 15.ph,
                              // Obx(() {
                              //   final selectedPlan =
                              //       plansController.selectedPlan.value;
                              //   if (selectedPlan == null) {
                              //     return SizedBox.shrink(); // Or a placeholder/info widget
                              //   }
                              //   return PlansFeaturesContainer(
                              //     title: selectedPlan.planTitle ?? '',
                              //     amount: selectedPlan.planPrice ?? '',
                              //     features: selectedPlan.includedService ?? [],
                              //   );
                              // }),
                              15.ph,
                              // Text(
                              //   AppLocalizations.of(context)!.photosAndVideos,
                              //   style: GoogleFonts.ubuntu(
                              //     fontSize: 14.sp,
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
                              // 15.ph,
                              // CarouselSlider(
                              //   items:
                              //       bannerList.map((text) {
                              //         return Container(
                              //           margin: EdgeInsets.symmetric(
                              //             horizontal: 3.w,
                              //           ),
                              //           decoration: BoxDecoration(
                              //             color: Colors.blueGrey,
                              //             borderRadius: BorderRadius.circular(
                              //               10.r,
                              //             ),
                              //           ),
                              //           child: Center(
                              //             child: Text(
                              //               text,
                              //               style: GoogleFonts.ubuntu(
                              //                 fontSize: 16.sp,
                              //               ),
                              //             ),
                              //           ),
                              //         );
                              //       }).toList(),
                              //   options: CarouselOptions(
                              //     height: 170.h,
                              //     autoPlay: false,
                              //     viewportFraction: 1.0, // Full width
                              //     onPageChanged: (index, reason) {
                              //       controller.updateIndex(index);
                              //     },
                              //   ),
                              // ),
                              // 10.ph,
                              // Align(
                              //   alignment: Alignment.center,
                              //   child: ProviderCarousalDotIndicator(
                              //     controller: controller,
                              //     bannerList: bannerList,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        15.ph,
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 13.w,
                            vertical: 10.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.rating,
                                style: GoogleFonts.ubuntu(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              20.ph,
                              // Real ratings data from API
                              Obx(() {
                                final ratingsController =
                                    controller.ratingsController;

                                if (ratingsController.isLoadingRatings.value) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (ratingsController.isRatingsError.value) {
                                  return Center(
                                    child: Text(
                                      'Failed to load ratings',
                                      style: GoogleFonts.ubuntu(
                                        fontSize: 12.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                }

                                final latestRatings =
                                    ratingsController.latestFiveRatings;

                                if (latestRatings.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'No ratings yet',
                                      style: GoogleFonts.ubuntu(
                                        fontSize: 12.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final ratingReversed = latestRatings.reversed.toList();
                                    final rating = ratingReversed[index];
                                    return ProvidersDetailsScreenReview(
                                      rating: rating.starRating,
                                      imageUrl: rating.consumer.avatar ??
                                          blankProfileImage,
                                      name: rating.consumer.name,
                                      review:
                                          rating.review.isEmpty
                                              ? ""
                                              : rating.review,
                                      time: rating.formattedDate,
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return 10.ph;
                                  },
                                  itemCount: latestRatings.length,
                                );
                              }),
                              70.ph,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Positioned(
                  //   right: 10.w,
                  //   top: 70.h,
                  //   child: Image.asset(
                  //     "assets/vectors/gif_chat.gif",
                  //     height: 40.h,
                  //     width: 40.h,
                  //   ),
                  // ),
                  // Positioned(
                  //   bottom: 20.h,
                  //   right: 16.w,
                  //   child: FloatingActionButton.extended(
                  //     onPressed: () {
                  //       // Navigate to chat
                  //     },
                  //     label: Text(
                  //       AppLocalizations.of(context)!.chatNow,
                  //       style: GoogleFonts.ubuntu(
                  //         color: Colors.white,
                  //         fontSize: 14.sp,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //     icon: Icon(Icons.chat, color: Colors.white),
                  //     backgroundColor: AppColors.green,
                  //   ),
                  // ),
                ],
              ),
            );
      }),
    );
  }
}
