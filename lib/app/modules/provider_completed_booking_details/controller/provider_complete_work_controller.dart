import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_bookings/controller/provider_bookings_controller.dart';
import 'package:ustahub/app/modules/provider_calendar/controller/provider_calendar_controller.dart';
import 'package:ustahub/app/modules/provider_completed_booking_details/repository/provider_completed_booking_repository.dart';

class ProviderCompleteWorkController extends GetxController {
  final _repository = ProviderCompletedBookingRepository();
  final isLoading = false.obs;

  Future<void> completeWork({required String bookingId, String? remark}) async {
    if (isLoading.value) return; // Prevent multiple submissions
    isLoading.value = true;

    try {
      // Always fetch latest booking status first
      try {
        final bookingController = Get.find<BookingDetailsController>();
        await bookingController.getBookingDetails(bookingId: bookingId);
        var bookingStatus = _normalizeStatus(
          bookingController.bookingDetails.value?.status,
        );
        
        print(
          '[COMPLETE_WORK] Current booking status: ${bookingController.bookingDetails.value?.status} -> $bookingStatus',
        );
        
        // If status is 'accepted', start work first
        if (bookingStatus == 'accepted') {
          print(
            '[COMPLETE_WORK] Booking status is $bookingStatus, starting work first...',
          );
          
          try {
            final startResponse = await _repository.startWork({
              'booking_id': bookingId,
            });
            
            if (startResponse['statusCode'] == 200 || 
                (startResponse['body'] != null &&
                    startResponse['body']['success'] == true)) {
              print('[COMPLETE_WORK] Work started successfully');
              // Update booking controller state
              bookingController.isStarted.value = true;
              // Refresh booking details to get updated status
              await bookingController.getBookingDetails(bookingId: bookingId);
              // Wait a bit for status to update in database
              await Future.delayed(const Duration(milliseconds: 500));
              bookingStatus = _normalizeStatus(
                bookingController.bookingDetails.value?.status,
              );
            } else {
              final errorMsg =
                  startResponse['body']?['error'] ??
                              startResponse['body']?['message'] ?? 
                              "Failed to start work";
              CustomToast.error(errorMsg);
              isLoading.value = false;
              return;
            }
          } catch (startError) {
            print('[COMPLETE_WORK] Error starting work: $startError');
            CustomToast.error("Failed to start work: ${startError.toString()}");
            isLoading.value = false;
            return;
          }
        }

        if (bookingStatus != 'in_progress') {
          // If status is not 'in_progress', show error
          CustomToast.error(
            "Booking must be in progress to complete. Current status: ${bookingController.bookingDetails.value?.status ?? bookingStatus}",
          );
          isLoading.value = false;
          return;
        }
      } catch (e) {
        print('[COMPLETE_WORK] Error checking booking status: $e');
        // Continue with completion attempt - let backend validate
      }

      final response = await _repository.completeBooings({
        'booking_id': bookingId,
        if (remark != null) 'remark': remark,
      });

      if (response != null && 
          (response['statusCode'] == 200 || 
              (response['body'] != null &&
                  response['body']['success'] == true))) {
        CustomToast.success(
          response['body']?['message'] ??
              response['message'] ??
              "Work completed successfully!",
        );
        
        // Update booking details controller state
        try {
          final bookingController = Get.find<BookingDetailsController>();
          bookingController.isComplete.value = true;
          bookingController.isStarted.value = true;
          bookingController.currentStatus.value = 'completed';
          // Refresh booking details to get updated status
          await bookingController.getBookingDetails(bookingId: bookingId);
        } catch (e) {
          print("Error updating booking controller: $e");
        }
        
        // Refresh provider bookings if available (only if controller is registered)
        try {
          if (Get.isRegistered<ProviderBookingController>()) {
            final providerBookingsController =
                Get.find<ProviderBookingController>();
            if (providerBookingsController.hasListeners) {
              // Refresh current tab's bookings
              final currentTab = providerBookingsController.selectedTab.value;
              if (currentTab <
                  providerBookingsController.bookingStatus.length) {
                providerBookingsController.providerBookingApi(
                  providerBookingsController.bookingStatus[currentTab],
                );
              }
            }
          }
        } catch (e) {
          // Controller might not be initialized, ignore
          print("ProviderBookingController not found, skipping refresh: $e");
        }
        
        // Refresh calendar if available
        try {
          if (Get.isRegistered<ProviderCalendarController>()) {
            final calendarController = Get.find<ProviderCalendarController>();
            await calendarController.fetchBookingsForDate(
              calendarController.selectedDate.value,
            );
          }
        } catch (e) {
          print("ProviderCalendarController not found, skipping refresh: $e");
        }
      } else {
        // Handle error response
        String errorMessage =
            response['body']?['message'] ?? 
            response['body']?['error'] ??
            response['message'] ??
            "Failed to complete work. Please try again.";
        CustomToast.error(errorMessage);
      }
    } catch (e) {
      // Handle exceptions during API call
      CustomToast.error("An error occurred: ${e.toString()}");
      print("Error completing work: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String _normalizeStatus(String? status) {
    if (status == null) return '';
    return status.toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_').trim();
  }
}
