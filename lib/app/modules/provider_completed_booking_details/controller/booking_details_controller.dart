import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ustahub/app/modules/favourite_providers/controller/favourite_provider_controller.dart';
import 'package:ustahub/app/modules/provider_completed_booking_details/controller/start_work_controller.dart';
import 'package:ustahub/app/modules/provider_completed_booking_details/model_class/Booking_details_model_class.dart';
import 'package:ustahub/app/modules/provider_completed_booking_details/repository/provider_completed_booking_repository.dart';
import 'package:ustahub/components/custom_toast.dart';

class BookingDetailsController extends GetxController {
  RxBool isStarted = false.obs;
  RxBool isComplete = false.obs;
  RxString currentStatus = ''.obs;

  void toggleIsStarted() {
    isStarted.toggle();
  }

  void toggleComplete() {
    isComplete.toggle();
  }

  final StartWorkController startWorkController =
      Get.find<StartWorkController>();
  final FavouriteProviderController favouriteProvider = Get.put(
    FavouriteProviderController(),
  );

  final isLoading = false.obs;

  final _api = ProviderCompletedBookingRepository();
  Rxn<BookingDetailsModelClass> bookingDetails =
      Rxn<BookingDetailsModelClass>();

  Future<void> getBookingDetails({required String bookingId}) async {
    isLoading.value = true;

    try {
      final value = await _api.bookingDetails(bookingId);
      if (value['statusCode'] == 200) {
        final data = value['body']['data'];
        if (data != null) {
          debugPrint('[BOOKING_DETAILS] Raw booking payload: $data');
          bookingDetails.value = BookingDetailsModelClass.fromJson(data);

          // Update state based on booking status from database
          final normalizedStatus = _normalizeStatus(
            bookingDetails.value?.status,
          );
          currentStatus.value = normalizedStatus;
          debugPrint(
            '[BOOKING_DETAILS] Current booking status: ${bookingDetails.value?.status} -> $normalizedStatus',
          );

          if (normalizedStatus == 'in_progress') {
            isStarted.value = true;
            isComplete.value = false;
          } else if (normalizedStatus == 'completed') {
            isStarted.value = true;
            isComplete.value = true;
          } else if (normalizedStatus == 'accepted') {
            isStarted.value = false;
            isComplete.value = false;
          } else if (normalizedStatus == 'pending') {
            isStarted.value = false;
            isComplete.value = false;
          }

          debugPrint(
            '[BOOKING_DETAILS] Updated state - isStarted: ${isStarted.value}, isComplete: ${isComplete.value}',
          );
          debugPrint(
            '[BOOKING_DETAILS] Booking details: ${bookingDetails.value?.id}',
          );
          debugPrint(
            '[BOOKING_DETAILS] Address: ${bookingDetails.value?.address?.address}',
          );
        } else {
          debugPrint("[BOOKING_DETAILS] Data is null for booking details.");
          CustomToast.error('Booking details are unavailable.');
        }
      } else {
        final message = value['body']?['message']?.toString() ?? 'Failed to load booking details';
        debugPrint("[BOOKING_DETAILS] Error response: $value");
        CustomToast.error(message);
        bookingDetails.value = null;
        currentStatus.value = '';
      }
    } catch (e) {
      debugPrint("[BOOKING_DETAILS] Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Start work on the current booking
  Future<bool> startWork(String bookingId) async {
    try {
      final response = await _api.startWork({'booking_id': bookingId});
      final body = response['body'] as Map<String, dynamic>? ?? {};

      if (response['statusCode'] == 200 && (body['success'] == true || body['status'] == true)) {
        currentStatus.value = 'in_progress';
        isStarted.value = true;
        isComplete.value = false;
        CustomToast.success(body['message']?.toString() ?? 'Work started successfully!');
        await getBookingDetails(bookingId: bookingId);
        return true;
      }

      CustomToast.error(body['message']?.toString() ?? 'Failed to start work');
      return false;
    } catch (e) {
      debugPrint('[BOOKING_CTRL] Error starting work: $e');
      CustomToast.error('Error: $e');
      return false;
    }
  }

  /// Complete the current booking
  Future<bool> completeWork(String bookingId, {String? remark}) async {
    try {
      final response = await _api.completeBooings({
        'booking_id': bookingId,
        if (remark != null) 'remark': remark,
      });
      final body = response['body'] as Map<String, dynamic>? ?? {};

      if (response['statusCode'] == 200 && (body['success'] == true || body['status'] == true)) {
        currentStatus.value = 'completed';
        isStarted.value = true;
        isComplete.value = true;
        CustomToast.success(body['message']?.toString() ?? 'Work completed successfully!');
        await getBookingDetails(bookingId: bookingId);
        return true;
      }

      CustomToast.error(body['message']?.toString() ?? 'Failed to complete work');
      return false;
    } catch (e) {
      debugPrint('[BOOKING_CTRL] Error completing work: $e');
      CustomToast.error('Error: $e');
      return false;
    }
  }

  String _normalizeStatus(String? status) {
    if (status == null) return '';
    return status.toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_').trim();
  }
  
  /// Get display-friendly status
  String get displayStatus {
    switch (currentStatus.value) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      default:
        return currentStatus.value.isNotEmpty 
            ? currentStatus.value.replaceAll('_', ' ').capitalizeFirst ?? currentStatus.value
            : 'Unknown';
    }
  }
  
  /// Check if booking can have work started
  bool get canStartWork => currentStatus.value == 'accepted';
  
  /// Check if booking can be marked complete
  bool get canMarkComplete => currentStatus.value == 'in_progress';
  
  /// Check if address has valid data for directions
  bool get hasValidAddress {
    final address = bookingDetails.value?.address;
    if (address == null) return false;
    
    // Check if we have coordinates
    final hasCoordinates =
        (address.latitude != null && address.latitude!.isNotEmpty && address.latitude != 'null') &&
        (address.longitude != null && address.longitude!.isNotEmpty && address.longitude != 'null');
    
    if (hasCoordinates) return true;
    
    // Check if we have address text
    final hasAddressText =
        (address.address != null && address.address!.isNotEmpty && address.address != 'null') ||
        (address.city != null && address.city!.isNotEmpty && address.city != 'null');
    
    return hasAddressText;
  }
  
  /// Get formatted address string for display
  String getFormattedAddress() {
    final address = bookingDetails.value?.address;
    if (address == null) return '';
    
    final parts = <String>[];
    
    if (address.address != null && address.address!.isNotEmpty && address.address != 'null') {
      parts.add(address.address!);
    }
    if (address.city != null && address.city!.isNotEmpty && address.city != 'null') {
      parts.add(address.city!);
    }
    if (address.country != null && address.country!.isNotEmpty && address.country != 'null') {
      parts.add(address.country!);
    }
    if (address.postalCode != null && address.postalCode!.isNotEmpty && address.postalCode != 'null') {
      parts.add(address.postalCode!);
    }
    
    return parts.join(', ');
  }
}
