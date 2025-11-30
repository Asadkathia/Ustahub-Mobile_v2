import 'dart:async';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/ui_v2/navigation/app_router_v2.dart';

class ServiceSuccessView extends StatefulWidget {
  final String? title, totalAmount, bottomTitle, bookingDate, bookingTime;
  final String? bookingId, providerName, serviceName;
  const ServiceSuccessView({
    super.key, 
    this.title, 
    this.totalAmount, 
    this.bottomTitle, 
    this.bookingDate, 
    this.bookingTime,
    this.bookingId,
    this.providerName,
    this.serviceName,
  });

  @override
  State<ServiceSuccessView> createState() => _ServiceSuccessViewState();
}

class _ServiceSuccessViewState extends State<ServiceSuccessView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main Card
                  Container(
                    width: 328.w,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 50.h), // Space for circle icon
                        Text(
                          "Great!",
                          style: GoogleFonts.ubuntu(
                            color: Colors.green,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          widget.title ?? "Your booking was successful!",
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),
                        
                        // Booking Summary
                        if (widget.bookingId != null) ...[
                          _rowItem("Booking ID", widget.bookingId!),
                          SizedBox(height: 8.h),
                        ],
                        if (widget.providerName != null) ...[
                          _rowItem("Provider", widget.providerName!),
                          SizedBox(height: 8.h),
                        ],
                        if (widget.serviceName != null) ...[
                          _rowItem("Service", widget.serviceName!),
                          SizedBox(height: 8.h),
                        ],
                        _rowItem("Booking Date", formatDate(widget.bookingDate)),
                        SizedBox(height: 8.h),
                        _rowItem("Booking Time", formatTime(widget.bookingTime)),
                        if (widget.totalAmount != null) ...[
                          SizedBox(height: 8.h),
                          _rowItem("Total Amount", "\$${widget.totalAmount}"),
                        ],
                        
                        SizedBox(height: 30.h),
                        CustomDottedLine(),
                        SizedBox(height: 30.h),
                        
                        // Action Buttons
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Navigate to BookingScreenV2
                              String? role = await Sharedprefhelper.getRole();
                              if (role == null || role.isEmpty) {
                                role = 'consumer';
                              }
                              AppRouterV2.goToNavBar(role: role, initialIndex: 2); // Bookings tab
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              "View Booking",
                              style: GoogleFonts.ubuntu(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              // Navigate to Chat Screen
                              String? role = await Sharedprefhelper.getRole();
                              if (role == null || role.isEmpty) {
                                role = 'consumer';
                              }
                              AppRouterV2.goToNavBar(role: role, initialIndex: 1); // Chat tab
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              side: BorderSide(color: Colors.green),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              "Chat with Provider",
                              style: GoogleFonts.ubuntu(
                                color: Colors.green,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Positioned Circle Icon
                  Positioned(
                    top: -55.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 80.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String formatTime(String? time) {
    if (time == null || time.isEmpty) return getCurrentTimeHHmm();
    // If time is already in HH:mm format, convert to 12-hour
    if (time.contains(':')) {
      return convertTo12HourFormat(time);
    }
    return time;
  }

  // Widget for reusable row
  Widget _rowItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.ubuntu(fontSize: 13.sp, color: AppColors.grey),
          ),
          Text(
            value,
            style: GoogleFonts.ubuntu(
              fontSize: 13.sp,

              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";
    try {
      final d = DateTime.parse(date);
      return "${monthName(d.month)} ${d.day}, ${d.year}";
    } catch (e) {
      return date;
    }
  }

  String monthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[(month - 1).clamp(0, 11)];
  }
}
 