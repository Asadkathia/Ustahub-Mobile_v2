import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timelines_upgraded/timelines_upgraded.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_calendar/controller/provider_calendar_controller.dart';
import '../../components/navigation/app_app_bar_v2.dart';
import '../../components/cards/calendar_booking_card_v2.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';

class ProviderCalendarScreenV2 extends StatelessWidget {
  const ProviderCalendarScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderCalendarController());
    final hours = List.generate(24, (index) => index);
    
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: AppLocalizations.of(context)!.calendar,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Calendar widget
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColorsV2.background,
              border: Border(
                bottom: BorderSide(
                  color: AppColorsV2.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Obx(() {
              return TableCalendar(
                focusedDay: controller.selectedDate.value,
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                currentDay: controller.selectedDate.value,
                calendarFormat: CalendarFormat.week,
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) =>
                    isSameDay(controller.selectedDate.value, day),
                onDaySelected: controller.onDaySelected,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(
                    Icons.chevron_left_rounded,
                    color: AppColorsV2.primary,
                    size: 24.sp,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColorsV2.primary,
                    size: 24.sp,
                  ),
                  titleTextStyle: AppTextStyles.heading4,
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColorsV2.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColorsV2.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppColorsV2.primary,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: AppTextStyles.bodyMedium,
                  weekendTextStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColorsV2.textSecondary,
                  ),
                  selectedTextStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColorsV2.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  todayTextStyle: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColorsV2.primary,
                  ),
                ),
                // Show markers for dates with bookings
                eventLoader: (day) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(day);
                  final hasBookings = controller.bookings.any((booking) {
                    try {
                      final bookingDate = booking.bookingDate;
                      if (bookingDate.isEmpty) return false;
                      final parsedDate = DateTime.parse(bookingDate);
                      final bookingDateKey =
                          DateFormat('yyyy-MM-dd').format(parsedDate);
                      return bookingDateKey == dateKey;
                    } catch (e) {
                      final bookingDate = booking.bookingDate;
                      return bookingDate.isNotEmpty &&
                          bookingDate.startsWith(dateKey);
                    }
                  });
                  return hasBookings ? [1] : [];
                },
              );
            }),
          ),

          // Selected date header with booking count
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingHorizontal,
              vertical: AppSpacing.mdVertical,
            ),
            decoration: BoxDecoration(
              color: AppColorsV2.primaryContainer,
              border: Border(
                bottom: BorderSide(
                  color: AppColorsV2.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Obx(() {
              final selected = controller.selectedDate.value;
              final formatted =
                  DateFormat('EEEE, MMM dd, yyyy').format(selected);
              final bookingCount = controller.selectedDateBookings.length;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatted,
                          style: AppTextStyles.heading4,
                        ),
                        if (bookingCount > 0) ...[
                          SizedBox(height: AppSpacing.xsVertical),
                          Text(
                            "$bookingCount ${bookingCount == 1 ? 'booking' : 'bookings'}",
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (bookingCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorsV2.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                      ),
                      child: Text(
                        "$bookingCount",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColorsV2.textOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),

          // Bookings list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColorsV2.primary,
                  ),
                );
              }

              final selectedDateBookings = controller.selectedDateBookings;
              if (selectedDateBookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64.sp,
                        color: AppColorsV2.textTertiary,
                      ),
                      SizedBox(height: AppSpacing.mdVertical),
                      Text(
                        'No bookings for this date',
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColorsV2.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xsVertical),
                      Text(
                        'Select another date to view bookings',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                );
              }

              // Timeline view with bookings
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: FixedTimeline.tileBuilder(
                  theme: TimelineThemeData(
                    nodePosition: 0.12,
                    color: AppColorsV2.borderMedium,
                    indicatorTheme: const IndicatorThemeData(
                      position: 0.12,
                      size: 18.0,
                    ),
                    connectorTheme: const ConnectorThemeData(thickness: 2.0),
                  ),
                  builder: TimelineTileBuilder.connected(
                    connectionDirection: ConnectionDirection.before,
                    itemCount: hours.length,
                    contentsBuilder: (_, index) {
                      final hourBookings =
                          controller.getBookingsForHour(hours[index]);

                      if (hourBookings.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: EdgeInsets.only(
                          left: AppSpacing.md,
                          bottom: AppSpacing.mdVertical,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: hourBookings.map((booking) {
                            final isCompleted =
                                controller.isCompleted(booking);
                            return CalendarBookingCardV2(
                              booking: booking,
                              isCompleted: isCompleted,
                              onTap: () {
                                // Navigate to booking details
                                // You can add navigation logic here
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                    indicatorBuilder: (_, index) {
                      final hourBookings =
                          controller.getBookingsForHour(hours[index]);
                      if (hourBookings.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColorsV2.primary,
                            width: 2.5,
                          ),
                          color: AppColorsV2.background,
                        ),
                        child: Container(
                          margin: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColorsV2.primary,
                          ),
                        ),
                      );
                    },
                    connectorBuilder: (_, index, ___) {
                      final hourBookings =
                          controller.getBookingsForHour(hours[index]);
                      if (hourBookings.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return DashedLineConnector(
                        color: AppColorsV2.borderLight,
                        thickness: 2.0,
                      );
                    },
                    oppositeContentsBuilder: (context, index) {
                      final hourBookings =
                          controller.getBookingsForHour(hours[index]);
                      if (hourBookings.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final timeLabel = TimeOfDay(
                        hour: hours[index],
                        minute: 0,
                      ).format(context);
                      return Container(
                        padding: EdgeInsets.only(right: AppSpacing.md),
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColorsV2.primaryContainer,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                          ),
                          child: Text(
                            timeLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColorsV2.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

