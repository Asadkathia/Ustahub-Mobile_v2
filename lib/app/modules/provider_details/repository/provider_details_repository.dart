import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class ProviderDetailsRepository extends GetxController {
  final _api = SupabaseApiServices();

  Future<dynamic> getProviderById(String id)async{
    final response = await _api.getProviderById(id);
    return response;
  }
   
}