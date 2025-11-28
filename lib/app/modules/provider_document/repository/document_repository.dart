import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';

class DocumentRepository {
  final _api = SupabaseApiServices();

  Future<dynamic> getDocuments() async {
    try {
      final response = await _api.getProviderDocuments();
      return response;
    } catch (e) {
      print('Error in getDocuments repository: $e');
      throw Exception('Failed to fetch documents: $e');
    }
  }
}
