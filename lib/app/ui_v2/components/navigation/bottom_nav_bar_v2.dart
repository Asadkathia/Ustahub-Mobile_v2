import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ustahub/app/export/exports.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';

class BottomNavBarV2 extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String role;

  const BottomNavBarV2({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusLarge),
          topRight: Radius.circular(AppSpacing.radiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorsV2.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context,
            AppLocalizations.of(context)!.home,
            AppVectors.svgHome,
            0,
          ),
          _navItem(
            context,
            AppLocalizations.of(context)!.chat,
            AppVectors.svgChat,
            1,
          ),
          _navItem(
            context,
            AppLocalizations.of(context)!.booking,
            AppVectors.svgBooking,
            2,
          ),
          _navItem(
            context,
            AppLocalizations.of(context)!.account,
            AppVectors.svgAccount,
            3,
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, String label, String assetPath, int index) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColorsV2.primary : AppColorsV2.textSecondary;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetPath,
              height: 24.h,
              width: 24.w,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 12.sp,
              ),
            ),
            if (isSelected)
              Container(
                margin: EdgeInsets.only(top: 4.h),
                width: 4.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColorsV2.primary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

