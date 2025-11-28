// time_slot_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ustahub/app/modules/checkout/modelclass/timeslot_model_class.dart';
import 'package:ustahub/app/modules/checkout/respository/checkout_repository.dart';
import 'package:ustahub/utils/contstants/constants.dart';

class CheckoutController extends GetxController {
  // for Date Selection

  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxString selectedYmdDate = "".obs;
  DateTime today = DateTime.now();

  DateTime get firstDay => today;
  DateTime get lastDay => DateTime(today.year, today.month + 3, today.day);

  void selectDate(DateTime day, String providerId) {
    selectedYmdDate.value = formatToYMD(day);

    getTimeSlots(providerId: providerId, date: formatToYMD(day));

    selectedDate.value = day;
    print(day);
  }

  // for Tab selection

  // var selectedTabIndex = 0.obs;

  // void changeTab(int index) {
  //   selectedTabIndex.value = index;
  // }

  // for Time selection
  RxString selectedTime = "00:00".obs;

  void selectTimeSlot(String time) {
    selectedTime.value = time;
  }

  final noteController = TextEditingController().obs;

  // Visiting Charge

  RxBool includeCharge = true.obs;

  void toggleCharge(bool? value) {
    includeCharge.value = value ?? false;
  }

  var timeSlotsLists = <TimeSlotModel>[].obs;

  final _api = CheckoutRepository();

  RxBool isLoading = false.obs;

  Future<void> getTimeSlots({
    required String providerId,
    required String date,
  }) async {
    print("Get time slots called");
    isLoading.value = true;
    timeSlotsLists.clear(); // Clear previous slots

    try {
      final value = await _api.getTimeSlots(providerId: providerId, date: date);
      print(value);
      if (value['statusCode'] == 200) {
        final slotsData = value['body']['slots'];
        if (slotsData != null && slotsData is List) {
          timeSlotsLists.value =
              slotsData.map((e) => TimeSlotModel.fromJson(e)).toList();
        } else {
          timeSlotsLists.value = [];
        }
      } else {
        print(value);
        timeSlotsLists.value = [];
      }
    } catch (e) {
      print("Error getting time slots: $e");
      timeSlotsLists.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // Track selected service name
  RxString selectedServiceName = ''.obs;

  void setSelectedServiceName(String name) {
    selectedServiceName.value = name;
  }
}
