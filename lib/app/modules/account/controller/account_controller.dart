import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/logout/controller/logout_controller.dart';

class AccountController extends GetxController {

final logoutController = Get.put(LogoutController());

  void logout() {
    logoutController.logout();
  }


}