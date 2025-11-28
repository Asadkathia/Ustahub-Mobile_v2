import 'dart:async';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/ui_v2/navigation/app_router_v2.dart';

class ServiceSuccessView extends StatefulWidget {
  final String? title, totalAmount, bottomTitle, bookingDate, bookingTime;
  const ServiceSuccessView({super.key, this.title, this.totalAmount, this.bottomTitle, this.bookingDate, this.bookingTime});

  @override
  State<ServiceSuccessView> createState() => _ServiceSuccessViewState();
}

class _ServiceSuccessViewState extends State<ServiceSuccessView> {
  int countdown = 3;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 1) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        navigateToHome();
      }
    });
  }

  Future<void> navigateToHome() async {
    String? role = await Sharedprefhelper.getRole();
    if (role == null || role.isEmpty) {
      AppRouterV2.goToNavBar(role: 'consumer');
      return;
    }
    AppRouterV2.goToNavBar(role: role);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        await navigateToHome();
        return false; // Prevent default back behavior since we're navigating
      },
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // ✅ Main Card
                  Container(
                    height: 480.h,
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
                        SizedBox(
                          height: 50.h,
                        ), // enough space for circle to overlap
                        Text(
                          "Great",
                          style: GoogleFonts.ubuntu(
                            color: Colors.green,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          widget.title ?? "Your service successfully done",
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            "Redirecting in ${countdown}s...",
                            style: GoogleFonts.ubuntu(
                              fontSize: 12.sp,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        _rowItem("Booking Status", "Done"),
                        // _rowItem("Total Amount", "\$${widget.totalAmount ?? 799}"),
                        _rowItem("Booking Date", formatDate(widget.bookingDate)),
                        _rowItem("Booking Time", getCurrentTimeHHmm()),

 
                        30.ph,
                        CustomDottedLine(),
                        30.ph,
      
                        // Text(
                        //   widget.bottomTitle ?? "You earn this service",
                        //   style: GoogleFonts.ubuntu(fontSize: 14.sp),
                        // ),
                        // SizedBox(height: 6.h),
                        // Text(
                        //   "\$${widget.totalAmount}",
                        //   style: GoogleFonts.ubuntu(
                        //     fontSize: 18.sp,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.green,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
      
                  // ✅ Positioned Circle Icon
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


 