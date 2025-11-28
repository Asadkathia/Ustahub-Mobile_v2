import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ustahub/app/modules/booking_request/model_class/BookingRequestModel.dart';
import 'package:ustahub/network/booking_api_service.dart';
import 'package:ustahub/utils/booking_card_mapper.dart';

class ProviderCalendarController extends GetxController {
  final selectedDate = DateTime.now().obs;
  final bookings = <BookingRequestModel>[].obs;
  final isLoading = false.obs;
  final BookingApiService _bookingApi = BookingApiService();

  @override
  void onInit() {
    super.onInit();
    fetchBookingsForDate(selectedDate.value);
  }

  /// Fetch all bookings for the provider (accepted, pending, completed)
  Future<void> fetchBookingsForDate(DateTime date) async {
    isLoading.value = true;
    try {
      final response = await _bookingApi.listBookings(
        role: 'provider',
        status: 'all',
        pageSize: 200,
      );
      final body = response['body'] as Map<String, dynamic>? ?? {};
      
      if (body['success'] == true && body['data'] != null) {
        final List data = body['data'] as List;
        bookings.value = data.map((e) {
          try {
            final mapped = BookingCardMapper.toLegacyForProvider(
              e as Map<String, dynamic>,
            );
            return BookingRequestModel.fromJson(mapped);
          } catch (parseError) {
            print('[CALENDAR] Parse error: $parseError');
            rethrow;
          }
        }).toList();
        
        print('[CALENDAR] Loaded ${bookings.length} bookings');
      } else {
        bookings.clear();
      }
    } catch (e) {
      print('[CALENDAR] Error fetching bookings: $e');
      bookings.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Get bookings for the selected date
  List<BookingRequestModel> get selectedDateBookings {
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    return bookings.where((booking) {
      final bookingDate = booking.bookingDate;
      if (bookingDate.isEmpty) return false;
      
      // Handle different date formats
      try {
        final parsedDate = DateTime.parse(bookingDate);
        final bookingDateKey = DateFormat('yyyy-MM-dd').format(parsedDate);
        return bookingDateKey == dateKey;
      } catch (e) {
        // If parsing fails, try direct string comparison
        return bookingDate.startsWith(dateKey);
      }
    }).toList();
  }

  /// Get bookings for a specific hour (0-23)
  List<BookingRequestModel> getBookingsForHour(int hour) {
    return selectedDateBookings.where((booking) {
      try {
        final timeStr = booking.bookingTime;
        if (timeStr.isEmpty) return false;
        
        // Parse time string (format: HH:MM:SS or HH:MM)
        final parts = timeStr.split(':');
        if (parts.isEmpty) return false;
        
        final bookingHour = int.tryParse(parts[0]);
        return bookingHour == hour;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Check if a booking is completed
  bool isCompleted(BookingRequestModel booking) {
    return booking.status.toLowerCase() == 'completed';
  }

  void onDaySelected(DateTime date, DateTime _) {
    selectedDate.value = date;
    // Refresh bookings when date changes
    fetchBookingsForDate(date);
  }
}
