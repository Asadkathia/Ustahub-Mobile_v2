import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: false, // Set to true for development
    );
  }

  static SupabaseClient get instance => Supabase.instance.client;

  static User? get currentUser => instance.auth.currentUser;

  static String? get currentUserId => currentUser?.id;

  static bool get isAuthenticated => currentUser != null;

  static Future<void> signOut() async {
    await instance.auth.signOut();
  }
}


