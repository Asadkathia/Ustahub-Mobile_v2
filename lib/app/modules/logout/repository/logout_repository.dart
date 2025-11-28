import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_client.dart';

class LogoutRepository {
  Future<dynamic> logout() async {
    try {
      // Sign out from Supabase
      await SupabaseClientService.signOut();
      
      // Clear shared preferences
      await Sharedprefhelper.clearSharedPreferences();
      
      return {
        'statusCode': 200,
        'body': {
          'status': true,
          'message': 'Logged out successfully',
        },
      };
    } catch (e) {
      // Handle exceptions
      throw Exception('Logout failed: $e');
    }
  }
}
