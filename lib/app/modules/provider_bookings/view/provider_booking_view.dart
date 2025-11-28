import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_completed_booking_details/view/booking_details_view.dart';
import 'package:ustahub/data/response/status.dart';

class ProviderBookingView extends GetView<ProviderBookingController> {
  const ProviderBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final providerController = Get.put(ProviderBookingController());
    Get.put(BookingHistoryController());

    // Ensure "Not Started" is selected and API is called when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (providerController.selectedTab.value != 0) {
        providerController.selectTab(0);
      }
      // Always call the not_started API when this view is accessed
      providerController.providerBookingApi("not_started");
    });

    return Scaffold(
      appBar: CustomAppBar(title: "Bookings"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 13.w),
        child: Column(
          children: [
            SizedBox(
              height: 50.h,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(
                  () => Row(
                    children: [
                      CustomTabButton(
                        title: "Not Started",
                        isSelected: providerController.selectedTab.value == 0,
                        onTap: () {
                          providerController.selectTab(0);
                          providerController.providerBookingApi("not_started");
                        },
                      ),
                      10.horizontalSpace,
                      CustomTabButton(
                        title: "In progress ",
                        isSelected: providerController.selectedTab.value == 1,
                        onTap: () {
                          providerController.selectTab(1);
                          providerController.providerBookingApi("ongoing");
                        },
                      ),
                      10.horizontalSpace,
                      CustomTabButton(
                        title: "Completed Bookings",
                        isSelected: providerController.selectedTab.value == 2,
                        onTap: () {
                          providerController.selectTab(2);
                          providerController.providerBookingApi("completed");
                        },
                      ),
                      10.horizontalSpace,
                      CustomTabButton(
                        title: "History",
                        isSelected: providerController.selectedTab.value == 3,
                        onTap: () {
                          providerController.selectTab(3);
                          final historyController =
                              Get.find<BookingHistoryController>();
                          historyController.fetchBookingHistory();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (providerController.selectedTab.value == 3) {
                  return _buildHistoryTab();
                }
                switch (providerController.rxRequestStatus.value) {
                  case Status.LOADING:
                    return ServiceProviderShimmerList();
                  case Status.ERROR:
                    return Center(child: Text(providerController.error.value));
                  case Status.COMPLETED:
                    if (providerController.providerBookingList.value.bookings ==
                            null ||
                        providerController
                            .providerBookingList
                            .value
                            .bookings!
                            .isEmpty) {
                      return Center(
                        child: Text(
                          "There are no bookings yet.",
                          style: GoogleFonts.ubuntu(
                            fontSize: 16.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount:
                          providerController
                              .providerBookingList
                              .value
                              .bookings!
                              .length,
                      itemBuilder: (context, index) {
                        final booking =
                            providerController
                                .providerBookingList
                                .value
                                .bookings![index];
                        return InkWell(
                          onTap: () {
                            if (providerController.selectedTab.value == 0) {
                              Get.to(
                                () => BookingDetailsView(
                                  pageName: "Not Started",
                                  bookingId: booking.id,
                                ),
                              );
                            } else if (providerController.selectedTab.value ==
                                1) {
                              Get.to(
                                () => BookingDetailsView(
                                  pageName: "In Progress",
                                  bookingId: booking.id,
                                ),
                              );
                            } else if (providerController.selectedTab.value ==
                                2) {
                              Get.to(
                                () => BookingDetailsView(
                                  pageName: "Completed",
                                  bookingId: booking.id,
                                ),
                              );
                            }else {
                              // Get.to(
                              //   () => BookingDetailsView(
                              //     pageName: "History",
                              //     bookingId: booking.id,
                              //   ),
                              // );
                            }
                          },
                          child: ServiceCardTile(
                            serviceName: booking.service?.name ?? '',
                            userName: booking.consumer?.name ?? '',
                            date:
                                "${formatDate(booking.bookingDate ?? "")}- ${convertTo12HourFormat(booking.bookingTime)}",
                            status: booking.status?.capitalizeFirst ?? '',
                            statusColor:
                                providerController.selectedTab.value == 0
                                    ? Colors.blue
                                    : providerController.selectedTab.value == 1
                                    ? Colors.orange
                                    : AppColors.green,
                            icon: Image.network(
                              booking.consumer?.profilePhotoUrl ??
                                  blankProfileImage,
                            ),
                          ),
                        );
                      },
                    );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final BookingHistoryController historyController =
        Get.find<BookingHistoryController>();

    return Obx(() {
      if (historyController.isLoading.value) {
        return ServiceProviderShimmerList();
      }

      if (historyController.isError.value) {
        return Center(child: Text(historyController.errorMessage.value));
      }

      if (historyController.isEmpty) {
        return Center(
          child: Text(
            "No booking history found.",
            style: GoogleFonts.ubuntu(fontSize: 16.sp, color: AppColors.grey),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await historyController.fetchBookingHistory();
        },
        child: ListView.builder(
          itemCount: historyController.bookings.length,
          itemBuilder: (context, index) {
            final booking = historyController.bookings[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.service.name,
                          style: GoogleFonts.ubuntu(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: booking.statusColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          booking.status.capitalizeFirst!,
                          style: GoogleFonts.ubuntu(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  8.verticalSpace,
                  Row(
                    children: [
                      Icon(Icons.person, size: 16.sp, color: AppColors.grey),
                      4.horizontalSpace,
                      Text(
                        booking.counterpartyName,
                        style: GoogleFonts.ubuntu(
                          fontSize: 14.sp,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  6.verticalSpace,
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16.sp,
                        color: AppColors.grey,
                      ),
                      4.horizontalSpace,
                      Text(
                        booking.formattedDate,
                        style: GoogleFonts.ubuntu(
                          fontSize: 14.sp,
                          color: AppColors.grey,
                        ),
                      ),
                      16.horizontalSpace,
                      Icon(
                        Icons.access_time,
                        size: 16.sp,
                        color: AppColors.grey,
                      ),
                      4.horizontalSpace,
                      Text(
                        booking.formattedTime,
                        style: GoogleFonts.ubuntu(
                          fontSize: 14.sp,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

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
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 18.w),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE6F5EC) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.green : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
