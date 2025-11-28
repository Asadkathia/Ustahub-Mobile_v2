import 'package:shared_preferences/shared_preferences.dart';
import 'package:ustahub/network/supabase_client.dart';

class Sharedprefhelper {
  static Future<void> setSharedPrefHelper(String key, String value) async {
    print("Setting $key to $value");
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(key, value);
  }

  static Future<String?> getSharedPrefHelper(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  static Future<void> saveToken(String token) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    print("Token: $token");
    pref.setString('token', token);
  }

  static Future<String?> getToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    String? token = pref.getString('token');
    return token;
  }

   static Future<String?> getRole() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    
    String? role = pref.getString('userRole');
    return role;
  }

  static Future<void> clearSharedPreferences() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }

  // Supabase session helpers
  static Future<void> saveSupabaseSession() async {
    try {
      final supabase = SupabaseClientService.instance;
      final session = supabase.auth.currentSession;
      if (session != null) {
        await setSharedPrefHelper('supabase_access_token', session.accessToken);
        await setSharedPrefHelper('supabase_refresh_token', session.refreshToken ?? '');
        await setSharedPrefHelper('supabase_user_id', session.user.id);
      }
    } catch (e) {
      print('[SHARED_PREF] Error saving Supabase session: $e');
    }
  }

  static Future<String?> getSupabaseAccessToken() async {
    return await getSharedPrefHelper('supabase_access_token');
  }

  static Future<String?> getSupabaseUserId() async {
    return await getSharedPrefHelper('supabase_user_id');
  }

  // Check if user has Supabase session
  static Future<bool> hasSupabaseSession() async {
    final token = await getSupabaseAccessToken();
    return token != null && token.isNotEmpty;
  }
}
