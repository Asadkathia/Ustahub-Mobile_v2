import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../design_system/colors/app_colors_v2.dart';

class BlurredBackgroundV2 extends StatelessWidget {
  final String imagePath;
  final Widget child;
  final double blurSigma;
  final Color? overlayColor;

  const BlurredBackgroundV2({
    super.key,
    required this.imagePath,
    required this.child,
    this.blurSigma = 10.0,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
        // Blur Effect
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              color: overlayColor ?? AppColorsV2.gradientStart.withOpacity(0.3),
            ),
          ),
        ),
        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: overlayColor != null
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      overlayColor!.withOpacity(0.6),
                      overlayColor!.withOpacity(0.8),
                    ],
                  )
                : AppColorsV2.overlayGradient,
          ),
        ),
        // Content
        child,
      ],
    );
  }
}

