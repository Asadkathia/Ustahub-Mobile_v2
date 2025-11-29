import 'package:ustahub/app/export/exports.dart';
import 'dart:async';
import 'package:ustahub/app/modules/onboarding/view/onboarding_view.dart';
import 'package:ustahub/app/ui_v2/config/ui_config.dart';
import 'package:ustahub/app/ui_v2/navigation/app_router_v2.dart';
import 'package:ustahub/app/ui_v2/screens/onboarding/onboarding_screen_v2.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';

class SplashScreenV2 extends StatefulWidget {
  const SplashScreenV2({super.key});

  @override
  State<SplashScreenV2> createState() => _SplashScreenV2State();
}

class _SplashScreenV2State extends State<SplashScreenV2> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    String? token = await Sharedprefhelper.getSharedPrefHelper('token');
    print("Token: $token");
    String? role = await Sharedprefhelper.getSharedPrefHelper('userRole');
    print("Role: $role");
    
    // Check for Supabase session (for Google OAuth)
    final supabase = SupabaseClientService.instance;
    final supabaseSession = supabase.auth.currentSession;
    final hasSupabaseSession = supabaseSession != null;
    
    // Check if there's a pending Google auth (user just completed OAuth)
    final pendingGoogleAuthRole = await Sharedprefhelper.getSharedPrefHelper('pendingGoogleAuthRole');
    
    if (hasSupabaseSession && pendingGoogleAuthRole != null) {
      // Handle Google auth callback
      print("[SPLASH] 🔐 Handling Google auth callback for role: $pendingGoogleAuthRole");
      try {
        final loginController = Get.put(LoginController());
        await loginController.handlePostGoogleSignIn(pendingGoogleAuthRole, supabaseSession);
        await Sharedprefhelper.removeSharedPrefHelper('pendingGoogleAuthRole');
        return; // Navigation handled in _handlePostGoogleSignIn
      } catch (e) {
        print("[SPLASH] ❌ Error handling Google auth: $e");
        // Fall through to normal flow
      }
    }
    
    // Check if user has seen onboarding before
    String? hasSeenOnboarding = await Sharedprefhelper.getSharedPrefHelper('hasSeenOnboarding');
    String? userMode = await Sharedprefhelper.getSharedPrefHelper('userMode');
    print("Has seen onboarding: $hasSeenOnboarding");
    print("User mode: $userMode");

    final providerProfilie = Get.put(ProviderProfileController());
    final consumerProfile = Get.put(ConsumerProfileController());
    // Initialize ProviderController for ConsumerHomepage dependency
    Get.put(ProviderController());

    // Precache images to prevent freeze during navigation
    await _precacheImages();

    Timer(const Duration(seconds: 3), () {
     if (token != null && token.isNotEmpty || hasSupabaseSession) {
       // User is logged in, go to main app
       AppRouterV2.goToNavBar(role: role ?? "consumer");
        if(role == "consumer" || role == null){
          consumerProfile.fetchProfile();
        }else{
          providerProfilie.fetchProfile();
        }
      } else {
        // User is not logged in
        if (hasSeenOnboarding == 'true') {
          // User has seen onboarding before, use their saved preference
          if (userMode == 'guest') {
            // User chose to continue as guest, go to guest mode
            AppRouterV2.goToNavBar(role: "guest");
          } else {
            // User chose provider/consumer but didn't complete login, take them to onboarding
            // String defaultRole = userMode ?? "consumer";
            if (UIConfig.useNewOnboarding) {
              Get.offAll(() => OnboardingScreenV2());
            } else {
              Get.offAll(() => OnboardingView());
            }
          }
        } else {
          // First time user, show onboarding
          if (UIConfig.useNewOnboarding) {
            Get.offAll(() => OnboardingScreenV2());
          } else {
            Get.offAll(() => OnboardingView());
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // USTAHUB Logo
            Image.asset(
              'images/Logo/Ustahub logo copy.png',
              height: 96.h,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  'USTAHUB',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColorsV2.textPrimary,
                    letterSpacing: 1.2,
                  ),
                );
              },
            ),
            SizedBox(height: AppSpacing.xlVertical),
            // Loading Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.w),
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColorsV2.primary),
                backgroundColor: AppColorsV2.primaryLight.withOpacity(0.3),
                minHeight: 4.h,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _precacheImages() async {
    try {
      final BuildContext? context = Get.context;
      if (context == null) return;

      // List of all images to precache
      final List<String> imagesToPrecache = [
        // Onboarding images
        'imgs/uzbek/WhatsApp Image 2025-11-26 at 00.09.00.jpeg',
        'imgs/uzbek/12.png',
        'imgs/uzbek/10.png',
        // Banner images
        'imgs/uzbek/9.png',
        'imgs/uzbek/WhatsApp Image 2025-11-26 at 00.11.22.jpeg',
        'imgs/uzbek/3.png',
        // Logo images
        'images/Logo/Ustahub logo copy.png',
        'images/Logo/Ustahub logo copy12.png',
      ];

      print("[SPLASH] Starting image precaching...");
      
      // Precache all images in parallel
      await Future.wait(
        imagesToPrecache.map((imagePath) async {
          try {
            await precacheImage(AssetImage(imagePath), context);
            print("[SPLASH] ✅ Precached: $imagePath");
          } catch (e) {
            print("[SPLASH] ⚠️ Failed to precache $imagePath: $e");
            // Continue with other images even if one fails
          }
        }),
      );
      
      print("[SPLASH] ✅ All images precached successfully");
    } catch (e) {
      print("[SPLASH] ⚠️ Error during image precaching: $e");
      // Continue even if precaching fails
    }
  }
}

