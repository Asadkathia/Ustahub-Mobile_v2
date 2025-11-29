import 'package:ustahub/app/modules/account/view/account_view.dart';
import 'package:ustahub/app/modules/bookings/view/booking_view.dart';
import 'package:ustahub/app/modules/chat/view/chats_list.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/provider_bookings/view/provider_booking_view.dart';
import 'package:ustahub/app/modules/Auth/login/view/login_view.dart';
import 'package:ustahub/app/modules/onboarding/view/onboarding_view.dart';
import 'package:ustahub/app/modules/common_controller.dart/provider_controller.dart';
import 'package:ustahub/app/ui_v2/config/ui_config.dart';
import 'package:ustahub/app/ui_v2/screens/onboarding/onboarding_screen_v2.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String role;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(AppLocalizations.of(context)!.home, AppVectors.svgHome, 0),
          _navItem(AppLocalizations.of(context)!.chat, AppVectors.svgChat, 1),
          _navItem(
            AppLocalizations.of(context)!.booking,
            AppVectors.svgBooking,
            2,
          ),
          _navItem(
            AppLocalizations.of(context)!.account,
            AppVectors.svgAccount,
            3,
          ),
        ],
      ),
    );
  }

  Widget _navItem(String label, String assetPath, int index) {
    final isSelected = currentIndex == index;
    final color = isSelected ? Colors.green : Colors.grey;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 80.w,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetPath,
              height: 22.h,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavBar extends StatefulWidget {
  final String role;
  final int? initialIndex;

  const NavBar({super.key, required this.role, this.initialIndex});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String? role;
  String? token;

  void getTokenAndRole() async {
    token = await Sharedprefhelper.getToken();
    role = await Sharedprefhelper.getRole();

    print("[NAV_BAR DEBUG] 📱 NavBar initialized with role: $role");
    print(
      "[NAV_BAR DEBUG] 🔑 Token present: ${token != null && token!.isNotEmpty}",
    );

  }

  @override
  void initState() {
    super.initState();
    getTokenAndRole();
    
    // Initialize required controllers for guest mode
    if (widget.role == "guest") {
      // Put required controllers that might be accessed by guest views
      try {
        Get.put(ProviderController());
      } catch (e) {
        print("[NAV_BAR DEBUG] ProviderController already exists or failed to initialize: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final navController = Get.put(NavBarController());

    // Set initial index if provided (e.g., from Edit Profile)
    if (widget.initialIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navController.goToTab(widget.initialIndex!);
      });
    }

    List<Widget> pages = [
      widget.role == "consumer" 
        ? ConsumerHomepage() 
        : widget.role == "provider" 
          ? ProviderHomepageView()
          : ConsumerHomepage(), // Guests see consumer homepage
      widget.role == "guest" 
        ? _buildGuestLoginPrompt("Chat") // Prompt to login for chat
        : const BookingChatListPage(),
      widget.role == "consumer" 
        ? BookingView() 
        : widget.role == "provider"
          ? ProviderBookingView()
          : _buildGuestLoginPrompt("Bookings"), // Prompt to login for bookings
      widget.role == "guest"
        ? _buildGuestAccountView() // Guest account with login options
        : AccountView(role: widget.role),
    ];

    return Obx(
      () => Scaffold(
        body: pages[navController.selectedIndex.value],
        bottomNavigationBar: CustomBottomNavBar(
          role: widget.role,
          currentIndex: navController.selectedIndex.value,
          onTap: (index) async {
            navController.selectedIndex.value = index;
          },
        ),
      ),
    );
  }

  // Helper method to build guest login prompt
  Widget _buildGuestLoginPrompt(String feature) {
    return Scaffold(
      appBar: AppBar(
        title: Text(feature),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.login,
                size: 80.sp,
                color: AppColors.green,
              ),
              SizedBox(height: 20.h),
              Text(
                "Login Required",
                style: GoogleFonts.ubuntu(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Please login to access $feature features",
                textAlign: TextAlign.center,
                style: GoogleFonts.ubuntu(
                  fontSize: 16.sp,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: 30.h),
              BuildBasicButton(
                title: "Login Now",
                onPressed: () {
                  if (UIConfig.useNewOnboarding) {
                    Get.offAll(() => OnboardingScreenV2());
                  } else {
                    Get.offAll(() => OnboardingView());
                  }
                },
                buttonColor: AppColors.green,
                textStyle: GoogleFonts.ubuntu(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build guest account view
  Widget _buildGuestAccountView() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            SizedBox(height: 50.h),
            CircleAvatar(
              radius: 50.r,
              backgroundColor: AppColors.grey.withOpacity(0.3),
              child: Icon(
                Icons.person,
                size: 50.sp,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Guest User",
              style: GoogleFonts.ubuntu(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Create an account to access all features",
              style: GoogleFonts.ubuntu(
                fontSize: 16.sp,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 40.h),
            BuildBasicButton(
              title: "Login as Service Provider",
              onPressed: () {
                Get.offAll(() => LoginView(role: "provider"));
              },
              buttonColor: Colors.white,
              textStyle: GoogleFonts.ubuntu(
                color: AppColors.green,
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 20.h),
            BuildBasicButton(
              title: "Login as Consumer",
              onPressed: () {
                Get.offAll(() => LoginView(role: "consumer"));
              },
              buttonColor: AppColors.green,
              textStyle: GoogleFonts.ubuntu(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 20.h),
            TextButton(
              onPressed: () {
                if (UIConfig.useNewOnboarding) {
                  Get.offAll(() => OnboardingScreenV2());
                } else {
                  Get.offAll(() => OnboardingView());
                }
              },
              child: Text(
                "Back to Onboarding",
                style: GoogleFonts.ubuntu(
                  color: AppColors.grey,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Account Page", style: TextStyle(fontSize: 24)));
  }
}
