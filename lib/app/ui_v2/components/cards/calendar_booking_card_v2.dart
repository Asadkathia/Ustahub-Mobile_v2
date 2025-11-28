import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/booking_request/model_class/BookingRequestModel.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';

/// UI v2 Calendar Booking Card - Modern design with teal accent
class CalendarBookingCardV2 extends StatelessWidget {
  final BookingRequestModel booking;
  final bool isCompleted;
  final VoidCallback? onTap;

  const CalendarBookingCardV2({
    super.key,
    required this.booking,
    this.isCompleted = false,
    this.onTap,
  });

  String _formatAddress(AddressModel? address) {
    if (address == null) return "Address not available";
    
    final parts = <String>[];
    
    final addressLine = address.address.trim();
    if (addressLine.isNotEmpty && addressLine != 'null') {
      parts.add(addressLine);
    }
    
    final city = address.city.trim();
    if (city.isNotEmpty && city != 'null') {
      parts.add(city);
    }
    
    final state = address.state.trim();
    if (state.isNotEmpty && state != 'null') {
      parts.add(state);
    }
    
    final country = address.country.trim();
    if (country.isNotEmpty && country != 'null') {
      parts.add(country);
    }
    
    final postalCode = address.postalCode.trim();
    
    if (parts.isEmpty && postalCode.isEmpty) {
      return "Address not available";
    }
    
    if (parts.isEmpty) {
      return postalCode;
    }
    
    if (postalCode.isNotEmpty && postalCode != 'null') {
      return "${parts.join(", ")} - $postalCode";
    }
    
    return parts.join(", ");
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColorsV2.warning;
      case 'accepted':
        return AppColorsV2.info;
      case 'completed':
        return AppColorsV2.success;
      case 'rejected':
        return AppColorsV2.error;
      case 'in_progress':
        return AppColorsV2.primary;
      default:
        return AppColorsV2.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: Container(
          margin: EdgeInsets.only(bottom: AppSpacing.mdVertical),
          decoration: BoxDecoration(
            color: AppColorsV2.background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(
              color: isCompleted
                  ? AppColorsV2.borderLight
                  : AppColorsV2.primary.withOpacity(0.2),
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
          child: Stack(
            children: [
              // Cross-out overlay for completed bookings
              if (isCompleted)
                Positioned.fill(
                  child: CustomPaint(
                    painter: CrossOutPainterV2(),
                  ),
                ),
              // Card content
              Opacity(
                opacity: isCompleted ? 0.6 : 1.0,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header: Service icon and name
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Service icon
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: AppColorsV2.primaryContainer,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                            ),
                            child: Icon(
                              Icons.home_repair_service_rounded,
                              color: AppColorsV2.primary,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          // Service name and booking ID
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.service?.name ?? "Service",
                                  style: AppTextStyles.heading4,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: AppSpacing.xsVertical),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColorsV2.primaryContainer,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                  ),
                                  child: Text(
                                    "#${booking.bookingId}",
                                    style: AppTextStyles.captionSmall.copyWith(
                                      color: AppColorsV2.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: AppSpacing.mdVertical),
                      
                      // Address section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16.sp,
                            color: AppColorsV2.textSecondary,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              _formatAddress(booking.address),
                              style: AppTextStyles.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: AppSpacing.smVertical),
                      
                      // Date and Time
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 16.sp,
                            color: AppColorsV2.textSecondary,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              "${formatDate(booking.bookingDate)} - ${convertTo12HourFormat(booking.bookingTime)}",
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColorsV2.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: AppSpacing.smVertical),
                      
                      // Consumer name
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 16.sp,
                            color: AppColorsV2.textSecondary,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              booking.consumer?.name ?? "Customer",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColorsV2.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      // Status badge
                      if (booking.status.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: AppSpacing.smVertical),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(booking.status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                              ),
                              child: Text(
                                booking.status.toUpperCase(),
                                style: AppTextStyles.captionSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(booking.status),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter to draw a diagonal cross-out line for completed bookings
class CrossOutPainterV2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColorsV2.textSecondary
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw diagonal line from top-left to bottom-right
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, size.height),
      paint,
    );

    // Draw diagonal line from top-right to bottom-left
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

