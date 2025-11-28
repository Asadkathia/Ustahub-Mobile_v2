import 'package:ustahub/network/supabase_api_services.dart';

class LoginRepository {
  final _api = SupabaseApiServices();

  // Send OTP to email using Supabase Edge Function
  Future<dynamic> sendOtpToEmail(String email, String role) async {
    try {
      final response = await _api.callEdgeFunction('otp-auth', {
        'action': 'send',
        'email': email,
        'role': role,
      });
      
      // Transform response to match expected format
      if (response['statusCode'] == 200) {
        return {
          'statusCode': 200,
          'body': {
            'status': true,
            'message': response['body']['message'] ?? 'OTP sent successfully',
            'email': email,
          },
        };
      }
      return response;
    } catch (e) {
      return {
        'statusCode': 500,
        'body': {
          'status': false,
          'message': 'Failed to send OTP: $e',
        },
      };
    }
  }

  // Verify OTP using Supabase Edge Function
  Future<dynamic> emailLogin(Map<String, dynamic> data, String role) async {
    try {
      final response = await _api.callEdgeFunction('otp-auth', {
        'action': 'verify',
        'email': data['email'],
        'otp': data['otp'],
        'role': role,
      });
      
      // Transform response to match expected format
      if (response['statusCode'] == 200 && response['body']['success'] == true) {
        final body = response['body'];
        
        // Return user info - session will be created in OTP controller
        // The Edge Function has already created/verified the user
        return {
          'statusCode': 200,
          'body': {
            'status': true,
            'success': true,
            'isRegister': body['isRegister'] ?? false,
            'user_id': body['user_id'],
            'email': body['email'],
            'role': body['role'],
            'temp_password': body['temp_password'], // Temporary password for immediate sign-in
            'access_token': 'supabase_session', // Will be handled by Supabase client
            'message': 'OTP verified successfully',
          },
        };
      }
      
      return response;
    } catch (e) {
      return {
        'statusCode': 500,
        'body': {
          'status': false,
          'message': 'Failed to verify OTP: $e',
        },
      };
    }
  }
}
