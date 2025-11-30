import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/utils/cache/image_cache_config.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';

class ReviewWithImagesV2 extends StatelessWidget {
  final String? consumerName;
  final String? consumerAvatar;
  final double rating;
  final String? review;
  final List<String>? imageUrls;
  final int helpfulCount;
  final bool isVerified;
  final VoidCallback? onHelpfulTap;
  final bool hasVotedHelpful;

  const ReviewWithImagesV2({
    super.key,
    this.consumerName,
    this.consumerAvatar,
    required this.rating,
    this.review,
    this.imageUrls,
    this.helpfulCount = 0,
    this.isVerified = false,
    this.onHelpfulTap,
    this.hasVotedHelpful = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.mdVertical),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  consumerAvatar ?? blankProfileImage,
                ),
                radius: 20.r,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          consumerName ?? 'Anonymous',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isVerified) ...[
                          SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.verified,
                            size: 16.sp,
                            color: AppColorsV2.primary,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 16.sp,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review != null && review!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.smVertical),
            Text(
              review!,
              style: AppTextStyles.bodySmall,
            ),
          ],
          if (imageUrls != null && imageUrls!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.smVertical),
            SizedBox(
              height: 100.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls!.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: AppSpacing.sm),
                    width: 100.w,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      child: CachedNetworkImage(
                        imageUrl: imageUrls![index],
                        cacheManager: getImageCacheManager(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColorsV2.surface,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColorsV2.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColorsV2.surface,
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColorsV2.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          SizedBox(height: AppSpacing.smVertical),
          Row(
            children: [
              TextButton.icon(
                onPressed: onHelpfulTap,
                icon: Icon(
                  hasVotedHelpful ? Icons.thumb_up : Icons.thumb_up_outlined,
                  size: 16.sp,
                  color: hasVotedHelpful
                      ? AppColorsV2.primary
                      : AppColorsV2.textSecondary,
                ),
                label: Text(
                  'Helpful ($helpfulCount)',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: hasVotedHelpful
                        ? AppColorsV2.primary
                        : AppColorsV2.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

