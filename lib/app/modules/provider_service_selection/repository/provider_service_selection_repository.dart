import 'package:ustahub/network/supabase_api_services.dart';
import 'package:ustahub/network/supabase_client.dart';

class ProviderServiceSelectionRepository {
  final _api = SupabaseApiServices();

  Future<dynamic> getServiceCategories() async {
    // Services are public, no auth required
    final response = await _api.getServices();
    
    // Transform to match expected format
    if (response['statusCode'] == 200 && response['body']['data'] != null) {
      return {
        'statusCode': 200,
        'body': {
          'status': true,
          'services': response['body']['data'],
        },
      };
    }
    return response;
  }

  Future<dynamic> addService(Map<String, dynamic> data) async {
    // Add service to provider_services table
    final supabase = SupabaseClientService.instance;
    final userId = SupabaseClientService.currentUserId;
    
    if (userId == null) {
      return {
        'statusCode': 401,
        'body': {'status': false, 'message': 'Not authenticated'},
      };
    }

    try {
      final serviceIds = data['service_id'] as List;
      final List<Map<String, dynamic>> inserts = serviceIds.map((id) => {
        'provider_id': userId,
        'service_id': id.toString(),
      }).toList();

      await supabase.from('provider_services').insert(inserts);

      return {
        'statusCode': 200,
        'body': {'status': true, 'message': 'Services added successfully'},
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'body': {'status': false, 'message': 'Failed to add services: $e'},
      };
    }
  }

  Future<dynamic> getMyServices() async {
    final supabase = SupabaseClientService.instance;
    final userId = SupabaseClientService.currentUserId;
    
    if (userId == null) {
      return {
        'statusCode': 401,
        'body': {'status': false, 'message': 'Not authenticated'},
      };
    }

    try {
      final response = await supabase
          .from('provider_services')
          .select('''
            *,
            services(*)
          ''')
          .eq('provider_id', userId);

      return {
        'statusCode': 200,
        'body': {
          'status': true,
          'services': response,
        },
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'body': {'status': false, 'message': 'Failed to fetch services: $e'},
      };
    }
  }
}