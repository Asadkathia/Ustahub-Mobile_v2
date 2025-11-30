import 'package:ustahub/app/export/exports.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';

class RatingFilterV2 extends StatelessWidget {
  final double minRating;
  final ValueChanged<double> onChanged;

  const RatingFilterV2({
    super.key,
    required this.minRating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Rating',
          style: AppTextStyles.heading4,
        ),
        SizedBox(height: AppSpacing.smVertical),
        Slider(
          value: minRating,
          min: 0.0,
          max: 5.0,
          divisions: 10,
          label: minRating.toStringAsFixed(1),
          onChanged: onChanged,
          activeColor: AppColorsV2.primary,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0.0',
              style: AppTextStyles.captionSmall,
            ),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < minRating.round()
                      ? Icons.star
                      : Icons.star_border,
                  size: 20.sp,
                  color: Colors.amber,
                );
              }),
            ),
            Text(
              '5.0',
              style: AppTextStyles.captionSmall,
            ),
          ],
        ),
      ],
    );
  }
}

