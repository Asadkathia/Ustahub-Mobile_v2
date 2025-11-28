import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/common_model_class/ProviderListModelClass.dart';
import 'package:ustahub/app/modules/consumer_homepage/view/all_services_view.dart';
import 'package:ustahub/app/modules/providers_list/view/providers_list_view.dart';

class ConsumerHomepage extends StatelessWidget {
  ConsumerHomepage({super.key});

  final ConsumerHomepageController controller = Get.put(
    ConsumerHomepageController(),
  );
  final CarouselController carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    controller.providerController.initializeLocation(); // Ensure location is initialized
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomSearchBar(),

              /// Carousel
              Obx(
                () =>
                    controller.bannerController.isLoading.value
                        ? Container(
                          height: 170.h,
                          decoration: BoxDecoration(color: Colors.grey[300]),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : controller.bannerController.bannersList.isNotEmpty
                        ? CarouselSlider(
                          items:
                              controller.bannerController.bannersList.map((
                                banner,
                              ) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.network(
                                      banner.image ?? '',
                                      width: double.infinity,
                                      height: 170.h,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                          options: CarouselOptions(
                            height: 170.h,
                            autoPlay: true,
                            viewportFraction: 1.0, // Full width
                            onPageChanged: (index, reason) {
                              controller.updateIndex(index);
                            },
                          ),
                        )
                        : Container(
                          height: 170.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.noBannersAvailable,
                              style: GoogleFonts.ubuntu(fontSize: 16.sp),
                            ),
                          ),
                        ),
              ),

              10.ph,

              /// Dot indicator with GetX
              Obx(
                () => CarousalDotIndicator(
                  controller: controller,
                  bannerList:
                      controller.bannerController.bannersList
                          .map((banner) => banner.image ?? '')
                          .toList(),
                ),
              ),
              10.ph,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        titleText(
                          title: AppLocalizations.of(context)!.services,
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(
                              () => AllServicesView(
                                services:
                                    controller
                                        .servicesController
                                        .serviceCategories,
                              ),
                            );
                            // Get.to(()=> ProvidersListView(providers: controller.providerController.providersList, serviceName: ));
                          },
                          child: Text(
                            AppLocalizations.of(context)!.viewAll,
                            style: GoogleFonts.ubuntu(
                              color: AppColors.green,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () =>
                          controller.servicesController.isLoading.value
                              ? const CategoriesGridShimmer()
                              : CategoriesGridView(
                                onCategoryTap: (val) {
                                  Get.to(
                                    () => ProvidersListView(
                                      providers:
                                          controller
                                              .providerController
                                              .providersList,
                                      serviceName: val.name!,
                                      serviceId:
                                          val.id.toString(), // Pass service ID
                                    ),
                                  );
                                },
                                data:
                                    controller
                                        .servicesController
                                        .serviceCategories,
                              ),
                    ),
                    10.ph,
                    titleText(
                      title: AppLocalizations.of(context)!.topServiceProviders,
                    ),
                    10.ph,
                    Obx(
                      () =>
                          controller.providerController.isLoading.value
                              ? const ServiceProviderShimmerList()
                              : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount:
                                    controller
                                                .providerController
                                                .providersList
                                                .length >=
                                            5
                                        ? 5
                                        : controller
                                            .providerController
                                            .providersList
                                            .length,
                                itemBuilder: (context, index) {
                                  final data =
                                      controller
                                          .providerController
                                          .providersList
                                          .reversed
                                          .toList()[index];
                                  final servicesString = (data.services ?? [])
                                      .map((s) => s.name ?? '')
                                      .where((name) => name.isNotEmpty)
                                      .join(', ');
                                  return ServiceProviderCard(
                                    onFavoriteTap: () async {
                                      // Toggle locally for instant UI feedback
                                      final realIndex =
                                          controller
                                              .providerController
                                              .providersList
                                              .length -
                                          1 -
                                          index;
                                      final current =
                                          controller
                                              .providerController
                                              .providersList[realIndex];
                                      controller
                                              .providerController
                                              .providersList[realIndex] =
                                          ProvidersListModelClass(
                                            id: current.id,
                                            name: current.name,
                                            avatar: current.avatar,
                                            isFavorite:
                                                !(current.isFavorite ?? false),
                                            averageRating:
                                                current.averageRating,
                                            totalRatings: current.totalRatings,
                                            services: current.services,
                                          );
                                      // Call API
                                      final token = await Sharedprefhelper.getToken();
                                      if(token != null && token.isNotEmpty) {
                                          await controller.favouriteProvider
                                              .favouriteToggle(
                                                id: data.id.toString(),
                                              );
                                      }                                   
                                    },
                                    isFavorite: data.isFavorite ?? false,
                                    onTap: () {
                                      Get.to(
                                        () => ProviderDetailsScreen(
                                          id: data.id.toString(),
                                        ),
                                      );
                                    },
                                    starValue: data.averageRating ?? 0.0,
                                    name: data.name ?? "",
                                    category: servicesString,
                                    // amount:
                                    //     data.plans?.isNotEmpty ?? false
                                    //         ? double.tryParse(
                                    //               data.plans?.first.planPrice ??
                                    //                   '',
                                    //             ) ??
                                    //             0
                                    //         : 0,
                                    imageUrl: data.avatar ?? blankProfileImage,
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
