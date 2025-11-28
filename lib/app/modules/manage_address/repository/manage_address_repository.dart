import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/network/supabase_api_services.dart';
import 'package:ustahub/network/supabase_client.dart';

class ManageAddressRepository {
  final _api = SupabaseApiServices();

  Future<dynamic> addAddress({
    required Map<String, dynamic> addressData,
    required String role, // 'consumer' or 'provider'
  }
  )async{
    final response = await _api.addAddress(addressData);
    return response;
  }


Future<dynamic> getAddresses(String role) async {
    final response = await _api.getAddresses();
    return response;
  }


Future<dynamic> updateAddress({
  required String addressId,
  required Map<String, dynamic> addressData,
  required String role, // 'consumer' or 'provider'


})async{
  final response = await _api.updateAddress(addressId.toString(), addressData);
  return response;
}


Future<dynamic> deleteAddress({
    required String addressId,
    required String role, // 'consumer' or 'provider'
  }) async {
    // Note: SupabaseApiServices doesn't have deleteAddress yet, using direct Supabase call
    try {
      final supabase = SupabaseClientService.instance;
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return {
          'statusCode': 401,
          'body': {'status': false, 'message': 'User not authenticated'}
        };
      }
      
      await supabase
          .from('addresses')
          .delete()
          .eq('id', addressId)
          .eq('user_id', userId);
      
      return {
        'statusCode': 200,
        'body': {'status': true, 'message': 'Address deleted successfully'}
      };
    } catch (e) {
      return {
        'statusCode': 400,
        'body': {'status': false, 'message': e.toString()}
      };
    }
  }

  Future<dynamic> setDefaultAddress({
    required String addressId,
    required String role, // 'consumer' or 'provider'
  }) async {
    final response = await _api.setDefaultAddress(addressId.toString());
    return response;
  }
}