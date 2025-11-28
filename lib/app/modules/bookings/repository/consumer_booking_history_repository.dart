import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/booking_api_service.dart';
import 'package:ustahub/utils/booking_card_mapper.dart';

class ConsumerBookingHistoryRepository {
  final BookingApiService _bookingApi = BookingApiService();

  Future<Map<String, dynamic>> getConsumerBookingHistory() async {
    try {
      print('Fetching consumer booking history...');

      final response = await _bookingApi.listBookings(
        role: 'consumer',
        status: 'history',
        pageSize: 100,
      );

      final body = response['body'] as Map<String, dynamic>? ?? {};
      if (body['success'] == true && body['data'] != null) {
        final List<dynamic> data = body['data'] as List<dynamic>;
        final bookings = data
            .map(
              (card) => BookingCardMapper.toLegacyForConsumer(
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
      print('Error in getConsumerBookingHistory: $e');
      rethrow;
    }
  }
}
