import 'package:ustahub/app/export/exports.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';

class ReviewResponseV2 extends StatelessWidget {
  final String responseText;
  final DateTime? createdAt;
  final String? providerName;

  const ReviewResponseV2({
    super.key,
    required this.responseText,
    this.createdAt,
    this.providerName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.smVertical),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColorsV2.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: AppColorsV2.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business,
                size: 16.sp,
                color: AppColorsV2.primary,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                providerName ?? 'Provider',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColorsV2.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xsVertical),
          Text(
            responseText,
            style: AppTextStyles.bodySmall,
          ),
          if (createdAt != null) ...[
            SizedBox(height: AppSpacing.xsVertical),
            Text(
              _formatDate(createdAt!),
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColorsV2.textSecondary,
              ),
            ),
          ],
        ],
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

