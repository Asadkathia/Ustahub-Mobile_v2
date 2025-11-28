
import '../../../export/exports.dart';
import 'package:ustahub/network/supabase_client.dart';

class AccountRespository {
  Future<dynamic> deleteAccount() async {
    try {
      final supabase = SupabaseClientService.instance;
      final userId = SupabaseClientService.currentUserId;
      
      if (userId == null) {
        return {
          'statusCode': 401,
          'body': {'status': false, 'message': 'User not authenticated'}
        };
      }

      // Note: User account deletion should be handled via Edge Function with admin privileges
      // For now, we'll mark the user as deleted in user_profiles and sign them out
      // The actual auth.users deletion should be done server-side via Edge Function
      await supabase
          .from('user_profiles')
          .update({'is_deleted': true, 'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
      
      // Sign out and clear local data
      await SupabaseClientService.signOut();
      await Sharedprefhelper.clearSharedPreferences();
      
      return {
        'statusCode': 200,
        'body': {'status': true, 'message': 'Account deleted successfully'}
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'body': {'status': false, 'message': 'Failed to delete account: $e'}
      };
    }
  }
}
