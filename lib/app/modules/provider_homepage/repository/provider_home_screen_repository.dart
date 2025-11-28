import 'package:ustahub/network/supabase_api_services.dart';

class ProviderHomeScreenRepository {
  final _apiService = SupabaseApiServices();

  Future<Map<String, dynamic>?> getProviderHomeScreenData() async {
    try {
      final response = await _apiService.getProviderHomeScreenData();
      return response;
    } catch (e) {
      return null;
    }
  }
}

