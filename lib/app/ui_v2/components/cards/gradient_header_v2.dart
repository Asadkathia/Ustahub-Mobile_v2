import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../design_system/colors/app_colors_v2.dart';

class GradientHeaderV2 extends StatelessWidget {
  final Widget child;
  final double? height;

  const GradientHeaderV2({
    super.key,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColorsV2.primaryGradient,
      ),
      child: child,
    );
  }
}

