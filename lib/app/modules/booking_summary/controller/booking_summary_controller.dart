import 'package:ustahub/app/modules/booking_summary/repository/booking_summary_repository.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/service_success/view/service_success_view.dart';

class BookingSummaryController extends GetxController {
  final BookingSummaryRepository _repository = BookingSummaryRepository();
  RxBool isLoading = false.obs;

  Future<void> bookService({required Map<String, dynamic> bookingData}) async {
    print(bookingData);
    isLoading.value = true;
    try {
      final response = await _repository.bookService(bookingData);
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        CustomToast.success("Booking successful");
        int itemTotalInt = 0;
        final itemTotalRaw = bookingData['item_total'];
        if (itemTotalRaw is int) {
          itemTotalInt = itemTotalRaw;
        } else if (itemTotalRaw is double) {
          itemTotalInt = itemTotalRaw.toInt();
        } else if (itemTotalRaw is String) {
          itemTotalInt =
              int.tryParse(itemTotalRaw) ??
              double.tryParse(itemTotalRaw)?.toInt() ??
              0;
        }
        Get.to(
          () => ServiceSuccessView(
            bottomTitle: "Paid Amount",
            title: "Payment Success!!!",
            totalAmount: visitingCharge.toString(),
            bookingDate: bookingData['booking_date'],
            bookingTime: bookingData['booking_time'],
          ),
        );
        // You can add navigation or state update here
      } else {
        CustomToast.error(
          response['body']['message'] ?? 'Failed to book service',
        );
      }
    } catch (e) {
      CustomToast.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
