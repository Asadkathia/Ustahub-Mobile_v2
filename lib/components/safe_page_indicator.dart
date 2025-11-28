import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SafePageIndicator extends StatelessWidget {
  final PageController controller;
  final int count;
  final IndicatorEffect? effect;
  final Function(int)? onDotClicked;

  const SafePageIndicator({
    super.key,
    required this.controller,
    required this.count,
    this.effect,
    this.onDotClicked,
  });

  @override
  Widget build(BuildContext context) {
    // Validate count to prevent rendering issues
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    // Ensure we have a valid page controller with proper initialization
    if (!controller.hasClients) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double page = 0.0;
        try {
          page = controller.page ?? controller.initialPage.toDouble();

          // Validate page value to prevent Infinity/NaN
          if (!page.isFinite) {
            page = controller.initialPage.toDouble();
          }

          // Clamp page to valid range
          page = page.clamp(0.0, (count - 1).toDouble());
        } catch (e) {
          page = controller.initialPage.toDouble();
        }

        return SmoothPageIndicator(
          controller: controller,
          count: count,
          effect:
              effect ??
              const WormEffect(dotHeight: 8.0, dotWidth: 8.0, spacing: 4.0),
          onDotClicked: onDotClicked,
        );
      },
    );
  }
}

class SafeAnimatedSmoothIndicator extends StatelessWidget {
  final int activeIndex;
  final int count;
  final IndicatorEffect? effect;
  final Function(int)? onDotClicked;

  const SafeAnimatedSmoothIndicator({
    super.key,
    required this.activeIndex,
    required this.count,
    this.effect,
    this.onDotClicked,
  });

  @override
  Widget build(BuildContext context) {
    // Validate inputs
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final safeActiveIndex = activeIndex.clamp(0, count - 1);

    return AnimatedSmoothIndicator(
      activeIndex: safeActiveIndex,
      count: count,
      effect:
          effect ??
          const WormEffect(dotHeight: 8.0, dotWidth: 8.0, spacing: 4.0),
      onDotClicked: onDotClicked,
    );
  }
}
