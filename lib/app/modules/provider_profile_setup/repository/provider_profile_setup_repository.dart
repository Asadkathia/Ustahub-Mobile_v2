import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class ProviderProfileSetupRepository {
  final _api = SupabaseApiServices();

  Future<dynamic> setupProfile({
    required Map<String, dynamic> data,
  })async{
    final response = await _api.updateProfile(data);
    return response;
  }
}