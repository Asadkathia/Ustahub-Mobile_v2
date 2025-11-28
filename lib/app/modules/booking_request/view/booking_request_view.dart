import 'package:ustahub/app/export/exports.dart';

class BookingRequestView extends StatelessWidget {
  BookingRequestView({super.key});

  final controller = Get.put(BookingRequestController());

  @override
  Widget build(BuildContext context) {
    controller.fetchBookingRequests();
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.bookingRequest),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              itemCount: 5,
              itemBuilder:
                  (_, index) => const ShimmerBookingRequestCard().withShimmerAi(
                    loading: true,
                  ),
            );
          } else if (controller.bookingRequests.isEmpty) {
            return  Center(
              child: Text(AppLocalizations.of(context)!.noBookingRequestsFound),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              itemCount: controller.bookingRequests.length,
              itemBuilder:
                  (_, index) => ProviderBookingRequestCard(
                    data: controller.bookingRequests[index],
                    isShowButtons: true,
                  ),
            );
          }
        }),
      ),
    );
  }
}

class ShimmerBookingRequestCard extends StatelessWidget {
  const ShimmerBookingRequestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150.w,
                    height: 20.h,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    width: 100.w,
                    height: 15.h,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            height: 40.h,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
