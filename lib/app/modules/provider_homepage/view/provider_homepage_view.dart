import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/booking_request/view/booking_request_view.dart';
import 'package:ustahub/app/modules/provider_calendar/view/provider_calendar_view.dart';
import 'package:ustahub/app/modules/provider_homepage/controller/provider_home_screen_controller.dart';

class ProviderHomepageView extends StatelessWidget {
  const ProviderHomepageView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProviderProfileController());
    final homeController = Get.put(ProviderHomeScreenController());

    profileController.fetchProfile();
    homeController.fetchProviderHomeScreenData();
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh all APIs called on homepage
            await Future.wait([
              profileController.fetchProfile(),
              homeController.fetchProviderHomeScreenData(),
            ]);
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 13.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                10.ph,
                Obx(() {
                  final user = profileController.userProfile.value;
                  if (user != null) {
                    return ConsumerHomepageHeader(
                      name: user.name,
                      imageUrl: user.avatar,
                    ).withShimmerAi(loading: profileController.isLoading.value);
                  }
                  return ConsumerHomepageHeader().withShimmerAi(
                    loading: profileController.isLoading.value,
                  );
                }),
                30.ph,
                Text(
                  AppLocalizations.of(context)!.overview,
                  style: GoogleFonts.ubuntu(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                10.ph,
                Obx(
                  () => GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.5,
                    ),
                    itemCount:
                        homeController.isLoading.value
                            ? 2
                            : _getDashboardItems(homeController).length,
                    itemBuilder: (context, index) {
                      if (homeController.isLoading.value) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ).withShimmerAi(loading: true);
                      }

                      final items = _getDashboardItems(homeController);
                      if (index >= items.length) return SizedBox.shrink();

                      final item = items[index];
                      return InkWell(
                        onTap: () {
                          if (index == 0) {
                            Get.to(() => BookingRequestView());
                          } else if (index == 1) {
                            Get.to(() => ProviderCalendarView());
                          }
                        },
                        child: dashboardCard(
                          icon: item['icon'],
                          label: item['label'],
                          value: item['value'],
                          iconColor: item['iconColor'],
                        ),
                      );
                    },
                  ),
                ),
                // 5.ph,
                // dashboardCard(icon: AppVectors.svgChat, label: AppLocalizations.of(Get.context!)!.activeChats, value: "4"),
                30.ph,
                ProviderReviewsWidget(homeController: homeController),
              ],
            ),
          ),
        ),
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
        'iconColor': AppColors.green,
      },
      {
        'icon': AppVectors.svgCalendar,
        'label': AppLocalizations.of(Get.context!)!.calendar,
        'value': "${data.overview.calendar}",
        'iconColor': AppColors.green,
      },
    ];
  }

  List<Map<String, dynamic>> _getDefaultDashboardItems() {
    return [
      {
        'icon': AppVectors.svgBookingRequests,
        'label': AppLocalizations.of(Get.context!)!.bookingRequest,
        'value': "0",
        'iconColor': AppColors.green,
      },
      {
        'icon': AppVectors.svgCalendar,
        'label': AppLocalizations.of(Get.context!)!.calendar,
        'value': "0",
        'iconColor': AppColors.green,
      },
    ];
  }
}
