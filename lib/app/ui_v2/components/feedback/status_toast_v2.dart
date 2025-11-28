import 'package:ustahub/app/export/exports.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';

enum StatusToastType { success, info, warning, error }

class StatusToastV2 extends StatelessWidget {
  final String message;
  final StatusToastType type;

  const StatusToastV2({
    super.key,
    required this.message,
    this.type = StatusToastType.info,
  });

  Color _backgroundColor() {
    switch (type) {
      case StatusToastType.success:
        return AppColorsV2.success.withOpacity(0.1);
      case StatusToastType.warning:
        return AppColorsV2.warning.withOpacity(0.1);
      case StatusToastType.error:
        return AppColorsV2.error.withOpacity(0.1);
      case StatusToastType.info:
      default:
        return AppColorsV2.primary.withOpacity(0.1);
    }
  }

  Color _accentColor() {
    switch (type) {
      case StatusToastType.success:
        return AppColorsV2.success;
      case StatusToastType.warning:
        return AppColorsV2.warning;
      case StatusToastType.error:
        return AppColorsV2.error;
      case StatusToastType.info:
      default:
        return AppColorsV2.primary;
    }
  }

  IconData _icon() {
    switch (type) {
      case StatusToastType.success:
        return Icons.check_circle;
      case StatusToastType.warning:
        return Icons.warning_rounded;
      case StatusToastType.error:
        return Icons.error_rounded;
      case StatusToastType.info:
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smVertical,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon(),
            color: _accentColor(),
            size: AppSpacing.iconMedium,
          ),
          SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: _accentColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

