import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timelines_upgraded/timelines_upgraded.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_calendar/controller/provider_calendar_controller.dart';
import 'package:ustahub/app/modules/provider_calendar/widgets/calendar_booking_card.dart';

class ProviderCalendarView extends StatelessWidget {
  ProviderCalendarView({super.key});

  final ProviderCalendarController controller = Get.put(
    ProviderCalendarController(),
  );

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(24, (index) => index);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.calendar,
          style: GoogleFonts.ubuntu(fontSize: 25.sp),
        ),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // Calendar widget - more compact
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Obx(() {
            return TableCalendar(
              focusedDay: controller.selectedDate.value,
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              currentDay: controller.selectedDate.value,
              calendarFormat: CalendarFormat.week,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate:
                  (day) => isSameDay(controller.selectedDate.value, day),
              onDaySelected: controller.onDaySelected,
                headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.green),
                  rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.green),
                  titleTextStyle: GoogleFonts.ubuntu(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackText,
                  ),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.green,
                  shape: BoxShape.circle,
                ),
                  markerDecoration: BoxDecoration(
                    color: Colors.blue,
                  shape: BoxShape.circle,
                  ),
                  defaultTextStyle: GoogleFonts.ubuntu(fontSize: 14.sp),
                  weekendTextStyle: GoogleFonts.ubuntu(
                    fontSize: 14.sp,
                    color: AppColors.grey,
                  ),
                  selectedTextStyle: GoogleFonts.ubuntu(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  todayTextStyle: GoogleFonts.ubuntu(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
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
                      final bookingDateKey = DateFormat('yyyy-MM-dd').format(parsedDate);
                      return bookingDateKey == dateKey;
                    } catch (e) {
                      final bookingDate = booking.bookingDate;
                      return bookingDate.isNotEmpty && bookingDate.startsWith(dateKey);
                    }
                  });
                  return hasBookings ? [1] : [];
                },
              );
            }),
          ),
          
          // Selected date header with booking count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Obx(() {
              final selected = controller.selectedDate.value;
              final formatted = DateFormat('EEEE, MMM dd, yyyy').format(selected);
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
                          style: GoogleFonts.ubuntu(
                            fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                            color: AppColors.blackText,
                          ),
                        ),
                        if (bookingCount > 0)
                          Text(
                            "$bookingCount ${bookingCount == 1 ? 'booking' : 'bookings'}",
                            style: GoogleFonts.ubuntu(
                              fontSize: 12.sp,
                              color: AppColors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (bookingCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "$bookingCount",
                        style: GoogleFonts.ubuntu(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.green,
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
                        size: 64.r,
                        color: AppColors.grey,
                      ),
                      16.ph,
                      Text(
                        'No bookings for this date',
                        style: GoogleFonts.ubuntu(
                          fontSize: 16.sp,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      8.ph,
                      Text(
                        'Select another date to view bookings',
                        style: GoogleFonts.ubuntu(
                          fontSize: 14.sp,
                          color: AppColors.grey.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Redesigned timeline with better spacing
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: FixedTimeline.tileBuilder(
                theme: TimelineThemeData(
                    nodePosition: 0.12,
                  color: const Color(0xff989898),
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
                      final hourBookings = controller.getBookingsForHour(hours[index]);
                      
                      if (hourBookings.isEmpty) {
                        return SizedBox.shrink();
                      }

                    return Padding(
                        padding: EdgeInsets.only(left: 12.w, bottom: 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: hourBookings.map((booking) {
                            final isCompleted = controller.isCompleted(booking);
                            return CalendarBookingCard(
                              booking: booking,
                              isCompleted: isCompleted,
                            );
                          }).toList(),
                      ),
                    );
                  },
                  indicatorBuilder: (_, index) {
                      final hourBookings = controller.getBookingsForHour(hours[index]);
                      if (hourBookings.isEmpty) {
                        return SizedBox.shrink();
                      }
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.green,
                            width: 2.5,
                          ),
                          color: Colors.white,
                        ),
                        child: Container(
                          margin: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.green,
                          ),
                        ),
                      );
                    },
                    connectorBuilder: (_, index, ___) {
                      final hourBookings = controller.getBookingsForHour(hours[index]);
                      if (hourBookings.isEmpty) {
                        return SizedBox.shrink();
                      }
                      return DashedLineConnector(
                        color: Colors.grey.shade300,
                        thickness: 2.0,
                      );
                    },
                  oppositeContentsBuilder: (context, index) {
                      final hourBookings = controller.getBookingsForHour(hours[index]);
                      if (hourBookings.isEmpty) {
                        return SizedBox.shrink();
                      }
                      
                    final timeLabel = TimeOfDay(
                      hour: hours[index],
                      minute: 0,
                    ).format(context);
                    return Container(
                        padding: EdgeInsets.only(right: 12.w),
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                      child: Text(
                        timeLabel,
                            style: GoogleFonts.ubuntu(
                              fontSize: 12.sp,
                              color: AppColors.green,
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