import 'package:ustahub/app/export/exports.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';

class CategoryRatingWidgetV2 extends StatelessWidget {
  final String category;
  final double rating;
  final ValueChanged<double>? onChanged;
  final bool readOnly;

  const CategoryRatingWidgetV2({
    super.key,
    required this.category,
    required this.rating,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: AppTextStyles.bodyMedium,
            ),
            if (!readOnly && onChanged != null)
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: readOnly
                        ? null
                        : () => onChanged!((index + 1).toDouble()),
                    child: Icon(
                      index < rating.round()
                          ? Icons.star
                          : Icons.star_border,
                      size: 24.sp,
                      color: Colors.amber,
                    ),
                  );
                }),
              )
            else
              Text(
                rating.toStringAsFixed(1),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        if (readOnly && onChanged == null)
          Slider(
            value: rating,
            min: 0.0,
            max: 5.0,
            divisions: 10,
            onChanged: null,
            activeColor: AppColorsV2.primary,
          ),
      ],
    );
  }
}

