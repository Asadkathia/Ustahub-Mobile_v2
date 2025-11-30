import 'dart:async';
import 'package:get/get.dart';

/// Controller for countdown timer using GetX observables
/// Replaces setState() with reactive variables for better performance
class CountdownController extends GetxController {
  final days = 7.obs;
  final hours = 12.obs;
  final minutes = 30.obs;
  final seconds = 20.obs;

  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    startCountdown();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  void startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value > 0) {
        seconds.value--;
      } else if (minutes.value > 0) {
        minutes.value--;
        seconds.value = 59;
      } else if (hours.value > 0) {
        hours.value--;
        minutes.value = 59;
        seconds.value = 59;
      } else if (days.value > 0) {
        days.value--;
        hours.value = 23;
        minutes.value = 59;
        seconds.value = 59;
      } else {
        timer.cancel();
      }
    });
  }

  void reset() {
    days.value = 7;
    hours.value = 12;
    minutes.value = 30;
    seconds.value = 20;
  }

  void stop() {
    _countdownTimer?.cancel();
  }
}

