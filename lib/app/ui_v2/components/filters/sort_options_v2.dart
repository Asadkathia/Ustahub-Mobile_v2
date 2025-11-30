import 'package:ustahub/app/export/exports.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';

class SortOptionsV2 extends StatelessWidget {
  final String selectedSort;
  final ValueChanged<String> onChanged;

  const SortOptionsV2({
    super.key,
    required this.selectedSort,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {'value': 'rating', 'label': 'Highest Rated'},
      {'value': 'price', 'label': 'Lowest Price'},
      {'value': 'distance', 'label': 'Nearest'},
      {'value': 'reviews', 'label': 'Most Reviews'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: AppTextStyles.heading4,
        ),
        SizedBox(height: AppSpacing.smVertical),
        ...options.map((option) => RadioListTile<String>(
          title: Text(
            option['label']!,
            style: AppTextStyles.bodyMedium,
          ),
          value: option['value']!,
          groupValue: selectedSort,
          onChanged: (value) => onChanged(value!),
          activeColor: AppColorsV2.primary,
        )),
      ],
    );
  }
}

