import 'package:ustahub/network/supabase_api_services.dart';

class CheckoutRepository {
  final _api = SupabaseApiServices();

  Future<dynamic> getTimeSlots({
    required String providerId,
    required String date,
  }) async {
    // Use Supabase database function to get booking slots
    final response = await _api.getBookingSlots(providerId, date);
    
    // Transform response to match expected format
    if (response['statusCode'] == 200 && response['body']['data'] != null) {
      return {
        'statusCode': 200,
        'body': {
          'status': true,
          'slots': response['body']['data'],
        },
      };
    }
    return response;
  }
}
