import 'package:ustahub/network/supabase_api_services.dart';

class HomepageRepository {
  final _apiService = SupabaseApiServices();

  Future<dynamic> favouriteToggle({required String id}) async {
    final response = await _apiService.toggleFavorite(id);
    return response;
  }
}
