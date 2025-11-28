import 'package:flutter/foundation.dart';
import 'package:ustahub/app/modules/bookings/model_class/booking_model_class.dart';
import 'package:ustahub/network/booking_api_service.dart';
import 'package:ustahub/utils/booking_card_mapper.dart';

class BookingRepository {
  final BookingApiService _bookingApi = BookingApiService();

  Future<List<BookingModel>> getUpcomingBookings() async {
    return _getBookingsByStatus('not_started');
  }

  Future<List<BookingModel>> getOngoingBookings() async {
    return _getBookingsByStatus('ongoing');
  }

  Future<List<BookingModel>> getCompletedBookings() async {
    return _getBookingsByStatus('completed');
  }

  Future<List<BookingModel>> _getBookingsByStatus(String status) async {
    try {
      final response = await _bookingApi.listBookings(
        role: 'consumer',
        status: status,
      );

      if (response['body']['success'] != true) {
        debugPrint('[BOOKING_REPO] API error: ${response['body']['message']}');
        return [];
      }

      final List<dynamic> data = response['body']['data'] as List<dynamic>? ?? [];
      return data
          .map(
            (card) => BookingModel.fromJson(
              BookingCardMapper.toLegacyForConsumer(card as Map<String, dynamic>),
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('[BOOKING_REPO] ❌ Error fetching bookings: $e');
      return [];
    }
  }
}
