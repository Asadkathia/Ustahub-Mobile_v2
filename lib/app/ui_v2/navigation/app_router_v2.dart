import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/nav_bar/view/custom_bottom_bar.dart';
import '../config/ui_config.dart';
import '../screens/splash/splash_screen_v2.dart';
import '../screens/onboarding/onboarding_screen_v2.dart';
import '../screens/auth/login/login_screen_v2.dart';
import '../screens/auth/signup/signup_screen_v2.dart';
import '../screens/auth/otp/otp_screen_v2.dart';
import '../screens/navigation/nav_bar_v2.dart';
import '../screens/provider/provider_details_screen_v2.dart';
import '../screens/booking/booking_summary_screen_v2.dart';

class AppRouterV2 {
  static Widget _navBarWidget({
    required String role,
    int initialIndex = 0,
  }) {
    // Always use v2 NavBar
    return NavBarV2(role: role, initialIndex: initialIndex);
  }

  // Route to new UI screens
  static void toSplashV2() {
    Get.offAll(() => const SplashScreenV2());
  }

  static void toOnboardingV2() {
    Get.offAll(() => OnboardingScreenV2());
  }

  static void toLoginV2({required String role}) {
    Get.to(() => LoginScreenV2(role: role));
  }

  static void toSignUpV2({required String role}) {
    Get.to(() => SignUpScreenV2(initialRole: role));
  }

  static void toOtpV2({required String role, required String email}) {
    Get.to(() => OtpScreenV2(role: role, email: email));
  }

  static void toNavBarV2({required String role, int? initialIndex}) {
    Get.offAll(
      () => NavBarV2(role: role, initialIndex: initialIndex ?? 0),
    );
  }

  static void goToNavBar({required String role, int initialIndex = 0}) {
    Get.offAll(() => _navBarWidget(role: role, initialIndex: initialIndex));
  }

  static void offNavBar({required String role, int initialIndex = 0}) {
    Get.off(() => _navBarWidget(role: role, initialIndex: initialIndex));
  }

  // Helper method to decide which UI to use (for gradual migration)
  static Widget getSplashScreen() {
    return const SplashScreenV2();
  }

  static Widget getOnboardingScreen() {
    return OnboardingScreenV2();
  }

  static Widget getLoginScreen({required String role}) {
    return LoginScreenV2(role: role);
  }

  static Widget getOtpScreen({required String role, required String email}) {
    return OtpScreenV2(role: role, email: email);
  }

  static Widget getNavBar({required String role, int? initialIndex}) {
    return _navBarWidget(role: role, initialIndex: initialIndex ?? 0);
  }

  // Provider Details Navigation
  static void toProviderDetailsV2({required String providerId}) {
    Get.to(() => ProviderDetailsScreenV2(id: providerId));
  }

  // Booking Summary Navigation
  static void toBookingSummaryV2({
    required String providerId,
    required String serviceId,
    required String serviceName,
    required String addressId,
    required String bookingDate,
    required String bookingTime,
    required String fullAddress,
    required String note,
  }) {
    Get.to(
      () => BookingSummaryScreenV2(
        providerId: providerId,
        serviceId: serviceId,
        serviceName: serviceName,
        addressId: addressId,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        fullAddress: fullAddress,
        note: note,
      ),
    );
  }
}

