import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/account/view/account_view.dart';
import 'package:ustahub/app/modules/bookings/view/booking_view.dart';
import 'package:ustahub/app/modules/provider_bookings/view/provider_booking_view.dart';
import 'package:ustahub/app/modules/provider_homepage/view/provider_homepage_view.dart';
import 'package:ustahub/app/modules/common_controller.dart/provider_controller.dart';
import 'package:ustahub/app/modules/chat/view/chats_list.dart';
import '../../components/navigation/bottom_nav_bar_v2.dart';
import '../../config/ui_config.dart';
import '../guest/login_required_screen_v2.dart';
import '../account/guest_account_screen_v2.dart';
import '../home/home_screen_v2.dart';
import '../home/provider_home_screen_v2.dart';
import '../chat/chat_screen_v2.dart';
import '../account/account_screen_v2.dart';
import '../bookings/booking_screen_v2.dart';
import '../bookings/provider_booking_screen_v2.dart';

class NavBarV2 extends StatefulWidget {
  final String role;
  final int? initialIndex;

  const NavBarV2({super.key, required this.role, this.initialIndex});

  @override
  State<NavBarV2> createState() => _NavBarV2State();
}

class _NavBarV2State extends State<NavBarV2> {
  String? role;
  String? token;

  void getTokenAndRole() async {
    token = await Sharedprefhelper.getToken();
    role = await Sharedprefhelper.getRole();

    print("[NAV_BAR_V2 DEBUG] 📱 NavBarV2 initialized with role: $role");
    print(
      "[NAV_BAR_V2 DEBUG] 🔑 Token present: ${token != null && token!.isNotEmpty}",
    );
  }

  @override
  void initState() {
    super.initState();
    getTokenAndRole();
    
    // Initialize required controllers for guest mode
    if (widget.role == "guest") {
      try {
        Get.put(ProviderController());
      } catch (e) {
        print("[NAV_BAR_V2 DEBUG] ProviderController already exists or failed to initialize: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final navController = Get.put(NavBarController());

    // Set initial index if provided
    if (widget.initialIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navController.goToTab(widget.initialIndex!);
      });
    }

    List<Widget> pages = [
      widget.role == "consumer" 
        ? (UIConfig.useNewHomeScreen ? HomeScreenV2() : ConsumerHomepage())
        : widget.role == "provider" 
          ? (UIConfig.useNewProviderHome ? ProviderHomeScreenV2() : ProviderHomepageView())
          : (UIConfig.useNewHomeScreen ? HomeScreenV2() : ConsumerHomepage()), // Guests see new home screen
      widget.role == "guest" 
        ? LoginRequiredScreenV2(feature: "Chat")
        : (UIConfig.useNewChat ? ChatScreenV2() : const BookingChatListPage()),
      widget.role == "consumer" 
        ? (UIConfig.useNewBookings ? BookingScreenV2() : BookingView())
        : widget.role == "provider"
          ? (UIConfig.useNewBookings ? ProviderBookingScreenV2() : ProviderBookingView())
          : LoginRequiredScreenV2(feature: "Bookings"),
      widget.role == "guest"
        ? GuestAccountScreenV2()
        : (UIConfig.useNewAccount ? AccountScreenV2(role: widget.role) : AccountView(role: widget.role)),
    ];

    return Obx(
      () => Scaffold(
        body: pages[navController.selectedIndex.value],
        bottomNavigationBar: BottomNavBarV2(
          role: widget.role,
          currentIndex: navController.selectedIndex.value,
          onTap: (index) async {
            navController.selectedIndex.value = index;
          },
        ),
      ),
    );
  }
}

