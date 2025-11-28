import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:ustahub/app/export/exports.dart';

class RatingView extends StatelessWidget {
  final String providerId;
  final String bookingId;
  final String? providerName;
  final String? providerImageUrl;

  const RatingView({
    super.key,
    required this.providerId,
    required this.bookingId,
    this.providerName,
    this.providerImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final RatingController controller = Get.put(RatingController());

    // Initialize the controller with provider & booking data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeRating(
        id: providerId,
        bookingId: bookingId,
        name: providerName,
        imageUrl: providerImageUrl,
      );
    });

    return Scaffold(
      appBar: CustomAppBar(title: "Rating"),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 13.w),
        child: Obx(
          () => Column(
            children: [
              RatingHeader(
                imageUrl:
                    controller.providerImageUrl.value.isNotEmpty
                        ? controller.providerImageUrl.value
                        : blankProfileImage,
                name:
                    controller.providerName.value.isNotEmpty
                        ? controller.providerName.value
                        : 'Provider',
                subtitle:
                    'Reviews are public and include your account and device info.',
              ),

              10.ph,
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: RatingBar(
                  alignment: Alignment.center,
                  size: 40.r,
                  isHalfAllowed: true,
                  halfFilledIcon: Icons.star_half_outlined,
                  filledIcon: Icons.star,
                  emptyIcon: Icons.star_border,
                  halfFilledColor: AppColors.darkGreen,
                  onRatingChanged: (value) {
                    controller.updateRating(value);
                    debugPrint('Rating: $value');
                  },
                  initialRating: controller.currentRating.value,
                  maxRating: 5,
                  emptyColor: AppColors.grey,
                  filledColor: AppColors.darkGreen,
                ),
              ),
              20.ph,
              buildFormField(
                radius: 10.r,
                hint: "Describe your experience",
                fillColor: Colors.white,
                maxLines: null,
                controller: controller.reviewController,
              ),

              // Show error message if any
              if (controller.isError.value) ...[
                20.ph,
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    controller.errorMessage.value,
                    style: GoogleFonts.ubuntu(
                      color: Colors.red,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],

              40.ph,
              BuildBasicButton(
                onPressed: () {
                  if (!controller.isLoading.value) {
                    controller.submitRating();
                  }
                },
                title:
                    controller.isLoading.value
                        ? "Publishing..."
                        : "Publish Review",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
