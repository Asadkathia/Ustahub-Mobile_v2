// // provider_service_request_details_view.dart
// import 'package:ustahub/app/export/exports.dart';

// class ProviderServiceRequestDetailsView extends StatelessWidget {
//   ProviderServiceRequestDetailsView({super.key});

//   final _controller = Get.put(ProviderServiceRequestDetailsController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColors.green,
//         onPressed:
//             () => MapsLauncher.launchCoordinates(37.4220041, -122.0862462),
//         child: const Icon(Icons.navigation_sharp, color: Colors.white),
//       ),

//       /// Bottom button that changes label and behaviour reactively
//       bottomNavigationBar: Obx(
//         () => InkWell(
//           onTap: () => showOtpBottomSheet(context,1),
//           child: Container(
//             height: 50.h,
//             width: double.infinity,
//             color: AppColors.green,
//             alignment: Alignment.center,
//             child: Text(
//               _controller.buttonText,
//               style: GoogleFonts.ubuntu(
//                 fontSize: 16.sp,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//       ),
//       appBar: const CustomAppBar(title: 'Service details'),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(horizontal: 13.w),
//           child: Column(
//             children: [
//               ProviderBookingRequestCard(isShowButtons: false),
//               10.ph,
//               PlansFeaturesContainer(
//                 title:
//                     'Basic plumbing services including leak repair, pipe fitting, and maintenance.',
//                 amount: '150',
//                 features: ['Leak repair', 'Pipe fitting', 'Maintenance'],
//               ),
//               10.ph,
//               PaymentSummaryWidget(
//                 isPaid: true,
//                 // itemTotal: 699,
//                 // discount: 50,
//                 // serviceFee: 50,
//                 // grandTotal: 749,
//                 visitingCharge: visitingCharge,
//               ),
//               50.ph,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
