class UIConfig {
  // Feature flag to switch between old and new UI
  static const bool useNewUI = true;
  
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
  
  static Future<bool> shouldUseNewUI() async {
    return useNewUI;
  }
}

