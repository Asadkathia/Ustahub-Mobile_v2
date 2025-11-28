import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ustahub/network/supabase_client.dart';

class BookingApiService {
  final SupabaseClient _client = SupabaseClientService.instance;

  Future<Map<String, dynamic>> listBookings({
    required String role,
    required String status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.functions.invoke(
      'booking-list',
      body: {
        'role': role,
        'status': status,
        'page': page,
        'page_size': pageSize,
      },
    );
    return _normalizeResponse(response, defaultStatusCode: 200);
  }

  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    final response = await _client.functions.invoke(
      'booking-detail',
      body: {'id': bookingId},
    );
    return _normalizeResponse(response, defaultStatusCode: 200);
  }

  Future<Map<String, dynamic>> performAction({
    required String action,
    required String bookingId,
    String? remark,
    String? reason,
  }) async {
    final response = await _client.functions.invoke(
      'booking-actions',
      body: {
        'action': action,
        'booking_id': bookingId,
        if (remark != null) 'remark': remark,
        if (reason != null) 'reason': reason,
      },
    );
    return _normalizeResponse(response, defaultStatusCode: 200);
  }

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> payload) async {
    final response = await _client.functions.invoke(
      'booking-create',
      body: payload,
    );
    return _normalizeResponse(response, defaultStatusCode: 201);
  }

  Future<Map<String, dynamic>> sendMessage({
    required String bookingId,
    required String text,
  }) async {
    final response = await _client.functions.invoke(
      'send-message',
      body: {
        'booking_id': bookingId,
        'text': text,
      },
    );
    return _normalizeResponse(response, defaultStatusCode: 200);
  }

  Map<String, dynamic> _normalizeResponse(
    FunctionResponse response, {
    required int defaultStatusCode,
  }) {
    dynamic data = response.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {
        data = {'success': false, 'message': data};
      }
    }

    if (data is! Map<String, dynamic>) {
      data = {'success': false, 'message': 'Invalid response from server'};
    }

    return {
      'statusCode': response.status ?? defaultStatusCode,
      'body': data,
    };
  }
}



