import 'package:ustahub/network/supabase_api_services.dart';

class BookingSummaryRepository {
  final _api = SupabaseApiServices();

  Future<dynamic> bookService(Map<String, dynamic> data) async {
    // Use Supabase to create booking
    final response = await _api.bookService(data);
    return response;
  }
}
