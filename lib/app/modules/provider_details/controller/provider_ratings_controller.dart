import 'package:ustahub/app/export/exports.dart';

class ProviderRatingsController extends GetxController {
  final ProviderRatingsRepository _repository = ProviderRatingsRepository();

  // Observable variables
  final RxBool isLoadingRatings = false.obs;
  final RxBool isRatingsError = false.obs;
  final RxString ratingsErrorMessage = ''.obs;
  final Rx<ProviderRatingsResponse> ratingsData =
      ProviderRatingsResponse(status: false, ratings: []).obs;

  // Getter for easy access to ratings list
  List<ProviderRating> get allRatings => ratingsData.value.ratings;

  // Get only the latest 5 ratings
  List<ProviderRating> get latestFiveRatings {
    final sortedRatings = List<ProviderRating>.from(allRatings);
    // Sort by creation date in descending order (latest first)
    sortedRatings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    // Return only the first 5
    return sortedRatings.take(5).toList();
  }

  bool get hasRatings => allRatings.isNotEmpty;
  int get ratingsCount => allRatings.length;

  // Fetch provider ratings
  Future<void> fetchProviderRatings(String providerId) async {
    try {
      isLoadingRatings.value = true;
      isRatingsError.value = false;
      ratingsErrorMessage.value = '';

      print('Fetching provider ratings for ID: $providerId');

      final response = await _repository.getProviderRatings(
        providerId: providerId,
      );

      print('Provider Ratings API Response: $response');

      // Check if the response is successful
      if (response['statusCode'] == 200) {
        final responseBody = response['body'];

        if (responseBody['status'] == true) {
          // SupabaseApiServices wraps raw rows under 'data'
          final dynamic data = responseBody['data'];
          print('[PROVIDER RATINGS] Raw data runtimeType: ${data.runtimeType}');
          final List<dynamic> rows =
              (data is List<dynamic>) ? data : <dynamic>[];

          print('[PROVIDER RATINGS] rows.length from API: ${rows.length}');

          final ratingsList = rows
              .map(
                (row) {
                  print('[PROVIDER RATINGS] Parsing row: ${row['id']}, rating: ${row['rating']}, user_profiles: ${row['user_profiles']}');
                  final parsed = ProviderRating.fromJson(
                    row as Map<String, dynamic>,
                  );
                  print('[PROVIDER RATINGS] Parsed rating: stars=${parsed.stars}, consumer.name=${parsed.consumer.name}, consumer.avatar=${parsed.consumer.avatar}');
                  return parsed;
                },
              )
              .toList();

          ratingsData.value = ProviderRatingsResponse(
            status: true,
            ratings: ratingsList,
          );

          print(
            'Provider ratings fetched successfully: ${allRatings.length} ratings',
          );
        } else {
          // Handle API error response
          final message =
              responseBody['message'] ?? 'Failed to fetch provider ratings';
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
      print("Catch error: $e");
      print('Error fetching provider ratings: $e');
      isRatingsError.value = true;
      ratingsErrorMessage.value = e.toString();
    } finally {
      isLoadingRatings.value = false;
    }
  }

  // Clear ratings data
  void clearRatings() {
    ratingsData.value = ProviderRatingsResponse(status: false, ratings: []);
    isRatingsError.value = false;
    ratingsErrorMessage.value = '';
  }

  // Refresh provider ratings
  Future<void> refreshProviderRatings(String providerId) async {
    await fetchProviderRatings(providerId);
  }

  @override
  void onClose() {
    // Clean up when controller is disposed
    clearRatings();
    super.onClose();
  }
}
