import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/booking_summary/controller/booking_summary_controller.dart';

class BookingSummaryView extends StatelessWidget {
  final String providerId,
      serviceId,
      serviceName,
      addressId,
      bookingDate,
      bookingTime,
      fullAddress,
      note;
  // final planSelectionController = Get.find<PlanSelectionController>();
  late final ProviderDetailsController providerController;
  final BookingSummaryController bookingController = Get.put(
    BookingSummaryController(),
  );
  
  BookingSummaryView({
    super.key,
    required this.addressId,
    required this.bookingDate,
    required this.bookingTime,
    required this.providerId,
    required this.serviceId,
    required this.serviceName,
    required this.fullAddress,
    required this.note,
  }) {
    // Initialize provider controller safely
    try {
      providerController = Get.find<ProviderDetailsController>();
    } catch (e) {
      // If controller doesn't exist, create it
      providerController = Get.put(ProviderDetailsController());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely get services string with null checks
    final servicesString = (providerController.providerDetails.value?.provider?.services ?? [])
        .map((s) => s.name ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ');

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.bookingSummary)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              child: Column(
                children: [
                  15.ph,
                  ServiceProviderCard(
                    isShowFavourite: false,
                    onTap: () {},
                    starValue: 3.5,
                    name:
                        providerController
                            .providerDetails
                            .value
                            ?.provider
                            ?.name ??
                        "",
                    category: servicesString,
                    // amount: visitingCharge,
                    imageUrl:
                        providerController
                            .providerDetails
                            .value
                            ?.provider
                            ?.avatar ??
                        blankProfileImage,
                  ),
                  15.ph,
                  AddressCard(
                    address: fullAddress,
                    dateTime:
                        "$bookingDate - ${convertTo12HourFormat(bookingTime)}",
                    phoneNumber: "",
                    serviceName: serviceName,
                  ),
                  15.ph,
                  // SelectedPlanForBookingSummary(
                  //   planSelectionController: planSelectionController,
                  // ),
                  // 15.ph,
                  // PaymentSummaryWidget(visitingCharge: visitingCharge),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => InkWell(
          onTap: bookingController.isLoading.value
              ? null
              : () async {
                  final bookingData = {
                    "booking_id":
                        "BOOK-${DateTime.now().millisecondsSinceEpoch}",
                    "provider_id": providerId,
                    "service_id": serviceId,
                    "address_id": addressId,
                    "booking_date": bookingDate,
                    "booking_time": bookingTime,
                    "visiting_charge": visitingCharge,
                    "note": note,
                    "service_fee": 0,
                    "total": 0,
                    "item_total": 0,
                  };
                  await bookingController.bookService(
                    bookingData: bookingData,
                  );
                },
          child: Container(
            height: 50.h,
            width: double.infinity,
            color: AppColors.green,
            alignment: Alignment.center,
            child:
                bookingController.isLoading.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                      AppLocalizations.of(context)!.conti,
                      style: GoogleFonts.ubuntu(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
