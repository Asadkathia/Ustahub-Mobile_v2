import 'package:get/get.dart';
import 'package:ustahub/app/modules/provider_homepage/model/provider_home_screen_model.dart';
import 'package:ustahub/app/modules/provider_homepage/repository/provider_home_screen_repository.dart';
import 'package:ustahub/components/custom_toast.dart';
import 'package:ustahub/utils/sharedPrefHelper/sharedPrefHelper.dart';

class ProviderHomeScreenController extends GetxController {
  final _repository = ProviderHomeScreenRepository();

  // Loading state
  final RxBool isLoading = false.obs;

  // Data properties
  final Rx<ProviderHomeScreenData?> homeScreenData =
      Rx<ProviderHomeScreenData?>(null);

  // Overview properties
  final RxInt bookingRequests = 0.obs;
  final RxInt calendarCount = 0.obs;

  // Ratings properties
  final RxInt ratingCount = 0.obs;
  final RxList<ProviderHomeRating> ratings = <ProviderHomeRating>[].obs;
  final RxString averageRating = '0.0'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProviderHomeScreenData();
  }

  Future<void> fetchProviderHomeScreenData() async {
    try {
      isLoading.value = true;
      print("[PROVIDER HOME DEBUG] 🚀 Fetching provider home screen data...");

      final response = await _repository.getProviderHomeScreenData();
      print("[PROVIDER HOME DEBUG] 📨 Raw response: $response");

      if (response != null && response['body'] != null) {
        final responseBody = response['body'];

        if (responseBody['status'] == true) {
          // Parse the response using the model
          final providerResponse =
              ProviderHomeScreenResponse.fromJson(responseBody);

          // Update the observable data
          homeScreenData.value = providerResponse.data;

          // Update individual properties for easy access
          bookingRequests.value = providerResponse.data.overview.bookingRequest;
          calendarCount.value = providerResponse.data.overview.calendar;

          ratingCount.value = providerResponse.data.ratings.ratingCount;
          ratings.value = providerResponse.data.ratings.ratings;
          averageRating.value = providerResponse.data.ratings.averageRating;

          print("[PROVIDER HOME DEBUG] ✅ Data loaded successfully");
          print(
            "[PROVIDER HOME DEBUG] 📊 Booking Requests: ${bookingRequests.value}",
          );
          print("[PROVIDER HOME DEBUG] 📅 Calendar: ${calendarCount.value}");
          print("[PROVIDER HOME DEBUG] ⭐ Rating Count: ${ratingCount.value}");
          print(
            "[PROVIDER HOME DEBUG] ⭐ Average Rating: ${averageRating.value}",
          );
          print("[PROVIDER HOME DEBUG] 💬 Reviews: ${ratings.length}");
        } else {
          final message = responseBody['message'] ?? 'Failed to fetch data';
          CustomToast.error(message);
          print("[PROVIDER HOME DEBUG] ❌ API Error: $message");
        }
      } else {
        CustomToast.error("No data received from server");
        print("[PROVIDER HOME DEBUG] ❌ Empty response received");
      }
    } catch (e) {
      CustomToast.error("Failed to load home screen data");
      print("[PROVIDER HOME DEBUG] ❌ Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchProviderHomeScreenData();
  }

  // Get formatted average rating
  String get formattedAverageRating {
    try {
      final rating = double.parse(averageRating.value);
      return rating.toStringAsFixed(1);
    } catch (e) {
      return '0.0';
    }
  }

  // Check if there are any ratings
  bool get hasRatings => ratingCount.value > 0;

  // Check if there are any booking requests
  bool get hasBookingRequests => bookingRequests.value > 0;
}
