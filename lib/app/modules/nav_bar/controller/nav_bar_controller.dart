import 'package:get/get.dart';

class NavBarController extends GetxController {
  RxInt selectedIndex = 0.obs;

  // Method to reset to homepage
  void goToHomepage() {
    selectedIndex.value = 0;
  }

  // Method to go to specific tab
  void goToTab(int index) {
    selectedIndex.value = index;
  }
}
