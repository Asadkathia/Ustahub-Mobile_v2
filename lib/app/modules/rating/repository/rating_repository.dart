import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class RatingRepository {
  final _apiServices = SupabaseApiServices();

  Future<Map<String, dynamic>> rateProvider({
    required String providerId,
    required String bookingId,
    required int stars,
    required String review,
  }) async {
    try {
      print('Rating provider...');

      final requestData = RateProviderRequest(
        providerId: providerId,
        stars: stars,
        review: review,
      );

      print('Request data: ${requestData.toJson()}');

      final response = await _apiServices.rateProvider({
        'provider_id': providerId,
        'booking_id': bookingId,
        'rating': stars,
        'review': review,
      });

      print('Rate Provider API Response: $response');
      return response;
    } catch (e) {
      print('Error in rateProvider: $e');
      rethrow;
    }
  }
}
