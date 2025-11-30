import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ustahub/app/ui_v2/design_system/colors/app_colors_v2.dart';
import 'package:ustahub/app/ui_v2/design_system/spacing/app_spacing.dart';

/// Standardized skeleton loader widget for consistent loading states
class SkeletonLoaderV2 extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoaderV2({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColorsV2.borderLight,
      highlightColor: AppColorsV2.background,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColorsV2.borderLight,
          borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusRound),
        ),
      ),
    );
  }
}

/// Skeleton loader for list items (e.g., booking cards, provider cards)
class SkeletonListItemV2 extends StatelessWidget {
  final double? height;
  final EdgeInsets? padding;

  const SkeletonListItemV2({
    super.key,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 120.h,
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      margin: EdgeInsets.only(bottom: AppSpacing.smVertical),
      decoration: BoxDecoration(
        color: AppColorsV2.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: Row(
        children: [
          SkeletonLoaderV2(
            width: 80.w,
            height: 80.h,
            borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonLoaderV2(
                  width: double.infinity,
                  height: 16.h,
                ),
                SizedBox(height: AppSpacing.smVertical),
                SkeletonLoaderV2(
                  width: 150.w,
                  height: 14.h,
                ),
                SizedBox(height: AppSpacing.xsVertical),
                SkeletonLoaderV2(
                  width: 100.w,
                  height: 14.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for grid items
class SkeletonGridItemV2 extends StatelessWidget {
  const SkeletonGridItemV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColorsV2.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoaderV2(
            width: double.infinity,
            height: 120.h,
            borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          ),
          SizedBox(height: AppSpacing.mdVertical),
          SkeletonLoaderV2(
            width: double.infinity,
            height: 16.h,
          ),
          SizedBox(height: AppSpacing.smVertical),
          SkeletonLoaderV2(
            width: 100.w,
            height: 14.h,
          ),
        ],
      ),
    );
  }
}

