import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_completed_booking_details/view/booking_details_view.dart';
import 'package:ustahub/app/ui_v2/screens/rating/enhanced_rating_screen_v2.dart';

class BookingView extends StatelessWidget {
  BookingView({super.key});
  final BookingController controller = Get.put(BookingController());

  @override
  Widget build(BuildContext context) {
    // Ensure "Not Started" is selected and API is called when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.selectedTab.value != 0) {
        controller.selectTab(0);
      }
      // Always call the upcoming bookings API when this view is accessed
      controller.fetchUpcomingBookings();
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.bookings,
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w500,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 13.w),
          child: Column(
            children: [
              10.ph,
              Obx(
                () => SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CustomTabButton(
                        title: AppLocalizations.of(context)!.notStarted,
                        isSelected: controller.selectedTab.value == 0,
                        onTap: () => controller.selectTab(0),
                      ),
                      10.horizontalSpace,
                      CustomTabButton(
                        title: AppLocalizations.of(context)!.inProgress,
                        isSelected: controller.selectedTab.value == 1,
                        onTap: () => controller.selectTab(1),
                      ),
                      10.horizontalSpace,
                      CustomTabButton(
                        title: AppLocalizations.of(context)!.completedBookings,
                        isSelected: controller.selectedTab.value == 2,
                        onTap: () => controller.selectTab(2),
                      ),
                      10.horizontalSpace,
                      CustomTabButton(
                        title: AppLocalizations.of(context)!.bookingHistory,
                        isSelected: controller.selectedTab.value == 3,
                        onTap: () => controller.selectTab(3),
                      ),
                    ],
                  ),
                ),
              ),
              15.ph,
              Obx(
                () =>
                    controller.selectedTab.value == 0
                        ? NotStartedBookingView()
                        : controller.selectedTab.value == 1
                        ? InProgress()
                        : controller.selectedTab.value == 2
                        ? CompletedBookingView()
                        : BookingHistoryListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingHistoryListView extends StatelessWidget {
  const BookingHistoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ConsumerBookingHistoryController historyController =
        Get.find<ConsumerBookingHistoryController>();

    return Obx(() {
      if (historyController.isLoading.value) {
        return SizedBox(
          height: 590.h,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (historyController.isError.value) {
        return SizedBox(
          height: 590.h,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.errorLoadingBookingHistory,
                  style: GoogleFonts.ubuntu(fontSize: 16.sp, color: Colors.red),
                ),
                10.ph,
                ElevatedButton(
                  onPressed:
                      () => historyController.fetchConsumerBookingHistory(),
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        );
      }

      if (historyController.isEmpty) {
        return SizedBox(
          height: 590.h,
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.noBookingHistoryFound,
              style: GoogleFonts.ubuntu(fontSize: 16.sp, color: AppColors.grey),
            ),
          ),
        );
      }

      return SizedBox(
        height: 590.h,
        child: RefreshIndicator(
          onRefresh: () async {
            await historyController.refreshBookingHistory();
          },
          child: ListView.separated(
            itemBuilder: (context, index) {
              final booking = historyController.bookings[index];
              return BookingCard(
                imageUrl: blankProfileImage,
                serviceTitle: booking.service.name,
                providerName: booking.provider.name,
                date: booking.formattedDate,
                time: booking.formattedTime,
                greyButtonOnTap: () {
                  // Implement rebook logic here
                  print("Rebook tapped for booking: ${booking.bookingId}");
                },
                greenButtonOnTap: () {
                  // For completed bookings, show enhanced rating view
                  if (booking.status.toLowerCase() == 'completed') {
                    Get.to(
                      () => EnhancedRatingScreenV2(
                        providerId: booking.providerId.toString(),
                        bookingId: booking.id ?? '',
                        providerName: booking.provider.name,
                        providerImageUrl: booking.provider.avatar ?? blankProfileImage,
                      ),
                    );
                  } else {
                    // For other statuses, show booking details
                    Get.to(
                      () => BookingDetailsView(
                        pageName: booking.displayStatus,
                        bookingId: booking.id,
                      ),
                    );
                  }
                },
                greyButtonText: AppLocalizations.of(context)!.rebook,
                greenButtonText:
                    booking.status.toLowerCase() == 'completed'
                        ? AppLocalizations.of(context)!.rateNow
                        : AppLocalizations.of(context)!.viewDetails,
                isShowCompleted: booking.status.toLowerCase() == 'completed',
                isShowCancelButton: booking.status.toLowerCase() != 'completed',
              );
            },
            separatorBuilder: (context, index) {
              return 15.ph;
            },
            itemCount: historyController.bookings.length,
          ),
        ),
      );
    });
  }
}

class NotStartedBookingView extends StatelessWidget {
  const NotStartedBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find();
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      if (controller.upcomingBookings.isEmpty) {
        return Center(child: Text(AppLocalizations.of(context)!.noBookingsYet));
      }
      return SizedBox(
        height: 590.h,
        child: ListView.separated(
          itemBuilder: (context, index) {
            final booking = controller.upcomingBookings[index];
            return BookingCard(
              isShowCancelButton: false,
              imageUrl: booking.provider?.avatar ?? blankProfileImage,
              serviceTitle: booking.service?.name ?? '-',
              providerName: booking.provider?.name ?? '-',
              date: booking.bookingDate ?? '-',
              time: convertTo12HourFormat(booking.bookingTime!),
              // price: booking.plan?.planPrice ?? '',
              greyButtonOnTap: () {
                // Implement cancel logic
              },
              greenButtonOnTap: () {
                Get.to(
                  () => BookingDetailsView(
                    pageName: AppLocalizations.of(context)!.notStartedStatus,
                    bookingId: booking.id,
                  ),
                );
              },
              greyButtonText: AppLocalizations.of(context)!.cancel,
              greenButtonText: AppLocalizations.of(context)!.viewDetails,
              isShowCompleted: false,
            );
          },
          separatorBuilder: (context, index) {
            return 15.ph;
          },
          itemCount: controller.upcomingBookings.length,
        ),
      );
    });
  }
}

class InProgress extends StatelessWidget {
  const InProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find();
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      if (controller.ongoingBookings.isEmpty) {
        return Center(
          child: Text(AppLocalizations.of(context)!.noOngoingBookings),
        );
      }
      return SizedBox(
        height: 590.h,
        child: ListView.separated(
          itemBuilder: (context, index) {
            final booking = controller.ongoingBookings[index];
            return BookingCard(
              isShowCancelButton: false,
              imageUrl: booking.provider?.avatar ?? blankProfileImage,
              serviceTitle: booking.service?.name ?? '-',
              providerName: booking.provider?.name ?? '-',
              date: booking.bookingDate ?? '-',
              time: convertTo12HourFormat(booking.bookingTime!),
              greyButtonOnTap: () {
                // Implement rebook logic
              },
              greenButtonOnTap: () {
                Get.to(
                  () => BookingDetailsView(
                    pageName: AppLocalizations.of(context)!.inProgressStatus,
                    bookingId: booking.id,
                  ),
                );
              },
              greyButtonText: AppLocalizations.of(context)!.rebook,
              greenButtonText: AppLocalizations.of(context)!.viewDetails,
              isShowCompleted: false,
            );
          },
          separatorBuilder: (context, index) {
            return 15.ph;
          },
          itemCount: controller.ongoingBookings.length,
        ),
      );
    });
  }
}

class CompletedBookingView extends StatelessWidget {
  const CompletedBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find();
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      if (controller.completedBookings.isEmpty) {
        return Center(
          child: Text(AppLocalizations.of(context)!.noCompletedBookings),
        );
      }
      return SizedBox(
        height: 590.h,
        child: ListView.separated(
          itemBuilder: (context, index) {
            final booking = controller.completedBookings[index];
            return BookingCard(
              isShowCancelButton: false,
              imageUrl: booking.provider?.avatar ?? blankProfileImage,
              serviceTitle: booking.service?.name ?? '-',
              providerName: booking.provider?.name ?? '-',
              date: booking.bookingDate ?? '-',
              time: convertTo12HourFormat(booking.bookingTime!),
              greyButtonOnTap: () {
                // Implement rebook logic
              },
              greenButtonOnTap: () {
                Get.to(
                  () => BookingDetailsView(
                    pageName: AppLocalizations.of(context)!.completedStatus,
                    bookingId: booking.id,
                  ),
                );
              },
              greyButtonText: AppLocalizations.of(context)!.rebook,
              greenButtonText: AppLocalizations.of(context)!.viewDetails,
              isShowCompleted: true,
            );
          },
          separatorBuilder: (context, index) {
            return 15.ph;
          },
          itemCount: controller.completedBookings.length,
        ),
      );
    });
  }
}
