import 'package:ustahub/app/export/exports.dart';

class CustomToast {
  static void show(
    String message, {
    Color bgColor = Colors.black,
    Color textColor = Colors.white,
  }) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: bgColor,
      textColor: textColor,
      fontSize: 14,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  static void success(String message) {
    show(message, bgColor: Colors.green, textColor: Colors.white);
  }

  static void error(String message) {
    show(message, bgColor: Colors.red, textColor: Colors.white);
  }

  static void info(String message) {
    show(message, bgColor: Colors.blueGrey, textColor: Colors.white);
  }
}
