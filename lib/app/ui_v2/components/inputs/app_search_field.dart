import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../cards/app_card.dart';

class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;
  final bool readOnly;
  final Widget? trailing;

  const AppSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onFilterTap,
    this.readOnly = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final input = TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      onSubmitted: onSubmitted != null ? (_) => onSubmitted!.call() : null,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMediumSecondary,
        border: InputBorder.none,
        icon: Icon(
          Icons.search,
          color: AppColorsV2.textSecondary,
          size: AppSpacing.iconMedium,
        ),
      ),
      style: AppTextStyles.bodyMedium,
    );

    return Row(
      children: [
        Expanded(
          child: AppCard(
            bordered: false,
            backgroundColor: AppColorsV2.inputBackground,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 12.h,
            ),
            child: input,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        if (onFilterTap != null || trailing != null)
          InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            onTap: onFilterTap,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColorsV2.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
              child: trailing ??
                  Icon(
                    Icons.tune,
                    color: AppColorsV2.primary,
                    size: AppSpacing.iconMedium,
                  ),
            ),
          ),
      ],
    );
  }
}

