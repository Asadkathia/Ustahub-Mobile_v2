import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/ui_v2/navigation/app_router_v2.dart';
import 'package:ustahub/app/ui_v2/config/ui_config.dart';
import 'package:ustahub/app/ui_v2/screens/onboarding/onboarding_screen_v2.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
    
    // Check if user has seen onboarding before
    String? hasSeenOnboarding = await Sharedprefhelper.getSharedPrefHelper('hasSeenOnboarding');
    String? userMode = await Sharedprefhelper.getSharedPrefHelper('userMode');
    print("Has seen onboarding: $hasSeenOnboarding");
    print("User mode: $userMode");

    final providerProfilie = Get.put(ProviderProfileController());
    final consumerProfile = Get.put(ConsumerProfileController());
    // Initialize ProviderController for ConsumerHomepage dependency
    Get.put(ProviderController());

    Timer(const Duration(seconds: 3), () {
      if (token != null && token.isNotEmpty) {
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
            // User chose provider/consumer but didn't complete login, take them to login
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
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Usta Hub",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green, // Dark green
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: LinearProgressIndicator(
                color: Colors.green,
                backgroundColor: Colors.greenAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
