import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';

/// UI v2 Booking Card Component for Consumer Bookings
class BookingCardV2 extends StatelessWidget {
  final String imageUrl;
  final String serviceTitle;
  final String providerName;
  final String date;
  final String time;
  final VoidCallback greyButtonOnTap;
  final VoidCallback greenButtonOnTap;
  final String greyButtonText;
  final String greenButtonText;
  final bool isShowCompleted;
  final bool? isShowCancelButton;

  const BookingCardV2({
    super.key,
    required this.imageUrl,
    required this.serviceTitle,
    required this.providerName,
    required this.date,
    required this.time,
    required this.greyButtonOnTap,
    required this.greenButtonOnTap,
    required this.greyButtonText,
    required this.greenButtonText,
    required this.isShowCompleted,
    this.isShowCancelButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColorsV2.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: AppColorsV2.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorsV2.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Image, Title, and Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider/Service Image
              Container(
                height: 80.h,
                width: 80.w,
                decoration: BoxDecoration(
                  color: AppColorsV2.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColorsV2.primary,
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.person_outline_rounded,
                      color: AppColorsV2.textSecondary,
                      size: 32.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // Service and Provider Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Title
                    Text(
                      serviceTitle,
                      style: AppTextStyles.heading4,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.xsVertical),
                    // Provider Name
                    Text(
                      "Provider: $providerName",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColorsV2.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.smVertical),
                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14.sp,
                          color: AppColorsV2.textSecondary,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            date,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xsVertical),
                    // Time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14.sp,
                          color: AppColorsV2.textSecondary,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            time,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status Badge
              if (isShowCompleted)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColorsV2.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Text(
                    "Completed",
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColorsV2.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: AppSpacing.mdVertical),
          
          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: AppColorsV2.borderLight,
          ),
          
          SizedBox(height: AppSpacing.mdVertical),
          
          // Bottom row: Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Grey/Secondary Button (Rebook/Cancel)
              if (isShowCancelButton == true)
                Expanded(
                  child: OutlinedButton(
                    onPressed: greyButtonOnTap,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.smVertical,
                      ),
                      side: BorderSide(
                        color: AppColorsV2.borderMedium,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                    ),
                    child: Text(
                      greyButtonText,
                      style: AppTextStyles.buttonSmall.copyWith(
                        color: AppColorsV2.textPrimary,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              
              if (isShowCancelButton == true) SizedBox(width: AppSpacing.md),
              
              // Primary Button (View Details/Rate Now)
              Expanded(
                child: ElevatedButton(
                  onPressed: greenButtonOnTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorsV2.primary,
                    foregroundColor: AppColorsV2.textOnPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.smVertical,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    greenButtonText,
                    style: AppTextStyles.buttonSmall,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

