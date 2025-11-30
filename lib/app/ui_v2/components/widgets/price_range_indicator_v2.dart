import 'package:ustahub/app/export/exports.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';

class PriceRangeIndicatorV2 extends StatelessWidget {
  final double? minPrice;
  final double? maxPrice;
  final double? avgPrice;

  const PriceRangeIndicatorV2({
    super.key,
    this.minPrice,
    this.maxPrice,
    this.avgPrice,
  });

  @override
  Widget build(BuildContext context) {
    if (minPrice == null && maxPrice == null && avgPrice == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColorsV2.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (minPrice != null && maxPrice != null) ...[
            Text(
              '\$${minPrice!.toStringAsFixed(0)} - \$${maxPrice!.toStringAsFixed(0)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColorsV2.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else if (avgPrice != null) ...[
            Text(
              'Avg: \$${avgPrice!.toStringAsFixed(0)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColorsV2.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

