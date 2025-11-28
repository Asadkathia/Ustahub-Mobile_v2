import 'package:flutter/foundation.dart';
import 'package:ustahub/network/booking_api_service.dart';

class ProviderCompletedBookingRepository {
  final BookingApiService _bookingApi = BookingApiService();

  Future<Map<String, dynamic>> bookingDetails(String bookingId) async {
    return _getBookingDetails(bookingId);
  }

  Future<Map<String, dynamic>> _getBookingDetails(String bookingId) async {
    try {
      final response = await _bookingApi.getBookingDetails(bookingId);
      final body = response['body'] as Map<String, dynamic>? ?? {};

      if (body['success'] == true && body['data'] != null) {
        final mapped = _mapDetailToLegacy(body['data'] as Map<String, dynamic>);
        return {
          'statusCode': 200,
          'body': {
            'status': true,
            'data': mapped,
          },
        };
      }

      return {
        'statusCode': response['statusCode'] ?? 500,
        'body': {
          'status': false,
          'message': body['message'] ?? 'Failed to load booking details',
        },
      };
    } catch (e) {
      debugPrint('[BOOKING_REPO] Error fetching booking: $e');
      return _error(e.toString());
    }
  }

  Map<String, dynamic> _mapDetailToLegacy(Map<String, dynamic> data) {
    final booking = data['booking'] as Map<String, dynamic>? ?? {};
    final consumer = data['consumer'] as Map<String, dynamic>? ?? {};
    final provider = data['provider'] as Map<String, dynamic>? ?? {};
    final service = data['service'] as Map<String, dynamic>? ?? {};
    final address = data['address'] as Map<String, dynamic>? ?? {};
    final plan = service['plan'] as Map<String, dynamic>?;
    final charges = service['charges'] as Map<String, dynamic>? ?? {};

    return {
      'id': booking['id'],
      'booking_id': booking['bookingNumber'],
      'consumer_id': consumer['id'],
      'provider_id': provider['id'],
      'service_id': service['id'],
      'plan_id': plan?['id'],
      'address_id': address['id'],
      'booking_date': booking['bookingDate'],
      'booking_time': booking['bookingTime'],
      'note': booking['note'],
      'status': booking['status'],
      'remark': booking['remark'],
      'visiting_charge': booking['visitingCharge'],
      'service_fee': charges['serviceFee'],
      'item_total': charges['itemTotal'],
      'item_discount': charges['itemDiscount'],
      'total': charges['total'],
      'created_at': booking['createdAt'],
      'updated_at': booking['updatedAt'],
      'consumer': {
        'id': consumer['id'],
        'name': consumer['name'],
        'profile_photo_url': consumer['avatar'],
        'phone': consumer['phone'],
      },
      'provider': {
        'id': provider['id'],
        'name': provider['name'],
        'profile_photo_url': provider['avatar'],
        'phone': provider['phone'],
      },
      'address': {
        'id': address['id'],
        'address': address['full'],
        'city': address['city'],
        'state': address['state'],
        'country': null,
        'postal_code': address['postalCode'],
        'latitude': address['latitude']?.toString(),
        'longitude': address['longitude']?.toString(),
      },
      'service': {
        'id': service['id'],
        'name': service['name'],
        'image': service['image'],
      },
      'plan': plan != null
          ? {
              'id': plan['id'],
              'plan_title': plan['name'],
              'plan_price': plan['price']?.toString(),
            }
          : null,
      'booking_payment': {
        'item_total': charges['itemTotal'],
        'visiting_charge': booking['visitingCharge'],
        'discount': charges['itemDiscount'],
        'service_fee': charges['serviceFee'],
        'total': charges['total'],
      },
      'permissions': data['permissions'],
    };
  }

  Future<Map<String, dynamic>> startWork(Map<String, dynamic> data) async {
    final bookingId = data['booking_id']?.toString() ?? data['id']?.toString();
    if (bookingId == null) {
      return _error('Booking ID is required');
    }
    return _performAction('start', bookingId);
  }

  Future<Map<String, dynamic>> completeBooings(Map<String, dynamic> data) async {
    final bookingId = data['booking_id']?.toString() ?? data['id']?.toString();
    if (bookingId == null) {
      return _error('Booking ID is required');
    }
    return _performAction('complete', bookingId, remark: data['remark']?.toString());
  }

  Future<Map<String, dynamic>> _performAction(
    String action,
    String bookingId, {
    String? remark,
  }) async {
    try {
      final response = await _bookingApi.performAction(
        action: action,
        bookingId: bookingId,
        remark: remark,
      );
      final body = response['body'] as Map<String, dynamic>? ?? {};

      if (body['success'] == true) {
      return {
          'statusCode': 200,
          'body': {
            'success': true,
            'message': body['message'],
            'data': body['data'],
          },
      };
    }
    
      return _error(body['message'] ?? 'Failed to perform action');
    } catch (e) {
      debugPrint('[BOOKING_REPO] Action error: $e');
      return _error(e.toString());
  }
  }

  Map<String, dynamic> _error(String message) {
    return {
      'statusCode': 400,
      'body': {
        'status': false,
        'message': message,
      },
    };
  }
}

