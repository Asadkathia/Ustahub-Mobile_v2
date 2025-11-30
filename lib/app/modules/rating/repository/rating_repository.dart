import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class RatingRepository {
  final _apiServices = SupabaseApiServices();

  Future<Map<String, dynamic>> rateProvider({
    required String providerId,
    required String bookingId,
    required int stars,
    required String review,
    List<String>? imageUrls,
    Map<String, double>? categoryRatings,
  }) async {
    try {
      print('Rating provider...');

      final requestData = RateProviderRequest(
        providerId: providerId,
        stars: stars,
        review: review,
      );

      print('Request data: ${requestData.toJson()}');

      final data = {
        'provider_id': providerId,
        'booking_id': bookingId,
        'rating': stars,
        'review': review,
        if (imageUrls != null && imageUrls.isNotEmpty) 'image_urls': imageUrls,
        if (categoryRatings != null && categoryRatings.isNotEmpty)
          'category_ratings': categoryRatings,
      };

      final response = await _apiServices.rateProvider(data);

      print('Rate Provider API Response: $response');
      return response;
    } catch (e) {
      print('Error in rateProvider: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> voteReviewHelpful(
    String ratingId,
    bool isHelpful,
  ) async {
    try {
      final response = await _apiServices.voteReviewHelpful(ratingId, isHelpful);
      return response;
    } catch (e) {
      print('Error in voteReviewHelpful: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> respondToReview(
    String ratingId,
    String responseText,
  ) async {
    try {
      final response = await _apiServices.respondToReview(ratingId, responseText);
      return response;
    } catch (e) {
      print('Error in respondToReview: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getReviewsWithFilters(
    String providerId, {
    String? sortBy,
    bool? withPhotos,
    bool? verifiedOnly,
  }) async {
    try {
      final response = await _apiServices.getReviewsWithFilters(
        providerId,
        sortBy: sortBy,
        withPhotos: withPhotos,
        verifiedOnly: verifiedOnly,
      );
      return response;
    } catch (e) {
      print('Error in getReviewsWithFilters: $e');
      rethrow;
    }
  }
}
