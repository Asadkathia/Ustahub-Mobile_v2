import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustahub/app/ui_v2/design_system/colors/app_colors_v2.dart';
import 'package:ustahub/app/ui_v2/design_system/spacing/app_spacing.dart';
import 'package:ustahub/app/ui_v2/design_system/typography/app_text_styles.dart';

/// Nudge banner component for in-app prompts and reminders
class NudgeBannerV2 extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final VoidCallback? onDismissed;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final Color? accentColor;

  const NudgeBannerV2({
    super.key,
    required this.title,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.onDismissed,
    this.icon = Icons.info_outline,
    this.iconColor = AppColorsV2.primary,
    this.backgroundColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? iconColor.withOpacity(0.1);
    final accent = accentColor ?? iconColor;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.mdVertical),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: accent,
                size: 24.sp,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.heading4.copyWith(
                    color: accent,
                  ),
                ),
              ),
              if (onDismissed != null)
                IconButton(
                  onPressed: onDismissed,
                  icon: Icon(
                    Icons.close,
                    color: accent.withOpacity(0.7),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          SizedBox(height: AppSpacing.xsVertical),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColorsV2.textSecondary,
            ),
          ),
          if (actionText != null && onActionPressed != null) ...[
            SizedBox(height: AppSpacing.mdVertical),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: AppColorsV2.textOnPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.smVertical,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

