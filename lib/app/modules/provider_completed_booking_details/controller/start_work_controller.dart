import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ustahub/app/modules/provider_completed_booking_details/controller/booking_details_controller.dart';
import 'package:ustahub/app/modules/provider_completed_booking_details/repository/provider_completed_booking_repository.dart';
import 'package:ustahub/components/custom_toast.dart';

class StartWorkController extends GetxController {
  // Removed the direct dependency on BookingDetailsController

  final isLoading = false.obs;

  final _api = ProviderCompletedBookingRepository();

  Future<void> startWork({required String? bookingId}) async {
    if (isLoading.value) return; // Prevent multiple submissions
    isLoading.value = true;

    if (bookingId == null) {
      CustomToast.error("Booking ID is missing. Cannot start work.");
      isLoading.value = false;
      return;
    }

    final data = {'booking_id': bookingId};

    try {
      final value = await _api.startWork(data);
      if (value['statusCode'] == 200 ||
          (value['body'] != null && value['body']['success'] == true)) {
          CustomToast.success("Work Started");
        final bookingController = Get.find<BookingDetailsController>();
        bookingController.isStarted.value = true;
        bookingController.isComplete.value = false;
        bookingController.currentStatus.value = 'in_progress';
        await bookingController.getBookingDetails(bookingId: bookingId);
        } else {
          String errorMessage = "An unknown error occurred";
        final body = value['body'];
        if (body != null) {
          if (body is Map) {
            errorMessage = body['message'] ?? body['error'] ?? errorMessage;
          } else if (body is Set && body.isNotEmpty) {
            final firstBodyItem = body.first;
              if (firstBodyItem is Map) {
              errorMessage =
                  firstBodyItem['message'] ??
                  firstBodyItem['error'] ??
                  errorMessage;
              }
            }
          }
          CustomToast.error(errorMessage);
        debugPrint('[START_WORK] Error response: $value');
        }
    } catch (e) {
      CustomToast.error("Failed to start work: $e");
      debugPrint('[START_WORK] Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
