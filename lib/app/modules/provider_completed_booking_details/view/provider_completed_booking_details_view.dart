import 'package:ustahub/app/export/exports.dart';

class ProviderCompletedBookingDetailsView extends StatelessWidget {
  const ProviderCompletedBookingDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 13.w),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: SvgPicture.asset(
                      AppVectors.back,
                      height: 30.h,
                      width: 30.h,
                    ),
                  ),
                  100.pw,
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60.sp,
                      ),
                    ),
                  ),
                ],
              ),
              10.ph,
              Text(
                "You earn on this servie",
                style: GoogleFonts.ubuntu(
                  textStyle: TextStyle(
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              Text(
                "\$780",
                style: GoogleFonts.ubuntu(
                  textStyle: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                    fontSize: 20.sp,
                  ),
                ),
              ),
              10.ph,
              ProviderBookingRequestCard(isShowButtons: false),
              10.ph,
              PaymentSummaryWidget(
                isPaid: true,
                // itemTotal: 699,
                // discount: 50,
                // serviceFee: 50,
                // grandTotal: 749,
                visitingCharge: visitingCharge,
              ),
              10.ph,
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.rating,
                          style: GoogleFonts.ubuntu(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.star,
                          color: AppColors.darkGreen,
                          size: 15.sp,
                        ),
                        5.pw,
                        Text(
                          "4.5",
                          style: GoogleFonts.ubuntu(
                            color: AppColors.grey,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    20.ph,
                    ProvidersDetailsScreenReview(
                      rating: 3.5,
                      imageUrl:
                          "https://www.shutterstock.com/image-photo/head-shot-portrait-close-smiling-600nw-1714666150.jpg",
                      name: "Abdul Rojak",
                      review: "Good Service",
                      time: "Today",
                    ),
                    70.ph,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
