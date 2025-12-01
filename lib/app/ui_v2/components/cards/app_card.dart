import 'package:flutter/material.dart';
import 'package:ustahub/app/ui_v2/design_system/colors/app_colors_v2.dart';
import 'package:ustahub/app/ui_v2/design_system/shadows/app_shadows.dart';
import 'package:ustahub/app/ui_v2/design_system/spacing/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool bordered;
  final bool enableShadow;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.bordered = true,
    this.enableShadow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? EdgeInsets.all(AppSpacing.cardPadding),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColorsV2.cardBackground,
        borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLarge),
        border: bordered
            ? Border.all(
                color: AppColorsV2.borderLight,
                width: 1,
              )
            : null,
        boxShadow: enableShadow ? AppShadows.subtle : null,
      ),
      child: child,
    );

    if (onTap == null) return card;

    return InkWell(
      borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLarge),
      onTap: onTap,
      child: card,
    );
  }
}

