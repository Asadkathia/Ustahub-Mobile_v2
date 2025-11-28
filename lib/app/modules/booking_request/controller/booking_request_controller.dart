import 'package:get/get.dart';
import 'package:ustahub/app/modules/provider_bookings/controller/provider_bookings_controller.dart';
import 'package:ustahub/app/modules/booking_request/model_class/BookingRequestModel.dart';
import 'package:ustahub/components/custom_toast.dart';
import 'package:ustahub/network/booking_api_service.dart';
import 'package:ustahub/utils/booking_card_mapper.dart';

class BookingRequestController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<BookingRequestModel> bookingRequests = <BookingRequestModel>[].obs;
  final BookingApiService _bookingApi = BookingApiService();

  @override
  void onInit() {
    super.onInit();
    fetchBookingRequests();
  }

  Future<void> fetchBookingRequests() async {
    print('[BOOKING_REQUEST] Fetching booking requests...');
    isLoading.value = true;
    try {
      final response = await _bookingApi.listBookings(
        role: 'provider',
        status: 'pending',
        pageSize: 50,
      );
      
      final body = response['body'] as Map<String, dynamic>? ?? {};
      
      if (body['success'] == true && body['data'] != null) {
        final List data = body['data'] as List? ?? [];
        print('[BOOKING_REQUEST] Raw data count: ${data.length}');
        print(
          '[BOOKING_REQUEST] First booking: ${data.isNotEmpty ? data[0] : 'empty'}',
        );
        
        bookingRequests.value =
            data.map((e) {
          try {
                final mapped = BookingCardMapper.toLegacyForProvider(
                  e as Map<String, dynamic>,
                );
                return BookingRequestModel.fromJson(mapped);
          } catch (parseError) {
                print(
                  '[BOOKING_REQUEST] ❌ Parse error for booking: $parseError',
                );
            print('[BOOKING_REQUEST] Booking data: $e');
            rethrow;
          }
        }).toList();
        print('[BOOKING_REQUEST] ✅ Loaded ${bookingRequests.length} requests');
      } else {
        print('[BOOKING_REQUEST] ⚠️ No data in response');
        bookingRequests.clear();
      }
    } catch (e, stackTrace) {
      print('[BOOKING_REQUEST] ❌ Error: $e');
      print('[BOOKING_REQUEST] Stack trace: $stackTrace');
      bookingRequests.clear();
    }
    isLoading.value = false;
  }

  Future<void> acceptOrRejectBooking({
    required String bookingId,
    required String status,
  }) async {
    isLoading.value = true;
    try {
      // Use Edge Function for booking workflow
      final action = status == 'accepted' ? 'accept' : 'reject';
      final response = await _bookingApi.performAction(
        action: action,
        bookingId: bookingId,
        remark: status == 'rejected' ? 'Booking rejected by provider' : null,
      );
      final body = response['body'] as Map<String, dynamic>? ?? {};
      
      if (body['success'] == true) {
        CustomToast.success("Request ${status}ed successfully");
        fetchBookingRequests();
        _refreshProviderBookings();
      } else {
        CustomToast.error(
          body['message'] ?? "Failed to update request",
        );
      }
    } catch (e) {
      print('[BOOKING_REQUEST] ❌ Error: $e');
      CustomToast.error("Failed to update request");
    }
    isLoading.value = false;
  }

  void _refreshProviderBookings() {
    if (Get.isRegistered<ProviderBookingController>()) {
      final providerBookingController = Get.find<ProviderBookingController>();
      providerBookingController.providerBookingApi("not_started");
      providerBookingController.providerBookingApi("ongoing");
    }
  }
}
