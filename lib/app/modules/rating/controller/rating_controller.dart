import 'package:ustahub/app/export/exports.dart';

class RatingController extends GetxController {
  final RatingRepository _repository = RatingRepository();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxDouble currentRating = 0.0.obs;
  final TextEditingController reviewController = TextEditingController();

  // Provider & booking info
  final RxString providerId = ''.obs;
  final RxString bookingId = ''.obs;
  final RxString providerName = ''.obs;
  final RxString providerImageUrl = ''.obs;

  // Initialize with provider & booking data
  void initializeRating({
    required String id,
    required String bookingId,
    String? name,
    String? imageUrl,
  }) {
    providerId.value = id;
    this.bookingId.value = bookingId;
    providerName.value = name ?? '';
    providerImageUrl.value = imageUrl ?? '';
  }

  // Update rating value
  void updateRating(double rating) {
    currentRating.value = rating;
  }

  // Submit rating
  Future<void> submitRating() async {
    if (providerId.value.isEmpty) {
      CustomToast.error('Provider ID is required');
      return;
    }

    if (currentRating.value == 0.0) {
      CustomToast.error('Please select a rating');
      return;
    }

    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';

      print('Submitting rating...');
      print('Provider ID: ${providerId.value}');
      print('Rating: ${currentRating.value}');
      print('Review: ${reviewController.text}');

      final response = await _repository.rateProvider(
        providerId: providerId.value,
        bookingId: bookingId.value,
        stars: currentRating.value.round(),
        review: reviewController.text.trim(),
      );

      print('Rating API Response: $response');

      // Check if the response is successful (Supabase insert returns 201)
      final statusCode = response['statusCode'] as int? ?? 0;
      if (statusCode == 200 || statusCode == 201) {
        final responseBody = response['body'];

        // Handle successful response
        if (responseBody['status'] == true) {
          final message =
              responseBody['message'] ?? 'Rating submitted successfully';

          CustomToast.success(message);

          // Navigate back after successful rating
          Get.back();

          print('Rating submitted successfully');
        } else {
          // Handle API error response
          final message = responseBody['message'] ?? 'Failed to submit rating';
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
      print('Error submitting rating: $e');
      isError.value = true;
      errorMessage.value = e.toString();

      // Show error toast
      CustomToast.error(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // Reset form
  void resetForm() {
    currentRating.value = 0.0;
    reviewController.clear();
    isError.value = false;
    errorMessage.value = '';
  }

  // Validate form
  bool get isFormValid {
    return providerId.value.isNotEmpty &&
        currentRating.value > 0.0 &&
        reviewController.text.trim().isNotEmpty;
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
