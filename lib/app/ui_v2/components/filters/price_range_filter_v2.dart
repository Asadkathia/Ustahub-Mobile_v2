import 'package:ustahub/app/export/exports.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';

class PriceRangeFilterV2 extends StatelessWidget {
  final double minPrice;
  final double maxPrice;
  final double currentMin;
  final double currentMax;
  final ValueChanged<RangeValues> onChanged;

  const PriceRangeFilterV2({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.currentMin,
    required this.currentMax,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: AppTextStyles.heading4,
        ),
        SizedBox(height: AppSpacing.smVertical),
        RangeSlider(
          values: RangeValues(currentMin, currentMax),
          min: minPrice,
          max: maxPrice,
          divisions: 20,
          labels: RangeLabels(
            '\$${currentMin.toStringAsFixed(0)}',
            '\$${currentMax.toStringAsFixed(0)}',
          ),
          onChanged: onChanged,
          activeColor: AppColorsV2.primary,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${minPrice.toStringAsFixed(0)}',
              style: AppTextStyles.captionSmall,
            ),
            Text(
              '\$${maxPrice.toStringAsFixed(0)}',
              style: AppTextStyles.captionSmall,
            ),
          ],
        ),
      ],
    );
  }
}

