// import 'package:ustahub/app/export/exports.dart';
// import 'package:ustahub/app/modules/booking_details/controller/booking_details_controller.dart';

// class BookingDetailsView extends StatelessWidget {
//   String? tabName;
//   BookingDetailsView({super.key, this.tabName});
//   final controller = Get.put(BookingDetailsController());
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar:
//           tabName == "Ongoing bookings"
//               ? Obx(
//                 () => InkWell(
//                   onTap: () {
//                     controller.isShowOTP.toggle();
//                   },
//                   child: Container(
//                     height: 50.h,
//                     width: double.infinity,
//                     color: AppColors.green,
//                     alignment: Alignment.center,
//                     child: Text(
//                       controller.isShowOTP.value
//                           ? "Service Completion OTP - ${controller.otp.value}"
//                           : "View OTP",
//                       style: GoogleFonts.ubuntu(
//                         fontSize: 16.sp,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//               : cancelBookingWidget(),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 13.w),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     5.ph,
//                     ProviderDetailsScreenHeader(
//                       isFavourite: false,
//                       name: "Adil",
//                       rating: "4.5",
//                       category: "Plumber",
//                       imageUrl:
//                           "https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D",
//                     ),
//                     15.ph,
//                     BookingDetailsAddressCard(
//                       date: 'Mon, Apr 12, 2025',
//                       time: '10:00 AM',
//                       address:
//                           'Plot no.209, Kavuri Hills, Madhapur, Telangana 500033, Ph: +91234567890',
//                     ),
//                     15.ph,
//                     SelectedPlanForBookingDetails(isBookingDetails: true),
//                     15.ph,
//                     PaymentSummaryWidget(
//                       visitingCharge: 30,
//                       // itemTotal: 699,
//                       // discount: 50,
//                       // serviceFee: 50,
//                       // grandTotal: 749,
//                       isPaid: true,
//                     ),
//                     20.ph,
//                     Text(
//                       AppLocalizations.of(context)!.recommendedService,
//                       style: GoogleFonts.ubuntu(
//                         color: Colors.black,
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     15.ph,
//                     SizedBox(
//                       // color: Colors.red,
//                       height: 130.h,
//                       child: ListView.separated(
//                         scrollDirection: Axis.horizontal,
//                         physics: BouncingScrollPhysics(),
//                         itemBuilder: (context, index) {
//                           return HomepagServicesContainer(
//                             // title: "Appliance Rapid lkfdjflkjdlkfjak;ljfdkl Repair",
//                             // iconPath: AppVectors.svgAppliances,
//                             // onTap: () {},
//                           );
//                         },
//                         separatorBuilder: (context, index) {
//                           return 10.pw;
//                         },
//                         itemCount: 7,
//                       ),
//                     ),
//                     15.ph,
//                   ],
//                 ),
//               ),
//               ReviewsWidgetCustom(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   InkWell cancelBookingWidget() {
//     return InkWell(
//       onTap: () {},
//       child: Container(
//         height: 50.h,
//         width: double.infinity,
//         color: AppColors.red,
//         alignment: Alignment.center,
//         child: Text(
//           AppLocalizations.of(Get.context!)!.cancelBooking,
//           style: GoogleFonts.ubuntu(
//             fontSize: 16.sp,
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }
// }
