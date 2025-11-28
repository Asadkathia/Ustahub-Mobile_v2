class UIConfig {
  // Feature flag to switch between old and new UI
  static const bool useNewUI = true; // Change to true when ready to use new UI
  
  // Individual screen flags (for gradual migration)
  static const bool useNewSplash = true;
  static const bool useNewOnboarding = true;
  static const bool useNewLogin = true;
  static const bool useNewOTP = true;
  static const bool useNewNavBar = true;
  static const bool useNewGuestScreens = true;
  static const bool useNewHomeScreen = true;
  static const bool useNewChat = true;
  static const bool useNewAccount = true;
  static const bool useNewBookings = true;
  static const bool useNewProviderHome = true;
  static const bool useNewServicesView = true;
  
  // You can also load this from SharedPreferences or remote config
  static Future<bool> shouldUseNewUI() async {
    // Option 1: Simple flag
    return useNewUI;
    
    // Option 2: From SharedPreferences
    // final pref = await SharedPreferences.getInstance();
    // return pref.getBool('use_new_ui') ?? false;
    
    // Option 3: Remote config (Firebase, etc.)
    // return await RemoteConfigService.getBool('use_new_ui');
  }
}

