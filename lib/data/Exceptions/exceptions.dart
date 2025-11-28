import 'package:get/get.dart';
import 'package:ustahub/components/internetexception.dart';


//About this class

/* Exception can be handled by the getx,here i've created a class Named appexception which is implementing the exception.
and when there is any internet exception then we are displaying the screen where there is a button comming from appsetting package
to open the setting of wifi,same as request timeout and other exception which will return the exception mesaage in the snackbar.
there are more such type of exception which can be handle by the exception,you can google it.
 */

class AppExceptions implements Exception {
  final _message; //error message
  final _prefix; //to display the type of error

  AppExceptions([this._prefix, this._message]);

  @override
  String toString() {
    return '$_prefix: $_message'; //displaying the message
  }
}

class InternetException extends AppExceptions {
  InternetException([String? message])
      : super(
          message,
          'No internet',
        ) {
    Get.to(NoInternet());
  }
}

class RequestTimeOut extends AppExceptions {
  RequestTimeOut([String? message]) : super(message, 'Request TimeOut');
}

class ServerException extends AppExceptions {
  ServerException([String? message]) : super(message, 'Internal server error');
}

class InvalidUrlException extends AppExceptions {
  InvalidUrlException([String? message]) : super(message, 'Invalid Url');
}

class FetchDataException extends AppExceptions {
  FetchDataException([String? message]) : super(message, '');
}
