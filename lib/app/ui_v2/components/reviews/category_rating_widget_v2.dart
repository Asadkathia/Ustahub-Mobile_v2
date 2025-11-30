import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';

/// Widget for displaying and selecting category-specific ratings
/// Used in enhanced review screens
class CategoryRatingWidgetV2 extends StatelessWidget {
  final String category;
  final double value;
  final ValueChanged<double>? onChanged;
  final bool readOnly;

  const CategoryRatingWidgetV2({
    super.key,
    required this.category,
    required this.value,
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
            Text(
              value.toStringAsFixed(1),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColorsV2.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.smVertical),
        Slider(
          value: value.clamp(0.0, 5.0),
          min: 0.0,
          max: 5.0,
          divisions: 10,
          label: value.toStringAsFixed(1),
          activeColor: readOnly 
              ? AppColorsV2.textSecondary 
              : AppColorsV2.primary,
          inactiveColor: AppColorsV2.borderLight,
          // Fix: Provide a no-op callback instead of null when readOnly is true
          // Slider requires a non-null onChanged callback
          onChanged: readOnly 
              ? (_) {
                  // No-op callback when readOnly is true
                  // This prevents the runtime error while keeping the slider disabled
                }
              : onChanged ?? (_) {
                  // Fallback no-op if onChanged is null but readOnly is false
                },
        ),
      ],
    );
  }
}

