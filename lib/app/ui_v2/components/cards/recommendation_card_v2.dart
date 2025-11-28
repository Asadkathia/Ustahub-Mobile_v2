import 'package:ustahub/app/export/exports.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';

class RecommendationCardV2 extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? badgeText;
  final double rating;
  final String location;
  final VoidCallback? onTap;

  const RecommendationCardV2({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.rating,
    required this.location,
    this.badgeText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.mdVertical),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColorsV2.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColorsV2.shadowMedium,
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              child: Image.network(
                imageUrl,
                width: 80.w,
                height: 80.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80.w,
                  height: 80.h,
                  color: AppColorsV2.surface,
                  child: Icon(
                    Icons.person,
                    color: AppColorsV2.textTertiary,
                    size: AppSpacing.iconLarge,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.heading4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badgeText != null && badgeText!.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColorsV2.primary.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusRound),
                          ),
                          child: Text(
                            badgeText!,
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColorsV2.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xsVertical),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                  SizedBox(height: AppSpacing.xsVertical),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16.sp,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        rating.toStringAsFixed(1),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Icon(
                        Icons.location_pin,
                        size: 16.sp,
                        color: AppColorsV2.info,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          location,
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColorsV2.info,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

