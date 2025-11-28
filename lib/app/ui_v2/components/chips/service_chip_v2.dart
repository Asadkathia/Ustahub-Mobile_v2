import 'package:ustahub/app/export/exports.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';

class ServiceChipV2 extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const ServiceChipV2({
    super.key,
    required this.label,
    required this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smVertical,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColorsV2.primary.withOpacity(0.12)
              : AppColorsV2.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          border: Border.all(
            color:
                isSelected ? AppColorsV2.primary : AppColorsV2.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSpacing.iconSmall,
              color:
                  isSelected ? AppColorsV2.primary : AppColorsV2.textSecondary,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected
                    ? AppColorsV2.primary
                    : AppColorsV2.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

