import 'package:ustahub/app/export/exports.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController().obs;
  final phoneController = TextEditingController().obs;

  var isEmailSelected = true.obs;

  void toggle(bool value) {
    isEmailSelected.value = value;
  }

  final _api = LoginRepository();

  final RxBool isLoading = false.obs;
  final RxBool isOtpSending = false.obs;

  // Use lazy initialization to avoid dependency issues
  ProviderController? _providerController;
  ProviderController get providerController {
    _providerController ??= Get.put(ProviderController());
    return _providerController!;
  }

  final providerProfileController = Get.put(ProviderProfileController());
  final consumerProfileController = Get.put(ConsumerProfileController());

  // Send OTP to email
  Future<void> sendOtpToEmail(String role) async {
    try {
      // Validate email
      final email = emailController.value.text.trim();
      if (email.isEmpty) {
        CustomToast.error("Please enter your email address");
        return;
      }

      // Validate email format
      if (!GetUtils.isEmail(email)) {
        CustomToast.error("Please enter a valid email address");
        return;
      }

      isOtpSending.value = true;

      print("[OTP DEBUG] 📧 Sending OTP to: $email for role: $role");

      final response = await _api.sendOtpToEmail(email, role);

      print("[OTP DEBUG] 📨 Response: $response");

      // Use enhanced error handling
      if (ApiErrorHandler.isSuccess(response)) {
        // Handle success response
        CustomToast.success(
          response['body']['message'] ?? "OTP sent successfully!",
        );

        // Prefer email from response if available, else fallback to the entered email
        final dynamic responseEmail =
            response['body']?['email'] ?? response['body']?['user']?['email'];
        final String safeEmail = (responseEmail is String && responseEmail.trim().isNotEmpty)
            ? responseEmail
            : email; // fallback to the email entered by user

        print("[OTP DEBUG] ✅ OTP sent successfully to: $safeEmail");
        print("[OTP DEBUG] 📝 IsRegister: ${response["body"]?['isRegister']}");

        // Navigate to OTP verification screen using direct navigation
        final otpController = Get.put(OtpController());
        otpController.setCredentials(safeEmail, role);

        Get.to(() => OtpView(email: safeEmail, role: role));
      } else {
        // Handle different types of errors appropriately
        if (ApiErrorHandler.isServerError(response)) {
          print("[OTP DEBUG] 🚨 Server Error Detected");
        }

        if (ApiErrorHandler.isAuthError(response)) {
          print("[OTP DEBUG] 🚪 Authentication Error");
          ApiErrorHandler.handleAuthError();
        }

        // Show user-friendly error message
        ApiErrorHandler.showError(response);

        print(
          "[OTP DEBUG] ❌ API Error: ${ApiErrorHandler.parseError(response)}",
        );
      }
    } catch (e) {
      CustomToast.error("An error occurred. Please try again.");
      print("[OTP DEBUG] ❌ Exception: $e");
    } finally {
      isOtpSending.value = false;
    }
  }
}
