import 'package:ustahub/app/export/exports.dart';

class ConsumerBookingHistoryController extends GetxController {
  final ConsumerBookingHistoryRepository _repository =
      ConsumerBookingHistoryRepository();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ConsumerBookingHistoryResponse> historyData =
      ConsumerBookingHistoryResponse(status: false, count: 0, bookings: []).obs;

  // Getter for easy access to bookings list
  List<ConsumerHistoryBooking> get bookings => historyData.value.bookings;
  bool get isEmpty => bookings.isEmpty;
  int get bookingCount => historyData.value.count;

  // Fetch booking history
  Future<void> fetchConsumerBookingHistory() async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      print('Fetching consumer booking history...');

      final response = await _repository.getConsumerBookingHistory();

      print('Consumer Booking History API Response: $response');

      // Check if the response is successful
      if (response['statusCode'] == 200) {
        final responseBody = response['body'];

        // Handle successful response - check for 'status' field
        if (responseBody['status'] == true) {
          // Parse the response using ConsumerBookingHistoryResponse model
          final historyResponse = ConsumerBookingHistoryResponse.fromJson(
            responseBody,
          );

          // Update history data
          historyData.value = historyResponse;

          print(
            'Consumer booking history fetched successfully: ${bookings.length} bookings',
          );
        } else {
          // Handle API error response
          final message =
              responseBody['message'] ?? 'Failed to fetch booking history';
          throw Exception(message);
        }
      } else {
        // Handle HTTP error
        final responseBody = response['body'];
        final message =
            responseBody['message'] ?? 'HTTP Error: ${response['statusCode']}';
        throw Exception(message);
      }
    } catch (e) {
      print('Error fetching consumer booking history: $e');
      isError.value = true;
      errorMessage.value = e.toString();

      // Show error toast
      // CustomToast.error(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // Filter bookings by status
  List<ConsumerHistoryBooking> getBookingsByStatus(String status) {
    return bookings
        .where(
          (booking) => booking.status.toLowerCase() == status.toLowerCase(),
        )
        .toList();
  }

  // Get completed bookings
  List<ConsumerHistoryBooking> get completedBookings =>
      getBookingsByStatus('completed');

  // Get ongoing bookings (start status)
  List<ConsumerHistoryBooking> get ongoingBookings =>
      getBookingsByStatus('start');

  // Get pending/not started bookings
  List<ConsumerHistoryBooking> get pendingBookings =>
      bookings
          .where(
            (booking) =>
                booking.status.toLowerCase() == 'pending' ||
                booking.status.toLowerCase() == 'not_started',
          )
          .toList();

  // Get cancelled bookings
  List<ConsumerHistoryBooking> get cancelledBookings =>
      getBookingsByStatus('cancelled');

  // Refresh booking history
  Future<void> refreshBookingHistory() async {
    await fetchConsumerBookingHistory();
  }

  // Clear history data
  void clearHistory() {
    historyData.value = ConsumerBookingHistoryResponse(
      status: false,
      count: 0,
      bookings: [],
    );
    isError.value = false;
    errorMessage.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    // Auto-fetch history when controller is initialized
    fetchConsumerBookingHistory();
  }

  @override
  void onClose() {
    // Clean up when controller is disposed
    clearHistory();
    super.onClose();
  }
}
