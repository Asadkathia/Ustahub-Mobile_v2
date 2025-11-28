import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:ustahub/app/export/exports.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/spacing/app_spacing.dart';
import '../../design_system/typography/app_text_styles.dart';

class BannerCarouselItem {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback? onTap;

  const BannerCarouselItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.onTap,
  });
}

class BannerCarouselV2 extends StatefulWidget {
  final List<BannerCarouselItem> items;
  final double height;

  const BannerCarouselV2({
    super.key,
    required this.items,
    this.height = 200,
  });

  @override
  State<BannerCarouselV2> createState() => _BannerCarouselV2State();
}

class _BannerCarouselV2State extends State<BannerCarouselV2> {
  int _currentIndex = 0;
  late final CarouselSliderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CarouselSliderController();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _controller,
          itemCount: widget.items.length,
          itemBuilder: (context, index, _) {
            final item = widget.items[index];
            return GestureDetector(
              onTap: item.onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColorsV2.surface,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColorsV2.textSecondary,
                            size: AppSpacing.iconXLarge,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColorsV2.overlayGradient,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            item.title,
                            style: AppTextStyles.heading2White,
                          ),
                          SizedBox(height: AppSpacing.xsVertical),
                          Text(
                            item.subtitle,
                            style: AppTextStyles.bodyMediumWhite,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          options: CarouselOptions(
            viewportFraction: 1,
            height: widget.height,
            autoPlay: true,
            enlargeCenterPage: false,
            onPageChanged: (index, _) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        SizedBox(height: AppSpacing.smVertical),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => Container(
              width: _currentIndex == index ? 20.w : 8.w,
              height: 6.h,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? AppColorsV2.primary
                    : AppColorsV2.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

