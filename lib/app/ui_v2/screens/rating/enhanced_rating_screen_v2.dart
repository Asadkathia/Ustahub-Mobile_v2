import 'dart:io';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/rating/controller/rating_controller.dart';
import 'package:ustahub/app/ui_v2/components/reviews/category_rating_widget_v2.dart';
import 'package:ustahub/app/ui_v2/ui_v2_exports.dart';

class EnhancedRatingScreenV2 extends StatelessWidget {
  final String providerId;
  final String bookingId;
  final String? providerName;
  final String? providerImageUrl;

  const EnhancedRatingScreenV2({
    super.key,
    required this.providerId,
    required this.bookingId,
    this.providerName,
    this.providerImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final ratingController = Get.put(RatingController());
    ratingController.initializeRating(
      id: providerId,
      bookingId: bookingId,
      name: providerName,
      imageUrl: providerImageUrl,
    );

    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: const AppAppBarV2(
        title: 'Rate Provider',
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        children: [
          // Overall rating
          Text(
            'Overall Rating',
            style: AppTextStyles.heading3,
          ),
          SizedBox(height: AppSpacing.mdVertical),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => ratingController.updateRating((index + 1).toDouble()),
                child: Icon(
                  index < ratingController.currentRating.value.round()
                      ? Icons.star
                      : Icons.star_border,
                  size: 48.sp,
                  color: Colors.amber,
                ),
              );
            }),
          )),
          SizedBox(height: AppSpacing.lgVertical),
          // Category ratings
          Text(
            'Rate by Category',
            style: AppTextStyles.heading4,
          ),
          SizedBox(height: AppSpacing.mdVertical),
          Obx(() => Column(
            children: [
              CategoryRatingWidgetV2(
                category: 'Quality',
                rating: ratingController.categoryRatings['quality'] ?? 0.0,
                onChanged: (value) =>
                    ratingController.updateCategoryRating('quality', value),
              ),
              SizedBox(height: AppSpacing.smVertical),
              CategoryRatingWidgetV2(
                category: 'Punctuality',
                rating: ratingController.categoryRatings['punctuality'] ?? 0.0,
                onChanged: (value) =>
                    ratingController.updateCategoryRating('punctuality', value),
              ),
              SizedBox(height: AppSpacing.smVertical),
              CategoryRatingWidgetV2(
                category: 'Communication',
                rating: ratingController.categoryRatings['communication'] ?? 0.0,
                onChanged: (value) =>
                    ratingController.updateCategoryRating('communication', value),
              ),
              SizedBox(height: AppSpacing.smVertical),
              CategoryRatingWidgetV2(
                category: 'Price',
                rating: ratingController.categoryRatings['price'] ?? 0.0,
                onChanged: (value) =>
                    ratingController.updateCategoryRating('price', value),
              ),
            ],
          )),
          SizedBox(height: AppSpacing.lgVertical),
          // Review text
          AppTextFieldV2(
            controller: ratingController.reviewController,
            labelText: 'Write a Review',
            hintText: 'Share your experience...',
            maxLines: 5,
          ),
          SizedBox(height: AppSpacing.mdVertical),
          // Review images
          Text(
            'Add Photos (Optional)',
            style: AppTextStyles.heading4,
          ),
          SizedBox(height: AppSpacing.smVertical),
          Obx(() {
            if (ratingController.reviewImages.isEmpty) {
              return SecondaryButtonV2(
                text: 'Add Photos',
                icon: Icons.add_photo_alternate,
                onPressed: () => ratingController.addReviewImage(),
              );
            }

            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ...ratingController.reviewImages.asMap().entries.map((entry) {
                  return Stack(
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          image: DecorationImage(
                            image: FileImage(entry.value),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () => ratingController.removeReviewImage(entry.key),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppColorsV2.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16.sp,
                              color: AppColorsV2.textOnPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                GestureDetector(
                  onTap: () => ratingController.addReviewImage(),
                  child: Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: AppColorsV2.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      border: Border.all(color: AppColorsV2.borderLight),
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppColorsV2.textSecondary,
                    ),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: AppSpacing.xlVertical),
          // Submit button
          Obx(() => PrimaryButtonV2(
            text: 'Submit Review',
            onPressed: ratingController.isFormValid
                ? () => ratingController.submitRating()
                : null,
            isLoading: ratingController.isLoading.value,
          )),
          SizedBox(height: AppSpacing.xlVertical),
        ],
      ),
    );
  }
}

