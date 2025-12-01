import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/ui_v2/ui_v2_exports.dart';
import 'package:ustahub/firebase_options.dart';
import 'package:ustahub/network/supabase_client.dart';

// Background message handler - must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}'); 
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  // Get Supabase credentials from API settings: https://supabase.com/dashboard/project/pyezhaebfvitqkpsjsil/settings/api
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://pyezhaebfvitqkpsjsil.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB5ZXpoYWViZnZpdHFrcHNqc2lsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM0ODYxMjcsImV4cCI6MjA3OTA2MjEyN30.qPfqvJ2xAWIufRY31tFgcqv9hC339mv6450FKyRd0Ds',
  );
  
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await SupabaseClientService.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    print('[SUPABASE] ✅ Initialized successfully');
  } else {
    print('[SUPABASE] ⚠️ Not initialized - missing anon key. Get it from: https://supabase.com/dashboard/project/pyezhaebfvitqkpsjsil/settings/api');
  }

  // Initialize Firebase Messaging for background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Handle Flutter lifecycle errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  // Firebase is configured natively in Android - no Flutter initialization needed
  // The FirebaseNotificationsHandler will automatically use the native Firebase setup

  // Load saved locale from shared preferences
  String? localeName = await Sharedprefhelper.getSharedPrefHelper('Locale');
  String finalLocale = localeName ?? 'en';

  // Ensure the locale is saved (if not already)
  await Sharedprefhelper.setSharedPrefHelper('Locale', finalLocale);

  // Initialize GetX controller after sharedPref setup

  String? token = await Sharedprefhelper.getToken();
  initializeDependencyInjection(token);

  // Start app with saved or default locale
  runApp(MainApp(initialLocale: finalLocale));
}

void initializeDependencyInjection(String? token, {String ? fcmToken}) {
  Get.put(LanguageController(), permanent: true);
  Get.lazyPut(() => FilterController());
  Get.lazyPut(() => NavBarController());

  if (token != null && token.isNotEmpty) {
    print("[MAIN_APP DEBUG] 🎯 User is logged in, initializing services...");
    Get.lazyPut(() => BannerController());
    Get.lazyPut(() => BookingRequestController());
    Get.lazyPut(() => ProviderController());
    Get.lazyPut(() => CheckoutController());
    print("[MAIN_APP DEBUG] ✅ All services initialized successfully");
  } else {
    print("[MAIN_APP DEBUG] ❌ No token found, user not logged in");
  }
}

class MainApp extends StatelessWidget {
  final String initialLocale;
  const MainApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return FirebaseNotificationsHandler(
      localNotificationsConfiguration: LocalNotificationsConfiguration(
        androidConfig: AndroidNotificationsConfig(
          // ...
        ),
        iosConfig: IosNotificationsConfig(
          // ...
        ),
      ),
      shouldHandleNotification: (msg) => true,
      onOpenNotificationArrive: (info) {
        print("[FIREBASE DEBUG] 🔔 Notification arrived while app open");
        print(
          "[FIREBASE DEBUG] Title: ${info.firebaseMessage.notification?.title}",
        );
        print(
          "[FIREBASE DEBUG] Body: ${info.firebaseMessage.notification?.body}",
        );
      },
      onTap: (info) {
        // Handle notification tap
        print("[FIREBASE DEBUG] 📱 Notification tapped");
        print("[FIREBASE DEBUG] Payload: ${info.payload}");
        print("[FIREBASE DEBUG] App State: ${info.appState}");
        print("[FIREBASE DEBUG] Firebase Message: ${info.firebaseMessage}");
      },
      onFcmTokenInitialize: (token) async {
        Sharedprefhelper.setSharedPrefHelper('FcmToken', token!);
        
        if (token != null && token.isNotEmpty) {
          await FcmService.storeFcmToken(token);
        }
        print("[FIREBASE DEBUG] 🔑 FCM Token initialized: $token");
      },
      onFcmTokenUpdate: (token) async {
        Sharedprefhelper.setSharedPrefHelper('FcmToken', token);
        print("[FIREBASE DEBUG] 🔄 FCM Token updated: $token");
        String? prefToken = await Sharedprefhelper.getToken();
        if (prefToken != null && prefToken.isNotEmpty) {
          await FcmService.storeFcmToken(token);
        }
      },

      child: ScreenUtilInit(
        designSize: const Size(360, 800),
        minTextAdapt: true,
        splitScreenMode: true,
        builder:
            (_, __) => GetMaterialApp(
              debugShowCheckedModeBanner: false,
              theme: UIConfig.useNewUI ? AppThemeV2.theme : AppTheme.appTheme,
              locale: Locale(initialLocale),
              supportedLocales: const [
                Locale('en'),
                Locale('ru'),
                Locale('uz'),
                Locale('ky'),
                Locale('kk'),
                Locale('ur'),
                Locale('ar'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: UIConfig.useNewSplash ? const SplashScreenV2() : SplashScreen(),
            ),
      ),
    );
  }
}
