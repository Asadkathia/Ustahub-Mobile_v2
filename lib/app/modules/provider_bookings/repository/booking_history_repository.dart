import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/booking_api_service.dart';
import 'package:ustahub/utils/booking_card_mapper.dart';

class BookingHistoryRepository {
  final BookingApiService _bookingApi = BookingApiService();

  Future<dynamic> getBookingHistory() async {
    try {
      print('Fetching booking history...');

      final response = await _bookingApi.listBookings(
        role: 'provider',
        status: 'history',
        pageSize: 100,
      );

      final body = response['body'] as Map<String, dynamic>? ?? {};

      if (body['success'] == true && body['data'] != null) {
        final List<dynamic> data = body['data'] as List<dynamic>;
        final bookings = data
            .map(
              (card) => BookingCardMapper.toLegacyForProvider(
                card as Map<String, dynamic>,
              ),
            )
            .toList();

        return {
          'statusCode': 200,
          'body': {
            'status': true,
            'count': bookings.length,
            'bookings': bookings,
          },
        };
      }

      return {
        'statusCode': response['statusCode'] ?? 500,
        'body': {
          'status': false,
          'message': body['message'] ?? 'Failed to fetch booking history',
        },
      };
    } catch (e) {
      print('Error in getBookingHistory repository: $e');
      throw Exception('Failed to fetch booking history: $e');
    }
  }
}
