import 'dart:async';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/Auth/login/controller/login_controller.dart';
import 'package:ustahub/app/ui_v2/navigation/app_router_v2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../design_system/colors/app_colors_v2.dart';
import '../../../design_system/typography/app_text_styles.dart';
import '../../../design_system/spacing/app_spacing.dart';
import '../../../components/buttons/primary_button.dart';
import '../../../components/inputs/app_text_field.dart';

class LoginScreenV2 extends StatefulWidget {
  final String role;
  
  const LoginScreenV2({
    super.key,
    required this.role,
  });

  @override
  State<LoginScreenV2> createState() => _LoginScreenV2State();
}

class _LoginScreenV2State extends State<LoginScreenV2> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAuthListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authStateSubscription?.cancel();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkForGoogleAuthSession();
    }
  }

  void _setupAuthListener() {
    final supabase = SupabaseClientService.instance;
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _handleGoogleAuthCallback(session);
      }
    });
  }

  Future<void> _checkForGoogleAuthSession() async {
    try {
      final supabase = SupabaseClientService.instance;
      final session = supabase.auth.currentSession;
      final pendingRole = await Sharedprefhelper.getSharedPrefHelper('pendingGoogleAuthRole');

      if (session != null && pendingRole != null) {
        await _handleGoogleAuthCallback(session);
      }
    } catch (e) {
      print("[LOGIN_SCREEN_V2] ❌ Error checking session: $e");
    }
  }

  Future<void> _handleGoogleAuthCallback(Session session) async {
    try {
      final pendingRole = await Sharedprefhelper.getSharedPrefHelper('pendingGoogleAuthRole') ?? widget.role;
      final loginController = Get.find<LoginController>();
      loginController.isGoogleSigningIn.value = false;
      await loginController.handlePostGoogleSignIn(pendingRole, session);
    } catch (e) {
      print("[LOGIN_SCREEN_V2] ❌ Error handling callback: $e");
      final loginController = Get.find<LoginController>();
      loginController.isGoogleSigningIn.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      body: GetBuilder<LoginController>(
        init: Get.put(LoginController()),
        builder: (logic) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(AppSpacing.screenPadding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 60.h),
                          // Title
                          Text(
                            "Welcome Back",
                            style: AppTextStyles.heading2,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.smVertical),
                          // Subtitle
                          Text(
                            "Sign in to continue",
                            style: AppTextStyles.bodyMediumSecondary,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.xlVertical),
                          // Email Input Field
                          AppTextField(
                            controller: logic.emailController.value,
                            hintText: "Email",
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppColorsV2.textSecondary,
                              size: AppSpacing.iconMedium,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Please enter your email";
                              }
                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(val.trim())) {
                                return "Please enter a valid email";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.lgVertical),
                          // Password Input Field
                          AppTextField(
                            controller: _passwordController,
                            hintText: "Password",
                            obscureText: _obscurePassword,
                            prefixIcon: Icon(
                              Icons.lock_outlined,
                              color: AppColorsV2.textSecondary,
                              size: AppSpacing.iconMedium,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColorsV2.textSecondary,
                                size: AppSpacing.iconMedium,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Please enter your password";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.mdVertical),
                          // Forgot Password Link (optional, can be added later)
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       // Navigate to forgot password screen
                          //     },
                          //     child: Text(
                          //       "Forgot Password?",
                          //       style: AppTextStyles.bodyMedium.copyWith(
                          //         color: AppColorsV2.primary,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          SizedBox(height: AppSpacing.lgVertical),
                          // Login Button
                          Obx(
                            () => PrimaryButton(
                              text: logic.isLoading.value
                                  ? "Signing in..."
                                  : "Log In",
                              onPressed: logic.isLoading.value ||
                                      logic.isGoogleSigningIn.value
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        logic.signInWithEmailPassword(
                                          logic.emailController.value.text.trim(),
                                          _passwordController.text,
                                          widget.role,
                                        );
                                      }
                                    },
                              isLoading: logic.isLoading.value,
                            ),
                          ),
                          SizedBox(height: AppSpacing.lgVertical),
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
                          Obx(
                            () => PrimaryButton(
                              text: logic.isGoogleSigningIn.value
                                  ? "Signing in..."
                                  : "Sign in with Google",
                              onPressed: logic.isGoogleSigningIn.value ||
                                      logic.isLoading.value
                                  ? null
                                  : () {
                                      logic.signInWithGoogle(widget.role);
                                    },
                              isLoading: logic.isGoogleSigningIn.value,
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
                          ),
                          SizedBox(height: AppSpacing.mdVertical),
                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: AppTextStyles.bodyMediumSecondary,
                              ),
                              GestureDetector(
                                onTap: () {
                                  AppRouterV2.toSignUpV2(role: widget.role);
                                },
                                child: Text(
                                  "Sign Up",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColorsV2.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

