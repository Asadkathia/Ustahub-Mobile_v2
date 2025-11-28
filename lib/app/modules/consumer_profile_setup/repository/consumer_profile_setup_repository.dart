import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class ConsumerProfileSetupRepository {
  final _api = SupabaseApiServices();

  Future<dynamic> setupProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _api.updateProfile(profileData);
      return response;
    } catch (error) {
      // Handle errors appropriately
      throw Exception('Failed to set up profile: $error');
    }
  }
}
