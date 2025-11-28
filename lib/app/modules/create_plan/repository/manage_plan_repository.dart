import 'package:ustahub/network/supabase_api_services.dart';

class ManagePlanRepository {
  final _api = SupabaseApiServices();

  Future<List<dynamic>> getPlans() async {
    final response = await _api.getProviderPlans();
    if (response['statusCode'] == 200 && response['body']['data'] != null) {
      return response['body']['data'] as List;
    }
    return [];
  }
}
