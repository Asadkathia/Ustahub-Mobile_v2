import '../../../export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class ServiceSelectionForPlanRepository {
  final _api = SupabaseApiServices();

  Future<dynamic> getMyServices() async {
    try {
      final response = await _api.getProviderServices();
      return response;
    } catch (e) {
      throw Exception("Failed to load services: $e");
    }
  }
}
