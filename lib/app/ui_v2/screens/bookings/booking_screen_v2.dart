import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_completed_booking_details/view/booking_details_view.dart';
import '../../components/navigation/app_app_bar_v2.dart';
import '../../components/tabs/custom_tab_button_v2.dart';
import '../../components/cards/booking_card_v2.dart';
import '../../components/feedback/skeleton_loader_v2.dart';
import '../../components/feedback/empty_state_v2.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';

class BookingScreenV2 extends StatelessWidget {
  BookingScreenV2({super.key});
  
  BookingController get controller {
    Get.lazyPut(() => BookingController());
    return Get.find<BookingController>();
  }

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
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: AppLocalizations.of(context)!.bookings,
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
          child: Column(
            children: [
              SizedBox(height: AppSpacing.mdVertical),
              SizedBox(
                height: 50.h,
                child: Obx(
                  () => SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CustomTabButtonV2(
                          title: AppLocalizations.of(context)!.notStarted,
                          isSelected: controller.selectedTab.value == 0,
                          onTap: () => controller.selectTab(0),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        CustomTabButtonV2(
                          title: AppLocalizations.of(context)!.inProgress,
                          isSelected: controller.selectedTab.value == 1,
                          onTap: () => controller.selectTab(1),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        CustomTabButtonV2(
                          title: AppLocalizations.of(context)!.completedBookings,
                          isSelected: controller.selectedTab.value == 2,
                          onTap: () => controller.selectTab(2),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        CustomTabButtonV2(
                          title: AppLocalizations.of(context)!.bookingHistory,
                          isSelected: controller.selectedTab.value == 3,
                          onTap: () => controller.selectTab(3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.mdVertical),
              Obx(
                () => controller.selectedTab.value == 0
                    ? NotStartedBookingViewV2()
                    : controller.selectedTab.value == 1
                        ? InProgressV2()
                        : controller.selectedTab.value == 2
                            ? CompletedBookingViewV2()
                            : BookingHistoryListViewV2(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingHistoryListViewV2 extends StatelessWidget {
  const BookingHistoryListViewV2({super.key});

  @override
  Widget build(BuildContext context) {
    final ConsumerBookingHistoryController historyController =
        Get.find<ConsumerBookingHistoryController>();

    return Obx(() {
      if (historyController.isLoading.value) {
        return SizedBox(
          height: 590.h,
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: 3,
            itemBuilder: (_, __) => SkeletonListItemV2(),
          ),
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
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColorsV2.error,
                  ),
                ),
                SizedBox(height: AppSpacing.mdVertical),
                ElevatedButton(
                  onPressed: () => historyController.fetchConsumerBookingHistory(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorsV2.primary,
                    foregroundColor: AppColorsV2.textOnPrimary,
                  ),
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
          child: EmptyStateV2(
            icon: Icons.history,
            title: AppLocalizations.of(context)!.noBookingHistoryFound,
            subtitle: 'Your completed bookings will appear here',
          ),
        );
      }

      return SizedBox(
        height: 590.h,
        child: RefreshIndicator(
          onRefresh: () async {
            await historyController.refreshBookingHistory();
          },
          color: AppColorsV2.primary,
          child: ListView.separated(
            itemBuilder: (context, index) {
              final booking = historyController.bookings[index];
              return BookingCardV2(
                imageUrl: blankProfileImage,
                serviceTitle: booking.service.name,
                providerName: booking.provider.name,
                date: booking.formattedDate,
                time: booking.formattedTime,
                greyButtonOnTap: () {
                  print("Rebook tapped for booking: ${booking.bookingId}");
                },
                greenButtonOnTap: () {
                  if (booking.status.toLowerCase() == 'completed') {
                    Get.to(
                      () => RatingView(
                        providerId: booking.providerId.toString(),
                        providerName: booking.provider.name,
                        providerImageUrl: blankProfileImage,
                        bookingId: booking.id,
                      ),
                    );
                  } else {
                    Get.to(
                      () => BookingDetailsView(
                        pageName: booking.displayStatus,
                        bookingId: booking.id,
                      ),
                    );
                  }
                },
                greyButtonText: AppLocalizations.of(context)!.rebook,
                greenButtonText: booking.status.toLowerCase() == 'completed'
                    ? AppLocalizations.of(context)!.rateNow
                    : AppLocalizations.of(context)!.viewDetails,
                isShowCompleted: booking.status.toLowerCase() == 'completed',
                isShowCancelButton: booking.status.toLowerCase() != 'completed',
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(height: AppSpacing.mdVertical);
            },
            itemCount: historyController.bookings.length,
          ),
        ),
      );
    });
  }
}

class NotStartedBookingViewV2 extends StatelessWidget {
  const NotStartedBookingViewV2({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find();
    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          height: 590.h,
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: 3,
            itemBuilder: (_, __) => SkeletonListItemV2(),
          ),
        );
      }
      if (controller.upcomingBookings.isEmpty) {
        return SizedBox(
          height: 590.h,
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.noBookingsYet,
              style: AppTextStyles.bodyMediumSecondary,
            ),
          ),
        );
      }
      return SizedBox(
        height: 590.h,
        child: ListView.separated(
          itemBuilder: (context, index) {
            final booking = controller.upcomingBookings[index];
            return BookingCardV2(
              isShowCancelButton: false,
              imageUrl: blankProfileImage,
              serviceTitle: booking.service?.name ?? '-',
              providerName: booking.provider?.name ?? '-',
              date: booking.bookingDate ?? '-',
              time: convertTo12HourFormat(booking.bookingTime!),
              greyButtonOnTap: () {},
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
            return SizedBox(height: AppSpacing.mdVertical);
          },
          itemCount: controller.upcomingBookings.length,
        ),
      );
    });
  }
}

class InProgressV2 extends StatelessWidget {
  const InProgressV2({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find();
    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          height: 590.h,
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: 3,
            itemBuilder: (_, __) => SkeletonListItemV2(),
          ),
        );
      }
      if (controller.ongoingBookings.isEmpty) {
        return SizedBox(
          height: 590.h,
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.noOngoingBookings,
              style: AppTextStyles.bodyMediumSecondary,
            ),
          ),
        );
      }
      return SizedBox(
        height: 590.h,
        child: ListView.separated(
          itemBuilder: (context, index) {
            final booking = controller.ongoingBookings[index];
            return BookingCardV2(
              isShowCancelButton: false,
              imageUrl: blankProfileImage,
              serviceTitle: booking.service?.name ?? '-',
              providerName: booking.provider?.name ?? '-',
              date: booking.bookingDate ?? '-',
              time: convertTo12HourFormat(booking.bookingTime!),
              greyButtonOnTap: () {},
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
            return SizedBox(height: AppSpacing.mdVertical);
          },
          itemCount: controller.ongoingBookings.length,
        ),
      );
    });
  }
}

class CompletedBookingViewV2 extends StatelessWidget {
  const CompletedBookingViewV2({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find();
    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          height: 590.h,
          child: ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: 3,
            itemBuilder: (_, __) => SkeletonListItemV2(),
          ),
        );
      }
      if (controller.completedBookings.isEmpty) {
        return SizedBox(
          height: 590.h,
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.noCompletedBookings,
              style: AppTextStyles.bodyMediumSecondary,
            ),
          ),
        );
      }
      return SizedBox(
        height: 590.h,
        child: ListView.separated(
          itemBuilder: (context, index) {
            final booking = controller.completedBookings[index];
            return BookingCardV2(
              isShowCancelButton: false,
              imageUrl: blankProfileImage,
              serviceTitle: booking.service?.name ?? '-',
              providerName: booking.provider?.name ?? '-',
              date: booking.bookingDate ?? '-',
              time: convertTo12HourFormat(booking.bookingTime!),
              greyButtonOnTap: () {},
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
            return SizedBox(height: AppSpacing.mdVertical);
          },
          itemCount: controller.completedBookings.length,
        ),
      );
    });
  }
}

