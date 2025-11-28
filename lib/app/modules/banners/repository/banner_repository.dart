import 'package:ustahub/network/supabase_api_services.dart';

class BannerRepository {
  final _api = SupabaseApiServices();

  Future<dynamic> getBanners({
    String? city,
    String? country,
  }) async {
    // Banners are public, no auth required
    final response = await _api.getBanners(
      city: city,
      country: country,
    );
    return response;
  }
}
