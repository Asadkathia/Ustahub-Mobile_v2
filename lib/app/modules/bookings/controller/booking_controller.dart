import 'package:get/get.dart';
import '../model_class/booking_model_class.dart';
import '../repository/booking_repository.dart';
import 'consumer_booking_history_controller.dart';

class BookingController extends GetxController {
  var selectedTab = 0.obs;
  var upcomingBookings = <BookingModel>[].obs;
  var ongoingBookings = <BookingModel>[].obs;
  var completedBookings = <BookingModel>[].obs;
  var isLoading = false.obs;

  final BookingRepository _repository = BookingRepository();

  // Consumer booking history controller
  final ConsumerBookingHistoryController _historyController = Get.put(
    ConsumerBookingHistoryController(),
  );

  void selectTab(int index) {
    selectedTab.value = index;
    if (index == 0) {
      fetchUpcomingBookings();
    } else if (index == 1) {
      fetchOngoingBookings();
    } else if (index == 2) {
      fetchCompletedBookings();
    } else if (index == 3) {
      // Fetch consumer booking history when History tab is selected
      _historyController.fetchConsumerBookingHistory();
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchUpcomingBookings();
  }

  Future<void> fetchUpcomingBookings() async {
    isLoading.value = true;
    try {
      final bookings = await _repository.getUpcomingBookings();
      upcomingBookings.assignAll(bookings);
    } catch (e) {
      upcomingBookings.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOngoingBookings() async {
    isLoading.value = true;
    try {
      final bookings = await _repository.getOngoingBookings();
      ongoingBookings.assignAll(bookings);
    } catch (e) {
      ongoingBookings.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCompletedBookings() async {
    isLoading.value = true;
    try {
      final bookings = await _repository.getCompletedBookings();
      completedBookings.assignAll(bookings);
    } catch (e) {
      completedBookings.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
