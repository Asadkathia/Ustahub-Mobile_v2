import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_bookings/model/booking_history_model.dart';
import 'package:ustahub/app/modules/provider_bookings/repository/booking_history_repository.dart';

class BookingHistoryController extends GetxController {
  final BookingHistoryRepository _repository = BookingHistoryRepository();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ProviderBookingHistoryResponse> historyData =
      ProviderBookingHistoryResponse(status: false, count: 0, bookings: []).obs;

  // Getter for easy access to bookings list
  List<HistoryBooking> get bookings => historyData.value.bookings;
  bool get isEmpty => bookings.isEmpty;
  int get bookingCount => historyData.value.count;

  // Fetch booking history
  Future<void> fetchBookingHistory() async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      print('Fetching booking history...');

      final response = await _repository.getBookingHistory();

      print('Booking History API Response: $response');

      // Check if the response is successful
      if (response['statusCode'] == 200) {
        final responseBody = response['body'];

        // Handle successful response - check for 'status' field
        if (responseBody['status'] == true) {
          // Parse the response using ProviderBookingHistoryResponse model
          final historyResponse = ProviderBookingHistoryResponse.fromJson(
            responseBody,
          );

          // Update history data
          historyData.value = historyResponse;

          print(
            'Booking history fetched successfully: ${bookings.length} bookings',
          );
        } else {
          // Handle API error response
          final errorMsg =
              responseBody['message'] ?? 'Failed to fetch booking history';
          print('API Error: $errorMsg');

          isError.value = true;
          errorMessage.value = errorMsg;
          CustomToast.error(errorMsg);
          throw Exception(errorMsg);
        }
      } else {
        // Handle HTTP error response
        final errorMsg =
            response['body']?['message'] ?? 'Failed to fetch booking history';
        print('HTTP Error: $errorMsg');

        isError.value = true;
        errorMessage.value = errorMsg;
        CustomToast.error(errorMsg);
        throw Exception(errorMsg);
      }
    } catch (e) {
      isError.value = true;
      print('Error fetching booking history: $e');

      // Show error message using CustomToast
      String errorMsg = 'Failed to fetch booking history';
      if (e.toString().contains('Exception:')) {
        errorMsg = e.toString().replaceAll('Exception: ', '');
      } else {
        errorMsg = 'Failed to fetch booking history: ${e.toString()}';
      }

      errorMessage.value = errorMsg;
      CustomToast.error(errorMsg);
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh booking history
  Future<void> refreshHistory() async {
    await fetchBookingHistory();
  }

  // Reset error state
  void clearError() {
    isError.value = false;
    errorMessage.value = '';
  }

  // Filter bookings by status
  List<HistoryBooking> getBookingsByStatus(String status) {
    return bookings
        .where(
          (booking) => booking.status.toLowerCase() == status.toLowerCase(),
        )
        .toList();
  }

  // Get bookings count by status
  int getBookingsCountByStatus(String status) {
    return getBookingsByStatus(status).length;
  }

  @override
  void onInit() {
    super.onInit();
    // Auto-fetch when controller initializes
    fetchBookingHistory();
  }

}
