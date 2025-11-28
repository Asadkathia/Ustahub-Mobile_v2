import 'dart:async';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/ui_v2/navigation/app_router_v2.dart';
import 'package:ustahub/main.dart';

class OtpController extends GetxController {
  final otpController = TextEditingController().obs;
  final _api = LoginRepository();

  RxInt remainingSeconds = 0.obs;
  Timer? _timer;

  // For storing email and role for resend functionality
  RxString currentEmail = ''.obs;
  RxString currentRole = ''.obs;
  final RxBool isResending = false.obs;

  @override
  void onInit() {
    startResendTimer();
    super.onInit();
  }

  // Set email and role when OTP screen is opened
  void setCredentials(String email, String role) {
    currentEmail.value = email;
    currentRole.value = role;
  }

  void startResendTimer() {
    if (_timer != null) _timer!.cancel();
    remainingSeconds.value = 30;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds.value == 0) {
        timer.cancel();
      } else {
        remainingSeconds.value--;
      }
    });
  }

  bool get isTimerActive => remainingSeconds.value > 0;

  // Resend OTP functionality
  Future<void> resendOtp() async {
    if (isTimerActive || currentEmail.isEmpty || currentRole.isEmpty) {
      return;
    }

    try {
      isResending.value = true;

      print(
        "[RESEND OTP DEBUG] 🔄 Resending OTP to: ${currentEmail.value} for role: ${currentRole.value}",
      );

      final response = await _api.sendOtpToEmail(
        currentEmail.value,
        currentRole.value,
      );

      if (response["statusCode"] == 200 || response["statusCode"] == 201) {
        CustomToast.success(
          response['body']['message'] ?? "OTP resent successfully!",
        );

        print("[RESEND OTP DEBUG] ✅ OTP resent successfully");

        // Restart the timer
        startResendTimer();
      } else {
        CustomToast.error(
          response['body']['message'] ?? "Failed to resend OTP",
        );
        print(
          "[RESEND OTP DEBUG] ❌ Failed to resend OTP: ${response['body']['message']}",
        );
      }
    } catch (e) {
      CustomToast.error("Failed to resend OTP. Please try again.");
      print("[RESEND OTP DEBUG] ❌ Exception: $e");
    } finally {
      isResending.value = false;
    }
  }

  // Use lazy initialization to avoid dependency issues
  ProviderController? _providerController;
  ProviderController get providerController {
    _providerController ??= Get.put(ProviderController());
    return _providerController!;
  }

  final providerProfileController = Get.put(ProviderProfileController());
  final consumerProfileController = Get.put(ConsumerProfileController());

  final isLoading = false.obs;

  Future<void> verifyOTP({required String role, required String email}) async {
    if (isLoading.value) return; // Prevent multiple submissions
    isLoading.value = true;

    final data = {'email': email, 'otp': otpController.value.text};
    try {
      final response = await _api.emailLogin(data, role);
      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final body = response['body'];
        
        // Create Supabase session after OTP verification using temporary password
        final supabase = SupabaseClientService.instance;
        bool sessionCreated = false;
        
        try {
          // Get temporary password from Edge Function response
          final tempPassword = body['temp_password'] as String?;
          
          if (tempPassword != null && tempPassword.isNotEmpty) {
            // Sign in with email and temporary password to create session
            final sessionResponse = await supabase.auth.signInWithPassword(
              email: email,
              password: tempPassword,
            );
            
            if (sessionResponse.session != null) {
              print('[OTP] ✅ Supabase session created successfully with temporary password');
              // Save session to shared preferences
              await Sharedprefhelper.saveSupabaseSession();
              sessionCreated = true;
            } else {
              print('[OTP] ⚠️ Session is null after sign-in');
            }
          } else {
            print('[OTP] ⚠️ No temporary password received');
          }
          
          // Store role in shared preferences
          await Sharedprefhelper.setSharedPrefHelper('userRole', role);
          
          // Store user ID for reference
          if (body['user_id'] != null) {
            await Sharedprefhelper.setSharedPrefHelper('user_id', body['user_id'].toString());
          }
        } catch (sessionError) {
          print('[OTP] ⚠️ Session creation error: $sessionError');
          // Fallback: Try passwordless sign-in
          try {
            await supabase.auth.signInWithOtp(
              email: email,
              shouldCreateUser: false,
            );
            print('[OTP] ✅ Passwordless sign-in initiated as fallback');
          } catch (fallbackError) {
            print('[OTP] ❌ Fallback also failed: $fallbackError');
          }
        }
        
        // Ensure user data is stored even if session creation failed
        if (!sessionCreated) {
          await Sharedprefhelper.setSharedPrefHelper('userRole', role);
          if (body['user_id'] != null) {
            await Sharedprefhelper.setSharedPrefHelper('user_id', body['user_id'].toString());
          }
        }
        
        // Store FCM token
        final String fcmToken = await Sharedprefhelper.getSharedPrefHelper("FcmToken") ?? "";
        if (fcmToken.isNotEmpty && SupabaseClientService.isAuthenticated) {
        await FcmService.storeFcmToken(fcmToken);
        }

        if (body['isRegister'] == true) {
          // Existing user - login
          if (role == "consumer") {
            consumerProfileController.fetchProfile();
          } else {
            providerProfileController.fetchProfile();
          }
          CustomToast.success("Login successful!");
          await Sharedprefhelper.setSharedPrefHelper('userRole', role);
          AppRouterV2.goToNavBar(role: role, initialIndex: 0);
          providerController.getProvider();
          initializeDependencyInjection('supabase_session');
        } else {
          // New user - signup
          providerController.getProvider();
          CustomToast.success("Signup successful! Please complete your profile.");
          await Sharedprefhelper.setSharedPrefHelper('userRole', role);
          if (role == "consumer") {
            Get.offAll(() => ConsumerProfileSetupView());
          } else {
            Get.offAll(() => ProviderServiceSelectionView(isManageService: false,));
          }
        }
      } else {
        CustomToast.error(response['body']['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      CustomToast.error('Failed to verify OTP: $e');
      print('[OTP] ❌ Error: $e');
    } finally {
      isLoading.value = false; // Reset loading state
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.value.dispose();
    super.onClose();
  }
}
