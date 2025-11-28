import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/booking_request/model_class/BookingRequestModel.dart';

/// Compact booking card specifically designed for calendar view
class CalendarBookingCard extends StatelessWidget {
  final BookingRequestModel booking;
  final bool isCompleted;

  const CalendarBookingCard({
    super.key,
    required this.booking,
    this.isCompleted = false,
  });

  /// Helper method to format address with proper null checks
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h, right: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isCompleted ? Colors.grey.shade300 : AppColors.green.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                painter: CrossOutPainter(),
              ),
            ),
          // Card content
          Opacity(
            opacity: isCompleted ? 0.7 : 1.0,
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header: Service name and booking ID
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service icon
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.home_repair_service,
                          color: AppColors.green,
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Service name and booking ID
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Service name - full width, no truncation
                            Text(
                              booking.service?.name ?? "Service",
                              style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp,
                                color: AppColors.blackText,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            // Booking ID - smaller, compact
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                "#${booking.bookingId}",
                                style: GoogleFonts.ubuntu(
                                  color: AppColors.green,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
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
                  
                  SizedBox(height: 12.h),
                  
                  // Address section
                  if (booking.address != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16.sp,
                          color: AppColors.grey,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            _formatAddress(booking.address),
                            style: GoogleFonts.ubuntu(
                              fontSize: 12.sp,
                              color: AppColors.blackText,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16.sp,
                          color: AppColors.grey,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            "Address not available",
                            style: GoogleFonts.ubuntu(
                              fontSize: 12.sp,
                              color: AppColors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  SizedBox(height: 10.h),
                  
                  // Date and Time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16.sp,
                        color: AppColors.grey,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "${formatDate(booking.bookingDate)} - ${convertTo12HourFormat(booking.bookingTime)}",
                        style: GoogleFonts.ubuntu(
                          fontSize: 12.sp,
                          color: AppColors.blackText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 10.h),
                  
                  // Consumer name
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16.sp,
                        color: AppColors.grey,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          booking.consumer?.name ?? "Customer",
                          style: GoogleFonts.ubuntu(
                            fontSize: 12.sp,
                            color: AppColors.blackText,
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
                      padding: EdgeInsets.only(top: 10.h),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(booking.status).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            booking.status.toUpperCase(),
                            style: GoogleFonts.ubuntu(
                              fontSize: 10.sp,
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return AppColors.green;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
        return Colors.purple;
      default:
        return AppColors.grey;
    }
  }
}

/// Custom painter to draw a diagonal cross-out line
class CrossOutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
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

