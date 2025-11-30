import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:ustahub/network/supabase_client.dart';

/// Service for booking and related operations
class BookingSupabaseService {
  final supabase = SupabaseClientService.instance;

  // Helper methods
  Map<String, dynamic> _handleResponse(dynamic data, {int statusCode = 200}) {
    return {
      'statusCode': statusCode,
      'body': {'status': true, 'data': data},
    };
  }

  Map<String, dynamic> _handleError(dynamic error, {int statusCode = 400}) {
    return {
      'statusCode': statusCode,
      'body': {'status': false, 'message': error.toString()},
    };
  }

  // Booking Operations
  Future<Map<String, dynamic>> getBookingSlots(
    String providerId,
    String bookingDate,
  ) async {
    try {
      final response = await supabase.rpc(
        'get_booking_slots',
        params: {'p_provider_id': providerId, 'p_booking_date': bookingDate},
      );

      // Transform the response to match TimeSlotModel format
      if (response != null && response is List) {
        final transformedSlots =
            (response as List).map((slot) {
              final timeSlot = slot['time_slot']?.toString() ?? '';
              final isAvailable = slot['is_available'] ?? false;

              // Extract time from TIME type (format: HH:MM:SS)
              String startTime = '';
              if (timeSlot.isNotEmpty) {
                final parts = timeSlot.split(':');
                if (parts.length >= 2) {
                  startTime = '${parts[0]}:${parts[1]}'; // HH:MM format
                }
              }

              return {
                'slot': timeSlot,
                'start_time': startTime,
                'end_time':
                    startTime.isNotEmpty ? _calculateEndTime(startTime) : null,
                'is_booked': !isAvailable,
              };
            }).toList();

        return {
          'statusCode': 200,
          'body': {'status': true, 'data': transformedSlots},
        };
      }

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  String _calculateEndTime(String startTime) {
    try {
      final parts = startTime.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        // Add 1 hour for slot duration
        hour = (hour + 1) % 24;

        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // If parsing fails, return empty string
    }
    return '';
  }

  Future<Map<String, dynamic>> bookService(Map<String, dynamic> data) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      data['consumer_id'] = userId;
      data['status'] = 'pending';
      data['booking_id'] ??=
          'BOOK-${DateTime.now().millisecondsSinceEpoch.toString()}';

      // Calculate totals using database function
      if (data['plan_id'] != null) {
        final totalResponse = await supabase.rpc(
          'calculate_booking_total',
          params: {
            'p_service_id': data['service_id'],
            'p_plan_id': data['plan_id'],
            'p_visiting_charge': data['visiting_charge'] ?? 0,
          },
        );

        if (totalResponse != null && totalResponse.isNotEmpty) {
          data['item_total'] = totalResponse[0]['item_total'];
          data['service_fee'] = totalResponse[0]['service_fee'];
          data['total'] = totalResponse[0]['total'];
        }
      }

      final response =
          await supabase.from('bookings').insert(data).select().single();

      return _handleResponse(response, statusCode: 201);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getBookings({
    String? status,
    List<String>? statuses,
    bool? forProvider,
  }) async {
    return _handleError(
      'Deprecated booking query. Use BookingApiService.listBookings instead.',
      statusCode: 410,
    );
  }

  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    try {
      debugPrint('[GET_BOOKING_DETAILS] Fetching booking: $bookingId');
      
      final response =
          await supabase
              .from('bookings')
              .select('''
        *,
        services(*),
        plans(*),
        booking_address:addresses!bookings_address_id_fkey(*),
        consumer_profile:user_profiles!bookings_consumer_id_fkey(id, name, avatar),
        provider_profile:user_profiles!bookings_provider_id_fkey(id, name, avatar),
        booking_notes(*)
      ''')
              .eq('id', bookingId)
              .single();

      debugPrint('[GET_BOOKING_DETAILS] Raw response: $response');
      debugPrint('[GET_BOOKING_DETAILS] address_id: ${response['address_id']}');
      debugPrint('[GET_BOOKING_DETAILS] booking_address: ${response['booking_address']}');
      debugPrint('[GET_BOOKING_DETAILS] status: ${response['status']}');

      // Transform the response to match expected format
      final Map<String, dynamic> transformed = Map<String, dynamic>.from(
        response,
      );

      // Map consumer profile
      if (response['consumer_profile'] != null) {
        final consumerProfile = response['consumer_profile'];
        transformed['consumer'] = {
          'id': consumerProfile['id']?.toString(),
          'name': consumerProfile['name']?.toString() ?? '',
          'profile_photo_url': consumerProfile['avatar']?.toString() ?? '',
        };
        transformed.remove('consumer_profile');
      }

      // Map provider profile
      if (response['provider_profile'] != null) {
        final providerProfile = response['provider_profile'];
        transformed['provider'] = {
          'id': providerProfile['id']?.toString(),
          'name': providerProfile['name']?.toString() ?? '',
          'profile_photo_url': providerProfile['avatar']?.toString() ?? '',
        };
        transformed.remove('provider_profile');
      }

      // Map address details
      if (response['booking_address'] != null) {
        final address = response['booking_address'];

        // Helper function to safely get string value
        String safeString(dynamic value) {
          if (value == null) return '';
          final str = value.toString().trim();
          return (str == 'null' || str.isEmpty) ? '' : str;
        }

        final addressLine1 = safeString(address['address_line1']);
        final addressLine2 = safeString(address['address_line2']);
        final fullAddress =
            addressLine2.isNotEmpty
                ? '$addressLine1, $addressLine2'
                : addressLine1;

        transformed['address'] = {
          'id': safeString(address['id']),
          'address': fullAddress,
          'address_line1': addressLine1,
          'address_line2': addressLine2,
          'city': safeString(address['city']),
          'state': safeString(address['state']),
          'country': safeString(address['country']),
          'postal_code': safeString(address['postal_code']),
          'latitude': safeString(address['latitude']),
          'longitude': safeString(address['longitude']),
          'is_default': address['is_default'] ?? false,
        };
        transformed.remove('booking_address');
      } else {
        // Set empty address if no address found
        transformed['address'] = {
          'id': '',
          'address': '',
          'address_line1': '',
          'address_line2': '',
          'city': '',
          'state': '',
          'country': '',
          'postal_code': '',
          'latitude': '',
          'longitude': '',
          'is_default': false,
        };
      }
      transformed.remove('booking_address');

      // Map services - handle both array and single object
      if (response['services'] != null) {
        dynamic serviceData = response['services'];
        Map<String, dynamic>? service;

        if (serviceData is List && serviceData.isNotEmpty) {
          service = serviceData[0] as Map<String, dynamic>?;
        } else if (serviceData is Map) {
          service = serviceData as Map<String, dynamic>;
        }

        if (service != null) {
          transformed['service'] = {
            'id': service['id']?.toString() ?? '',
            'name': service['name']?.toString() ?? '',
          };
        }
        transformed.remove('services');
      }

      // Map plans - handle both array and single object
      if (response['plans'] != null) {
        dynamic planData = response['plans'];
        Map<String, dynamic>? plan;

        if (planData is List && planData.isNotEmpty) {
          plan = planData[0] as Map<String, dynamic>?;
        } else if (planData is Map) {
          plan = planData as Map<String, dynamic>;
        }

        if (plan != null) {
          transformed['plan'] = {
            'id': plan['id']?.toString() ?? '',
            'plan_type': plan['plan_type']?.toString() ?? '',
          };
        }
        transformed.remove('plans');
      }

      return _handleResponse(transformed);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Favorite Operations
  Future<Map<String, dynamic>> toggleFavorite(String providerId) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      // Check if already favorited
      final existing =
          await supabase
              .from('favorites')
              .select()
              .eq('consumer_id', userId)
              .eq('provider_id', providerId)
              .maybeSingle();

      if (existing != null) {
        // Remove favorite
        await supabase
            .from('favorites')
            .delete()
            .eq('consumer_id', userId)
            .eq('provider_id', providerId);

        return _handleResponse({'is_favorite': false});
      } else {
        // Add favorite
        await supabase.from('favorites').insert({
          'consumer_id': userId,
          'provider_id': providerId,
        });

        return _handleResponse({'is_favorite': true});
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  // Rating Operations
  Future<Map<String, dynamic>> rateProvider(Map<String, dynamic> data) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      data['consumer_id'] = userId;
      final response =
          await supabase.from('ratings').insert(data).select().single();

      return _handleResponse(response, statusCode: 201);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Booking Notes
  Future<Map<String, dynamic>> getBookingNotes(String bookingId) async {
    try {
      final response = await supabase
          .from('booking_notes')
          .select()
          .eq('booking_id', bookingId)
          .order('created_at', ascending: false);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> addBookingNote({
    required String bookingId,
    required String note,
    List<String>? imageUrls,
  }) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      final response =
          await supabase
              .from('booking_notes')
              .insert({
                'booking_id': bookingId,
                'user_id': userId,
                'note': note,
                'images': imageUrls ?? [],
              })
              .select()
              .single();

      return _handleResponse(response, statusCode: 201);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Edge Function Calls
  Future<Map<String, dynamic>> callEdgeFunction(
    String functionName,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await supabase.functions.invoke(
        functionName,
        body: body,
      );

      return {'statusCode': 200, 'body': response.data ?? response};
    } catch (e) {
      return _handleError(e);
    }
  }

  // FCM Token Operations (via Edge Function)
  Future<Map<String, dynamic>> storeFcmToken(String token) async {
    final deviceType = Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'unknown');
    return callEdgeFunction('fcm-token', {
      'action': 'store',
      'token': token,
      'device_type': deviceType,
    });
  }

  // Booking Workflow (via Edge Function)
  Future<Map<String, dynamic>> bookingAction(
    String action,
    String bookingId, {
    String? remark,
  }) async {
    return callEdgeFunction('booking-actions', {
      'action': action,
      'booking_id': bookingId,
      if (remark != null) 'remark': remark,
    });
  }

  // Wallet Operations (via Edge Function)
  Future<Map<String, dynamic>> walletAction(
    String action, {
    double? amount,
    String? description,
  }) async {
    return callEdgeFunction('wallet', {
      'action': action,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
    });
  }
}

