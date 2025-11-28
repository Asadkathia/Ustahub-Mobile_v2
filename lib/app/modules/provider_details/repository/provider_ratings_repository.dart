import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class ProviderRatingsRepository {
  final _apiServices = SupabaseApiServices();

  Future<Map<String, dynamic>> getProviderRatings({
    required String providerId,
  }) async {
    try {
      print('Fetching provider ratings for provider ID: $providerId');

      final response = await _apiServices.getProviderRatings(providerId);

      print('Provider Ratings API Response: $response');
      return response;
    } catch (e) {
      print('Error in getProviderRatings: $e');
      rethrow;
    }
  }
}
