import 'package:flutter/foundation.dart';
import 'package:ustahub/app/modules/provider_bookings/model/provider_booking_model.dart';
import 'package:ustahub/network/booking_api_service.dart';
import 'package:ustahub/utils/booking_card_mapper.dart';

class ProviderBookingRepository {
  final BookingApiService _bookingApi = BookingApiService();

  Future<ProviderBookingModel> providerBookingApi(String type) async {
    try {
      final response = await _bookingApi.listBookings(
        role: 'provider',
        status: type,
      );

      if (response['body']['success'] != true) {
        throw response['body']['message'] ?? 'Failed to load bookings';
      }

      final List<dynamic> bookings = response['body']['data'] as List<dynamic>? ?? [];
      final transformed = bookings
          .map(
            (card) => BookingCardMapper.toLegacyForProvider(
              card as Map<String, dynamic>,
            ),
          )
          .toList();

      return ProviderBookingModel.fromJson({
        'status': true,
        'type': type,
        'count': transformed.length,
        'bookings': transformed,
      });
    } catch (e) {
      debugPrint('[PROVIDER_BOOKING_REPO] Error: $e');
      rethrow;
    }
  }
}
