import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/ui_v2/navigation/app_router_v2.dart';
import 'package:ustahub/app/ui_v2/config/ui_config.dart';
import 'package:ustahub/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final RxBool isGoogleSigningIn = false.obs;
  final RxBool isSigningUp = false.obs;

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

        // Navigate to OTP verification screen - use new UI if enabled
        final otpController = Get.put(OtpController());
        otpController.setCredentials(safeEmail, role);

        if (UIConfig.useNewOTP) {
          AppRouterV2.toOtpV2(role: role, email: safeEmail);
        } else {
          Get.to(() => OtpView(email: safeEmail, role: role));
        }
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

  // Sign up with email and password
  Future<void> signUpWithEmailPassword(String email, String password, String role) async {
    if (isSigningUp.value || isLoading.value) return;
    isSigningUp.value = true;
    isLoading.value = true;

    try {
      print("[SIGNUP] 🔐 Starting email/password sign-up for: $email, role: $role");
      
      final supabase = SupabaseClientService.instance;
      
      // Sign up with Supabase
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': role,
        },
      );

      if (response.session != null && response.user != null) {
        print("[SIGNUP] ✅ User created successfully");
        
        // Save session
        await Sharedprefhelper.saveSupabaseSession();
        await Sharedprefhelper.saveToken(response.session!.accessToken);
        
        // Store role temporarily for profile creation
        await Sharedprefhelper.setSharedPrefHelper('pendingGoogleAuthRole', role);
        
        // Call Edge Function to create profile with role
        final api = SupabaseApiServices();
        final profileResponse = await api.callEdgeFunction('google-auth-handler', {
          'user_id': response.user!.id,
          'email': response.user!.email ?? email,
          'name': response.user!.userMetadata?['full_name'] ?? email.split('@')[0],
          'role': role,
        });

        print("[SIGNUP] 📨 Profile handler response: $profileResponse");

        if (profileResponse['statusCode'] == 200 || profileResponse['statusCode'] == 201) {
          // Store role and user ID
          await Sharedprefhelper.setSharedPrefHelper('userRole', role);
          await Sharedprefhelper.setSharedPrefHelper('user_id', response.user!.id);
          await Sharedprefhelper.removeSharedPrefHelper('pendingGoogleAuthRole');

          // Store FCM token
          final String fcmToken = await Sharedprefhelper.getSharedPrefHelper("FcmToken") ?? "";
          if (fcmToken.isNotEmpty) {
            await FcmService.storeFcmToken(fcmToken);
          }

          // New user - navigate to profile setup
          providerController.getProvider();
          CustomToast.success("Signup successful! Please complete your profile.");
          if (role == "consumer") {
            Get.offAll(() => ConsumerProfileSetupView());
          } else {
            Get.offAll(() => ProviderServiceSelectionView(isManageService: false));
          }
        } else {
          CustomToast.error("Failed to create profile. Please try again.");
          print("[SIGNUP] ❌ Profile handler error: ${profileResponse['body']}");
        }
      } else {
        // Email confirmation might be required
        if (response.user != null) {
          CustomToast.success("Please check your email to verify your account.");
          // Navigate back to login
          Get.back();
        } else {
          CustomToast.error("Failed to create account. Please try again.");
        }
      }
    } catch (e) {
      print("[SIGNUP] ❌ Error: $e");
      String errorMessage = "Failed to create account. Please try again.";
      if (e.toString().contains('already registered')) {
        errorMessage = "This email is already registered. Please sign in instead.";
      } else if (e.toString().contains('password')) {
        errorMessage = "Password is too weak. Please use a stronger password.";
      }
      CustomToast.error(errorMessage);
    } finally {
      isSigningUp.value = false;
      isLoading.value = false;
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmailPassword(String email, String password, String role) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      print("[LOGIN] 🔐 Starting email/password sign-in for: $email, role: $role");
      
      final supabase = SupabaseClientService.instance;
      
      // Sign in with Supabase
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null && response.user != null) {
        print("[LOGIN] ✅ User signed in successfully");
        
        // Save session
        await Sharedprefhelper.saveSupabaseSession();
        await Sharedprefhelper.saveToken(response.session!.accessToken);
        
        // Get user profile to check role
        final profileResponse = await supabase
            .from('user_profiles')
            .select('role')
            .eq('id', response.user!.id)
            .maybeSingle();

        final userRole = (profileResponse != null && profileResponse['role'] != null)
            ? profileResponse['role'] as String
            : role;
        
        // Store role and user ID
        await Sharedprefhelper.setSharedPrefHelper('userRole', userRole);
        await Sharedprefhelper.setSharedPrefHelper('user_id', response.user!.id);

        // Store FCM token
        final String fcmToken = await Sharedprefhelper.getSharedPrefHelper("FcmToken") ?? "";
        if (fcmToken.isNotEmpty) {
          await FcmService.storeFcmToken(fcmToken);
        }

        // Navigate to home
        if (userRole == "consumer") {
          consumerProfileController.fetchProfile();
        } else {
          providerProfileController.fetchProfile();
        }
        CustomToast.success("Login successful!");
        AppRouterV2.goToNavBar(role: userRole, initialIndex: 0);
        providerController.getProvider();
        initializeDependencyInjection('supabase_session');
      } else {
        CustomToast.error("Failed to sign in. Please check your credentials.");
      }
    } catch (e) {
      print("[LOGIN] ❌ Error: $e");
      String errorMessage = "Failed to sign in. Please try again.";
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = "Invalid email or password. Please try again.";
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = "Please verify your email before signing in.";
      }
      CustomToast.error(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with Google using Supabase OAuth
  Future<void> signInWithGoogle(String role) async {
    if (isGoogleSigningIn.value) return; // Prevent multiple submissions
    isGoogleSigningIn.value = true;

    try {
      print("[GOOGLE AUTH] 🔐 Starting Google sign-in for role: $role");
      
      final supabase = SupabaseClientService.instance;
      
      // Store role temporarily for post-auth handling
      await Sharedprefhelper.setSharedPrefHelper('pendingGoogleAuthRole', role);
      
      // Initiate Google OAuth flow
      // The redirect URL should match what's configured in Supabase dashboard
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.ustahub://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
        queryParams: {
          'access_type': 'offline',
          'prompt': 'consent',
        },
      );

      print("[GOOGLE AUTH] 📱 OAuth flow initiated");

      // The session will be created automatically when OAuth callback is handled
      // We'll check for the session in the app's main initialization or splash screen

    } catch (e) {
      print("[GOOGLE AUTH] ❌ Error: $e");
      CustomToast.error("Failed to sign in with Google. Please try again.");
      isGoogleSigningIn.value = false;
    }
  }

  // Call this method after OAuth callback completes (e.g., from splash screen or main.dart)
  static Future<void> handleGoogleAuthCallback() async {
    try {
      final supabase = SupabaseClientService.instance;
      final session = supabase.auth.currentSession;
      
      if (session != null) {
        print("[GOOGLE AUTH] ✅ Session found after OAuth callback");
        
        // Get pending role from shared preferences
        final pendingRole = await Sharedprefhelper.getSharedPrefHelper('pendingGoogleAuthRole') ?? 'consumer';
        await Sharedprefhelper.removeSharedPrefHelper('pendingGoogleAuthRole');
        
        // Handle post-sign-in
        final controller = Get.put(LoginController());
        await controller.handlePostGoogleSignIn(pendingRole, session);
      }
    } catch (e) {
      print("[GOOGLE AUTH] ❌ Callback handling error: $e");
    }
  }

  // Handle post-Google sign-in: check profile, create/update with role
  // Made public so splash screen can call it
  Future<void> handlePostGoogleSignIn(String role, Session session) async {
    try {
      final supabase = SupabaseClientService.instance;
      final user = session.user;
      
      print("[GOOGLE AUTH] 👤 User ID: ${user.id}, Email: ${user.email}");

      // Save session
      await Sharedprefhelper.saveSupabaseSession();

      // Call Edge Function to ensure profile exists with role
      final api = SupabaseApiServices();
      final response = await api.callEdgeFunction('google-auth-handler', {
        'user_id': user.id,
        'email': user.email,
        'name': user.userMetadata?['full_name'] ?? user.email?.split('@')[0] ?? 'User',
        'role': role,
      });

      print("[GOOGLE AUTH] 📨 Profile handler response: $response");

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        final body = response['body'];
        final isNewUser = body['isNewUser'] ?? false;
        final existingRole = body['existingRole'] as String?;

        // Store role in shared preferences
        await Sharedprefhelper.setSharedPrefHelper('userRole', role);
        await Sharedprefhelper.setSharedPrefHelper('user_id', user.id);
        
        // Save token for compatibility with existing auth checks
        // Use Supabase access token as the token
        await Sharedprefhelper.saveToken(session.accessToken);

        // Store FCM token
        final String fcmToken = await Sharedprefhelper.getSharedPrefHelper("FcmToken") ?? "";
        if (fcmToken.isNotEmpty && SupabaseClientService.isAuthenticated) {
          await FcmService.storeFcmToken(fcmToken);
        }

        if (isNewUser || existingRole == null) {
          // New user - navigate to profile setup
          providerController.getProvider();
          CustomToast.success("Signup successful! Please complete your profile.");
          if (role == "consumer") {
            Get.offAll(() => ConsumerProfileSetupView());
          } else {
            Get.offAll(() => ProviderServiceSelectionView(isManageService: false));
          }
        } else {
          // Existing user - navigate to home
          if (role == "consumer") {
            consumerProfileController.fetchProfile();
          } else {
            providerProfileController.fetchProfile();
          }
          CustomToast.success("Login successful!");
          // Use offAll to ensure OTP screen is removed from navigation stack
          AppRouterV2.goToNavBar(role: role, initialIndex: 0);
          providerController.getProvider();
          initializeDependencyInjection('supabase_session');
        }
      } else {
        CustomToast.error("Failed to set up profile. Please try again.");
        print("[GOOGLE AUTH] ❌ Profile handler error: ${response['body']}");
      }
    } catch (e) {
      print("[GOOGLE AUTH] ❌ Post-sign-in error: $e");
      CustomToast.error("An error occurred. Please try again.");
    }
  }
}
