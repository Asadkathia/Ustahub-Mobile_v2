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

class SignUpScreenV2 extends StatefulWidget {
  final String? initialRole;
  
  const SignUpScreenV2({
    super.key,
    this.initialRole,
  });

  @override
  State<SignUpScreenV2> createState() => _SignUpScreenV2State();
}

class _SignUpScreenV2State extends State<SignUpScreenV2> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = 'consumer';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  StreamSubscription<AuthState>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedRole = widget.initialRole ?? 'consumer';
    _setupAuthListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authStateSubscription?.cancel();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
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
      print("[SIGNUP_SCREEN_V2] ❌ Error checking session: $e");
    }
  }

  Future<void> _handleGoogleAuthCallback(Session session) async {
    try {
      final pendingRole = await Sharedprefhelper.getSharedPrefHelper('pendingGoogleAuthRole') ?? _selectedRole;
      final loginController = Get.find<LoginController>();
      loginController.isGoogleSigningIn.value = false;
      await loginController.handlePostGoogleSignIn(pendingRole, session);
    } catch (e) {
      print("[SIGNUP_SCREEN_V2] ❌ Error handling callback: $e");
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
          // Sync email controller with LoginController
          if (logic.emailController.value.text != _emailController.text) {
            _emailController.text = logic.emailController.value.text;
          }

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
                          SizedBox(height: 40.h),
                          // Title
                          Text(
                            "Create Account",
                            style: AppTextStyles.heading2,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.smVertical),
                          // Subtitle
                          Text(
                            "Sign up to get started",
                            style: AppTextStyles.bodyMediumSecondary,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.xlVertical),
                          // Role Selection
                          Container(
                            padding: EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColorsV2.background,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                              border: Border.all(
                                color: AppColorsV2.borderLight,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedRole = 'consumer';
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: AppSpacing.md,
                                        horizontal: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _selectedRole == 'consumer'
                                            ? AppColorsV2.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                      ),
                                      child: Text(
                                        "Consumer",
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: _selectedRole == 'consumer'
                                              ? AppColorsV2.textOnPrimary
                                              : AppColorsV2.textSecondary,
                                          fontWeight: _selectedRole == 'consumer'
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedRole = 'provider';
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: AppSpacing.md,
                                        horizontal: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _selectedRole == 'provider'
                                            ? AppColorsV2.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                      ),
                                      child: Text(
                                        "Provider",
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: _selectedRole == 'provider'
                                              ? AppColorsV2.textOnPrimary
                                              : AppColorsV2.textSecondary,
                                          fontWeight: _selectedRole == 'provider'
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppSpacing.lgVertical),
                          // Email Input Field
                          AppTextField(
                            controller: _emailController,
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
                            onChanged: (value) {
                              logic.emailController.value.text = value;
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
                                return "Please enter a password";
                              }
                              if (val.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.lgVertical),
                          // Confirm Password Input Field
                          AppTextField(
                            controller: _confirmPasswordController,
                            hintText: "Confirm Password",
                            obscureText: _obscureConfirmPassword,
                            prefixIcon: Icon(
                              Icons.lock_outlined,
                              color: AppColorsV2.textSecondary,
                              size: AppSpacing.iconMedium,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColorsV2.textSecondary,
                                size: AppSpacing.iconMedium,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Please confirm your password";
                              }
                              if (val != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: AppSpacing.xlVertical),
                          // Sign Up Button
                          Obx(
                            () => PrimaryButton(
                              text: logic.isLoading.value
                                  ? "Creating Account..."
                                  : "Sign Up",
                              onPressed: logic.isLoading.value ||
                                      logic.isGoogleSigningIn.value
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        logic.signUpWithEmailPassword(
                                          _emailController.text.trim(),
                                          _passwordController.text,
                                          _selectedRole,
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
                                  ? "Signing up..."
                                  : "Sign up with Google",
                              onPressed: logic.isGoogleSigningIn.value ||
                                      logic.isLoading.value
                                  ? null
                                  : () {
                                      logic.signInWithGoogle(_selectedRole);
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
                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: AppTextStyles.bodyMediumSecondary,
                              ),
                              GestureDetector(
                                onTap: () {
                                  AppRouterV2.toLoginV2(role: _selectedRole);
                                },
                                child: Text(
                                  "Log In",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColorsV2.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.xlVertical),
                          // Terms and Privacy Policy
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenPaddingHorizontal,
                            ),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: AppTextStyles.bodySmall,
                                children: [
                                  TextSpan(
                                    text: "By continuing, you agree to our ",
                                  ),
                                  TextSpan(
                                    text: "Terms & Conditions",
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColorsV2.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " and ",
                                  ),
                                  TextSpan(
                                    text: "Privacy Policy",
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColorsV2.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
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

