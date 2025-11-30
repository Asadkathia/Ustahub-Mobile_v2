import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_portfolio/model/portfolio_model.dart';
import 'package:ustahub/utils/cache/image_cache_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';

class PortfolioCardV2 extends StatelessWidget {
  final PortfolioModel portfolio;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const PortfolioCardV2({
    super.key,
    required this.portfolio,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final firstImage = portfolio.imageUrls.isNotEmpty
        ? portfolio.imageUrls.first
        : null;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: AppSpacing.mdVertical),
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
              // Image Section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppSpacing.radiusLarge),
                      topRight: Radius.circular(AppSpacing.radiusLarge),
                    ),
                    child: firstImage != null
                        ? CachedNetworkImage(
                            imageUrl: firstImage,
                            cacheManager: getImageCacheManager(),
                            width: double.infinity,
                            height: 200.h,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: double.infinity,
                              height: 200.h,
                              color: AppColorsV2.surface,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColorsV2.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: double.infinity,
                              height: 200.h,
                              color: AppColorsV2.surface,
                              child: Icon(
                                Icons.image_not_supported,
                                size: AppSpacing.iconXLarge,
                                color: AppColorsV2.textTertiary,
                              ),
                            ),
                            memCacheWidth: (400 * MediaQuery.of(context).devicePixelRatio).round(),
                            memCacheHeight: (200 * MediaQuery.of(context).devicePixelRatio).round(),
                            maxWidthDiskCache: 800,
                            maxHeightDiskCache: 600,
                          )
                        : Container(
                            width: double.infinity,
                            height: 200.h,
                            color: AppColorsV2.surface,
                            child: Icon(
                              Icons.image,
                              size: AppSpacing.iconXLarge,
                              color: AppColorsV2.textTertiary,
                            ),
                          ),
                  ),
                  // Image count badge
                  if (portfolio.imageUrls.length > 1)
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 14.sp,
                              color: AppColorsV2.textOnPrimary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${portfolio.imageUrls.length}',
                              style: AppTextStyles.captionSmall.copyWith(
                                color: AppColorsV2.textOnPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Featured badge
                  if (portfolio.isFeatured)
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColorsV2.primary,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 14.sp,
                              color: AppColorsV2.textOnPrimary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Featured',
                              style: AppTextStyles.captionSmall.copyWith(
                                color: AppColorsV2.textOnPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // Content Section
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      portfolio.title ?? 'Untitled Portfolio',
                      style: AppTextStyles.heading4,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.xsVertical),
                    // Description
                    if (portfolio.description != null &&
                        portfolio.description!.isNotEmpty)
                      Text(
                        portfolio.description!,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    // Project date
                    if (portfolio.projectDate != null) ...[
                      SizedBox(height: AppSpacing.xsVertical),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14.sp,
                            color: AppColorsV2.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _formatDate(portfolio.projectDate!),
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColorsV2.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Tags
                    if (portfolio.tags.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.xsVertical),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: portfolio.tags.take(3).map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColorsV2.primaryContainer,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                            ),
                            child: Text(
                              tag,
                              style: AppTextStyles.captionSmall.copyWith(
                                color: AppColorsV2.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    // Action buttons (if showActions is true)
                    if (showActions) ...[
                      SizedBox(height: AppSpacing.mdVertical),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (onEdit != null)
                            TextButton.icon(
                              onPressed: onEdit,
                              icon: Icon(
                                Icons.edit,
                                size: AppSpacing.iconSmall,
                                color: AppColorsV2.primary,
                              ),
                              label: Text(
                                'Edit',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColorsV2.primary,
                                ),
                              ),
                            ),
                          if (onDelete != null) ...[
                            SizedBox(width: AppSpacing.sm),
                            TextButton.icon(
                              onPressed: onDelete,
                              icon: Icon(
                                Icons.delete,
                                size: AppSpacing.iconSmall,
                                color: AppColorsV2.error,
                              ),
                              label: Text(
                                'Delete',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColorsV2.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

