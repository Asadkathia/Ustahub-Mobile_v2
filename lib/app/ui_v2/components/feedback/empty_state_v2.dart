import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustahub/app/ui_v2/design_system/colors/app_colors_v2.dart';
import 'package:ustahub/app/ui_v2/design_system/spacing/app_spacing.dart';
import 'package:ustahub/app/ui_v2/design_system/typography/app_text_styles.dart';

/// Standardized empty state widget for consistent UI across the app
class EmptyStateV2 extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double? iconSize;

  const EmptyStateV2({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xlVertical),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize ?? 64.w,
              color: iconColor ?? AppColorsV2.textTertiary,
            ),
            SizedBox(height: AppSpacing.mdVertical),
            Text(
              title,
              style: AppTextStyles.heading4.copyWith(
                color: AppColorsV2.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.smVertical),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColorsV2.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSpacing.lgVertical),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsV2.primary,
                  foregroundColor: AppColorsV2.textOnPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.mdVertical,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

