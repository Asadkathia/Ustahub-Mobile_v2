import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_completed_booking_details/view/booking_details_view.dart';
import 'package:ustahub/data/response/status.dart';
import '../../components/navigation/app_app_bar_v2.dart';
import '../../components/tabs/custom_tab_button_v2.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';

class ProviderBookingScreenV2 extends GetView<ProviderBookingController> {
  const ProviderBookingScreenV2({super.key});

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
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: AppLocalizations.of(context)!.bookings,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingHorizontal),
        child: Column(
          children: [
            SizedBox(height: AppSpacing.mdVertical),
            SizedBox(
              height: 50.h,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Obx(
                  () => Row(
                    children: [
                      CustomTabButtonV2(
                        title: "Not Started",
                        isSelected: providerController.selectedTab.value == 0,
                        onTap: () {
                          providerController.selectTab(0);
                          providerController.providerBookingApi("not_started");
                        },
                      ),
                      SizedBox(width: AppSpacing.sm),
                      CustomTabButtonV2(
                        title: "In progress",
                        isSelected: providerController.selectedTab.value == 1,
                        onTap: () {
                          providerController.selectTab(1);
                          providerController.providerBookingApi("ongoing");
                        },
                      ),
                      SizedBox(width: AppSpacing.sm),
                      CustomTabButtonV2(
                        title: "Completed Bookings",
                        isSelected: providerController.selectedTab.value == 2,
                        onTap: () {
                          providerController.selectTab(2);
                          providerController.providerBookingApi("completed");
                        },
                      ),
                      SizedBox(width: AppSpacing.sm),
                      CustomTabButtonV2(
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
                    return Center(
                      child: Text(
                        providerController.error.value,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColorsV2.error,
                        ),
                      ),
                    );
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
                          style: AppTextStyles.bodyMediumSecondary,
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: providerController
                          .providerBookingList
                          .value
                          .bookings!
                          .length,
                      itemBuilder: (context, index) {
                        final booking = providerController
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
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: AppSpacing.mdVertical),
                            padding: EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColorsV2.background,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColorsV2.shadowMedium,
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ServiceCardTile(
                              serviceName: booking.service?.name ?? '',
                              userName: booking.consumer?.name ?? '',
                              date:
                                  "${formatDate(booking.bookingDate ?? "")}- ${convertTo12HourFormat(booking.bookingTime)}",
                              status: booking.status?.capitalizeFirst ?? '',
                              statusColor:
                                  providerController.selectedTab.value == 0
                                      ? AppColorsV2.info
                                      : providerController.selectedTab.value == 1
                                          ? AppColorsV2.warning
                                          : AppColorsV2.success,
                              icon: Image.network(
                                booking.consumer?.profilePhotoUrl ??
                                    blankProfileImage,
                              ),
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
        return Center(
          child: Text(
            historyController.errorMessage.value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColorsV2.error,
            ),
          ),
        );
      }

      if (historyController.isEmpty) {
        return Center(
          child: Text(
            "No booking history found.",
            style: AppTextStyles.bodyMediumSecondary,
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await historyController.fetchBookingHistory();
        },
        color: AppColorsV2.primary,
        child: ListView.builder(
          itemCount: historyController.bookings.length,
          itemBuilder: (context, index) {
            final booking = historyController.bookings[index];
            return Container(
              margin: EdgeInsets.only(bottom: AppSpacing.mdVertical),
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColorsV2.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColorsV2.shadowMedium,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
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
                          style: AppTextStyles.heading4,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: booking.statusColor,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                        ),
                        child: Text(
                          booking.status.capitalizeFirst!,
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColorsV2.textOnPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.smVertical),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: AppSpacing.iconSmall,
                        color: AppColorsV2.textSecondary,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        booking.counterpartyName,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xsVertical),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: AppSpacing.iconSmall,
                        color: AppColorsV2.textSecondary,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        booking.formattedDate,
                        style: AppTextStyles.bodySmall,
                      ),
                      SizedBox(width: AppSpacing.md),
                      Icon(
                        Icons.access_time,
                        size: AppSpacing.iconSmall,
                        color: AppColorsV2.textSecondary,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        booking.formattedTime,
                        style: AppTextStyles.bodySmall,
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

