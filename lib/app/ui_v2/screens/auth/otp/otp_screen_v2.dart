import 'dart:async';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/Auth/OTP/controller/otp_controller.dart';
import 'package:ustahub/app/modules/Auth/login/controller/login_controller.dart';
import 'package:ustahub/app/modules/onboarding/view/onboarding_view.dart';
import 'package:ustahub/app/ui_v2/config/ui_config.dart';
import 'package:ustahub/app/ui_v2/screens/onboarding/onboarding_screen_v2.dart';
import 'package:ustahub/app/ui_v2/screens/splash/splash_screen_v2.dart';
import 'package:ustahub/app/ui_v2/navigation/app_router_v2.dart';
import 'package:ustahub/main.dart';
import 'package:pinput/pinput.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../design_system/colors/app_colors_v2.dart';
import '../../../design_system/typography/app_text_styles.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../components/buttons/primary_button.dart';

class OtpScreenV2 extends StatefulWidget {
  final String role;
  final String email;
  
  const OtpScreenV2({
    super.key,
    required this.role,
    required this.email,
  });

  @override
  State<OtpScreenV2> createState() => _OtpScreenV2State();
}

class _OtpScreenV2State extends State<OtpScreenV2> with WidgetsBindingObserver {
  StreamSubscription<AuthState>? _authStateSubscription;
  Timer? _sessionCheckTimer;
  bool _isHandlingCallback = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAuthListener();
    _checkForGoogleAuthSession();
    _startSessionPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authStateSubscription?.cancel();
    _sessionCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Check for session when app resumes (e.g., returning from OAuth browser)
    if (state == AppLifecycleState.resumed) {
      // Restart polling in case it stopped
      try {
        final loginController = Get.find<LoginController>();
        if (loginController.isGoogleSigningIn.value) {
          _restartSessionPolling();
        }
      } catch (e) {
        // Controller might not exist, that's okay
      }
      
      // Add a small delay to allow Supabase to process the deep link
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkForGoogleAuthSession();
      });
    }
  }

  void _startSessionPolling() {
    // Cancel any existing timer
    _sessionCheckTimer?.cancel();
    
    // Poll for session every 1 second if Google sign-in is in progress
    _sessionCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        if (!mounted) {
          timer.cancel();
          return;
        }

        final loginController = Get.find<LoginController>();
        if (loginController.isGoogleSigningIn.value && !_isHandlingCallback) {
          await _checkForGoogleAuthSession();
        } else if (!loginController.isGoogleSigningIn.value && !_isHandlingCallback) {
          // Stop polling if sign-in is no longer in progress and we're not handling callback
          timer.cancel();
        }
      } catch (e) {
        // LoginController might not exist yet, that's okay
        print("[OTP_SCREEN_V2] ⚠️ Error in polling: $e");
      }
    });
  }

  void _restartSessionPolling() {
    print("[OTP_SCREEN_V2] 🔄 Restarting session polling");
    _startSessionPolling();
  }

  void _setupAuthListener() {
    final supabase = SupabaseClientService.instance;
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      print("[OTP_SCREEN_V2] 🔔 Auth state changed: $event");

      if (event == AuthChangeEvent.signedIn && session != null) {
        print("[OTP_SCREEN_V2] ✅ User signed in via OAuth");
        _handleGoogleAuthCallback(session);
      }
    });
  }

  Future<void> _checkForGoogleAuthSession() async {
    if (_isHandlingCallback) {
      print("[OTP_SCREEN_V2] ⏸️ Already handling callback, skipping check");
      return;
    }

    try {
      final supabase = SupabaseClientService.instance;
      final session = supabase.auth.currentSession;
      final pendingRole = await Sharedprefhelper.getSharedPrefHelper('pendingGoogleAuthRole');

      print("[OTP_SCREEN_V2] 🔍 Checking session - Has session: ${session != null}, Has pending role: ${pendingRole != null}");

      if (session != null && pendingRole != null) {
        print("[OTP_SCREEN_V2] ✅ Session found, handling Google auth callback");
        _sessionCheckTimer?.cancel(); // Stop polling
        await _handleGoogleAuthCallback(session);
      } else if (session != null && pendingRole == null) {
        // Session exists but no pending role - might be from a previous login
        print("[OTP_SCREEN_V2] ℹ️ Session exists but no pending role");
      }
    } catch (e) {
      print("[OTP_SCREEN_V2] ❌ Error checking session: $e");
    }
  }

  Future<void> _handleGoogleAuthCallback(Session session) async {
    if (_isHandlingCallback) {
      print("[OTP_SCREEN_V2] ⏸️ Already handling callback, ignoring duplicate");
      return;
    }

    _isHandlingCallback = true;

    try {
      print("[OTP_SCREEN_V2] 🚀 Starting Google auth callback handling");
      final pendingRole = await Sharedprefhelper.getSharedPrefHelper('pendingGoogleAuthRole') ?? widget.role;
      await Sharedprefhelper.removeSharedPrefHelper('pendingGoogleAuthRole');

      final loginController = Get.find<LoginController>();
      loginController.isGoogleSigningIn.value = false; // Reset loading state

      // Stop polling and listeners before navigation
      _sessionCheckTimer?.cancel();
      _authStateSubscription?.cancel();

      // Save session and token first
      await Sharedprefhelper.saveSupabaseSession();
      await Sharedprefhelper.saveToken(session.accessToken);

      // Call Edge Function to ensure profile exists with role
      final api = SupabaseApiServices();
      final response = await api.callEdgeFunction('google-auth-handler', {
        'user_id': session.user.id,
        'email': session.user.email,
        'name': session.user.userMetadata?['full_name'] ?? session.user.email?.split('@')[0] ?? 'User',
        'role': pendingRole,
      });

      print("[OTP_SCREEN_V2] 📨 Profile handler response: $response");

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final body = response['body'];
        final isNewUser = body['isNewUser'] ?? false;
        final existingRole = body['existingRole'] as String?;

        // Store role in shared preferences
        await Sharedprefhelper.setSharedPrefHelper('userRole', pendingRole);
        await Sharedprefhelper.setSharedPrefHelper('user_id', session.user.id);

        // Store FCM token
        final String fcmToken = await Sharedprefhelper.getSharedPrefHelper("FcmToken") ?? "";
        if (fcmToken.isNotEmpty && SupabaseClientService.isAuthenticated) {
          await FcmService.storeFcmToken(fcmToken);
        }

        // Navigate directly from OTP screen - this ensures we're off the OTP screen
        if (isNewUser || existingRole == null) {
          // New user - navigate to profile setup
          loginController.providerController.getProvider();
          CustomToast.success("Signup successful! Please complete your profile.");
          if (pendingRole == "consumer") {
            Get.offAll(() => ConsumerProfileSetupView());
          } else {
            Get.offAll(() => ProviderServiceSelectionView(isManageService: false));
          }
        } else {
          // Existing user - navigate to home
          if (pendingRole == "consumer") {
            loginController.consumerProfileController.fetchProfile();
          } else {
            loginController.providerProfileController.fetchProfile();
          }
          CustomToast.success("Login successful!");
          // Use offAll directly to ensure OTP screen is removed
          AppRouterV2.goToNavBar(role: pendingRole, initialIndex: 0);
          loginController.providerController.getProvider();
          initializeDependencyInjection('supabase_session');
        }
        
        print("[OTP_SCREEN_V2] ✅ Google auth callback handled successfully");
      } else {
        CustomToast.error("Failed to set up profile. Please try again.");
        print("[OTP_SCREEN_V2] ❌ Profile handler error: ${response['body']}");
        _isHandlingCallback = false; // Reset on error
      }
    } catch (e) {
      print("[OTP_SCREEN_V2] ❌ Error handling callback: $e");
      final loginController = Get.find<LoginController>();
      loginController.isGoogleSigningIn.value = false; // Reset on error
      _isHandlingCallback = false; // Reset flag on error so user can retry
      CustomToast.error("An error occurred. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      body: GetBuilder<OtpController>(
        init: () {
          final controller = Get.put(OtpController());
          controller.setCredentials(widget.email, widget.role);
          return controller;
        }(),
        builder: (logic) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppSpacing.screenPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 60.h),
                        // Title
                        Text(
                          AppLocalizations.of(context)!.otpVerify,
                          style: AppTextStyles.heading2,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.smVertical),
                        // Subtitle
                        Text(
                          "${AppLocalizations.of(context)!.otpVerification} ${widget.email}",
                          style: AppTextStyles.bodyMediumSecondary,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.xlVertical),
                        // Code Input Field - Using Pinput for compatibility with existing controller
                        Pinput(
                          length: 6,
                          controller: logic.otpController.value,
                          onTapOutside: (event) {
                            FocusScope.of(context).unfocus();
                          },
                          onCompleted: (value) {
                            logic.verifyOTP(role: widget.role, email: widget.email);
                          },
                          defaultPinTheme: PinTheme(
                            width: 60.w,
                            height: 60.h,
                            textStyle: AppTextStyles.heading3.copyWith(
                              fontSize: 24.sp,
                            ),
                            decoration: BoxDecoration(
                              color: AppColorsV2.background,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                              border: Border.all(
                                color: AppColorsV2.borderLight,
                                width: 1,
                              ),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 60.w,
                            height: 60.h,
                            textStyle: AppTextStyles.heading3.copyWith(
                              fontSize: 24.sp,
                            ),
                            decoration: BoxDecoration(
                              color: AppColorsV2.background,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                              border: Border.all(
                                color: AppColorsV2.borderFocus,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lgVertical),
                        // Verify Button
                        Obx(
                          () => PrimaryButton(
                            text: logic.isLoading.value
                                ? "Verifying..."
                                : AppLocalizations.of(context)!.verify,
                            onPressed: logic.isLoading.value
                                ? null
                                : () {
                                    if (logic.otpController.value.text.length == 6) {
                                      logic.verifyOTP(role: widget.role, email: widget.email);
                                    }
                                  },
                            isLoading: logic.isLoading.value,
                          ),
                        ),
                        SizedBox(height: AppSpacing.mdVertical),
                        // Resend OTP
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: AppSpacing.iconSmall,
                                color: logic.isTimerActive || logic.isResending.value
                                    ? AppColorsV2.textSecondary
                                    : AppColorsV2.primary,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              GestureDetector(
                                onTap: logic.isTimerActive || logic.isResending.value
                                    ? null
                                    : () {
                                        logic.resendOtp();
                                      },
                                child: Text(
                                  logic.isResending.value
                                      ? "Resending..."
                                      : logic.isTimerActive
                                          ? "${AppLocalizations.of(context)!.resendIn} ${logic.remainingSeconds.value}s"
                                          : AppLocalizations.of(context)!.resendOtp,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: logic.isTimerActive || logic.isResending.value
                                        ? AppColorsV2.textSecondary
                                        : AppColorsV2.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSpacing.xlVertical),
                        // Divider with "OR" text
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppColorsV2.borderLight)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: Text(
                                "OR",
                                style: AppTextStyles.bodyMediumSecondary,
                              ),
                            ),
                            Expanded(child: Divider(color: AppColorsV2.borderLight)),
                          ],
                        ),
                        SizedBox(height: AppSpacing.lgVertical),
                        // Google Sign-In Button
                        GetBuilder<LoginController>(
                          init: Get.put(LoginController()),
                          builder: (loginLogic) {
                            return Obx(
                              () => PrimaryButton(
                                text: loginLogic.isGoogleSigningIn.value
                                    ? "Signing in..."
                                    : AppLocalizations.of(context)!.loginGoogle,
                                onPressed: loginLogic.isGoogleSigningIn.value || logic.isLoading.value
                                    ? null
                                    : () async {
                                        // Restart polling when Google sign-in is initiated
                                        _restartSessionPolling();
                                        await loginLogic.signInWithGoogle(widget.role);
                                      },
                                isLoading: loginLogic.isGoogleSigningIn.value,
                                backgroundColor: Colors.white,
                                textStyle: AppTextStyles.buttonLarge.copyWith(
                                  color: AppColorsV2.textPrimary,
                                ),
                                icon: SvgPicture.asset(
                                  height: 24.h,
                                  width: 24.w,
                                  AppVectors.svgGoogle,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: AppSpacing.mdVertical),
                        // Back Link
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Text(
                            "Back",
                            style: AppTextStyles.bodyMediumSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

