import 'package:ustahub/app/modules/booking_summary/repository/booking_summary_repository.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/service_success/view/service_success_view.dart';
import 'package:ustahub/app/ui_v2/screens/guest/login_required_screen_v2.dart';

class BookingSummaryController extends GetxController {
  final BookingSummaryRepository _repository = BookingSummaryRepository();
  RxBool isLoading = false.obs;

  /// Check authentication and role
  Future<bool> _checkAuth({required String requiredRole}) async {
    final userId = SupabaseClientService.currentUserId;
    if (userId == null) {
      Get.to(() => LoginRequiredScreenV2(feature: 'Booking'));
      return false;
    }
    final role = await Sharedprefhelper.getRole();
    if (requiredRole == 'consumer' && role != 'consumer') {
      CustomToast.error('This feature is only available for consumers');
      return false;
    }
    if (requiredRole == 'provider' && role != 'provider') {
      CustomToast.error('This feature is only available for providers');
      return false;
    }
    return true;
  }

  Future<String?> bookService({required Map<String, dynamic> bookingData}) async {
    // Check authentication before proceeding
    if (!await _checkAuth(requiredRole: 'consumer')) {
      return null;
    }
    
    print(bookingData);
    isLoading.value = true;
    try {
      final response = await _repository.bookService(bookingData);
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        CustomToast.success("Booking successful");
        
        // Extract booking ID from response
        String? bookingId;
        if (response['body'] != null && response['body']['data'] != null) {
          final data = response['body']['data'];
          bookingId = data['id']?.toString() ?? 
                     data['booking_id']?.toString() ??
                     bookingData['booking_id']?.toString();
        } else {
          bookingId = bookingData['booking_id']?.toString();
        }
        
        // Get provider details for success screen
        final providerName = bookingData['provider_name'] ?? 'Provider';
        final serviceName = bookingData['service_name'] ?? 'Service';
        
        Get.to(
          () => ServiceSuccessView(
            bookingId: bookingId,
            providerName: providerName,
            serviceName: serviceName,
            bookingDate: bookingData['booking_date'],
            bookingTime: bookingData['booking_time'],
            totalAmount: bookingData['total']?.toString() ?? 
                        (bookingData['item_total']?.toString() ?? '0'),
          ),
        );
        
        return bookingId;
      } else {
        CustomToast.error(
          response['body']['message'] ?? 'Failed to book service',
        );
        return null;
      }
    } catch (e) {
      CustomToast.error('Error: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
