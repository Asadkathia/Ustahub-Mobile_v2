import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_completed_booking_details/view/provider_completed_booking_details_view.dart';

class PaymnetEarningView extends StatelessWidget {
  const PaymnetEarningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.earnings),
      body: SafeArea(
        child: ListView.builder(
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Get.to(() => ProviderCompletedBookingDetailsView());
              },
              child: PaymentDetailCard(
                paymentMethod: "Cash",
                amount: "\$58",
                orderId: "#125",
                date: "02 Dec, 2022",
              ),
            );
          },
        ),
      ),
    );
  }
}

class PaymentDetailCard extends StatelessWidget {
  final String paymentMethod;
  final String amount;
  final String orderId;
  final String date;

  const PaymentDetailCard({
    super.key,
    required this.paymentMethod,
    required this.amount,
    required this.orderId,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.shade100),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Method
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppLocalizations.of(context)!.paymentMethod} :',
                style: GoogleFonts.ubuntu(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                paymentMethod,
                style: GoogleFonts.ubuntu(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.amount,
                      style: GoogleFonts.ubuntu(fontSize: 13.sp),
                    ),
                    Text(
                      amount,
                      style: GoogleFonts.ubuntu(
                        fontSize: 14.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // Order Id
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.orderId,
                      style: GoogleFonts.ubuntu(fontSize: 13.sp),
                    ),
                    Text(
                      orderId,
                      style: GoogleFonts.ubuntu(
                        fontSize: 13.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.date,
                      style: GoogleFonts.ubuntu(fontSize: 13.sp),
                    ),
                    Text(
                      date,
                      style: GoogleFonts.ubuntu(
                        fontSize: 13.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
