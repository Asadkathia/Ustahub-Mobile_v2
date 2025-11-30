import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:ustahub/network/supabase_client.dart';

class SupabaseApiServices {
  final supabase = SupabaseClientService.instance;

  // Helper method to handle Supabase responses
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

  // User Profile Operations
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      final response =
          await supabase
              .from('user_profiles')
              .select()
              .eq('id', userId)
              .single();

      return _handleResponse({'user': response});
    } catch (e) {
      return _handleError(e);
    }
  }

  // Provider Profile - returns format with 'details' key for compatibility
  Future<Map<String, dynamic>> getProviderProfile() async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      final details = await _composeProviderRecord(userId);

      // Return in Laravel-compatible format with 'details' key
      return {
        'statusCode': 200,
        'body': {'status': true, 'details': details},
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      // First, get the current profile to check role
      final currentProfile =
          await supabase
              .from('user_profiles')
              .select('role')
              .eq('id', userId)
              .maybeSingle();

      // Map profile_image to avatar for consistency
      final updateData = Map<String, dynamic>.from(data);
      if (updateData.containsKey('profile_image')) {
        updateData['avatar'] = updateData['profile_image'];
        updateData.remove('profile_image');
      }

      debugPrint('[UPDATE PROFILE] Updating with data: $updateData');
      debugPrint('[UPDATE PROFILE] Avatar URL: ${updateData['avatar']}');

      final response =
          await supabase
              .from('user_profiles')
              .update(updateData)
              .eq('id', userId)
              .select()
              .single();

      debugPrint('[UPDATE PROFILE] Response: ${response['avatar']}');

      // If user is a provider, ensure provider record exists
      final role = data['role'] ?? currentProfile?['role'];
      if (role == 'provider') {
        try {
          // Try to insert provider record (will fail silently if exists due to ON CONFLICT)
          await supabase
              .from('providers')
              .insert({
                'id': userId,
                'business_name': data['name'] ?? currentProfile?['name'] ?? '',
              })
              .select()
              .maybeSingle();
        } catch (e) {
          // If insert fails, try update (record might already exist)
          try {
            await supabase
                .from('providers')
                .update({
                  'business_name':
                      data['name'] ?? currentProfile?['name'] ?? '',
                  'updated_at': DateTime.now().toIso8601String(),
                })
                .eq('id', userId);
          } catch (updateError) {
            debugPrint(
              '[SUPABASE] Provider record update failed: $updateError',
            );
          }
        }
      }

      return _handleResponse({'user': response});
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> upsertProviderDocuments(
    List<Map<String, dynamic>> documents,
  ) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      final sanitized =
          documents
              .where(
                (doc) =>
                    (doc['document_type'] ?? '').toString().isNotEmpty &&
                    (doc['document_image'] ?? doc['document_url']) != null,
              )
              .map(
                (doc) => {
                  'provider_id': userId,
                  'document_type': doc['document_type'],
                  'document_url':
                      doc['document_url'] ?? doc['document_image'] as String,
                  'status': 'pending',
                },
              )
              .toList();

      if (sanitized.isEmpty) {
        return _handleResponse({'message': 'No documents provided'});
      }

      final docTypes =
          sanitized.map((doc) => doc['document_type'] as String).toList();

      final quotedTypes = docTypes
          .map((e) => '"${e.replaceAll('"', '""')}"')
          .join(',');
      await supabase
          .from('provider_documents')
          .delete()
          .eq('provider_id', userId)
          .filter('document_type', 'in', '($quotedTypes)');

      final response =
          await supabase.from('provider_documents').insert(sanitized).select();

      return _handleResponse(response, statusCode: 201);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Address Operations
  Future<Map<String, dynamic>> getAddresses() async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      final response = await supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> addAddress(Map<String, dynamic> data) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      data['user_id'] = userId;

      // Check if user has any addresses
      final existingAddresses = await supabase
          .from('addresses')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      // If this is the first address, set it as default
      if (existingAddresses.isEmpty) {
        data['is_default'] = true;
      } else {
        // If not explicitly set, default to false
        data['is_default'] = data['is_default'] ?? false;
      }

      final response =
          await supabase.from('addresses').insert(data).select().single();

      return _handleResponse(response, statusCode: 201);
    } catch (e) {
      debugPrint('[ADD_ADDRESS] Error: $e');
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateAddress(
    String addressId,
    Map<String, dynamic> data,
  ) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      final response =
          await supabase
              .from('addresses')
              .update(data)
              .eq('id', addressId)
              .eq('user_id', userId)
              .select()
              .single();

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> setDefaultAddress(String addressId) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      // First, set all addresses to non-default
      await supabase
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', userId);

      // Then set the selected address as default
      final response =
          await supabase
              .from('addresses')
              .update({'is_default': true})
              .eq('id', addressId)
              .eq('user_id', userId)
              .select()
              .single();

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Service Operations
  Future<Map<String, dynamic>> getServices() async {
    try {
      final response = await supabase
          .from('services')
          .select()
          .eq('is_active', true)
          .order('name');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('[SUPABASE API] Error getting services: $e');
      return _handleError(e);
    }
  }

  // Provider Operations
  Future<Map<String, dynamic>> getProviders({
    String? serviceId,
    String? searchTerm,
    int? limit,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    double? maxDistance,
    double? latitude,
    double? longitude,
    String? sortBy,
    bool? verifiedOnly,
    bool? availableToday,
  }) async {
    try {
      // Use advanced search if any advanced parameters are provided
      if (minPrice != null ||
          maxPrice != null ||
          minRating != null ||
          maxDistance != null ||
          verifiedOnly == true ||
          availableToday == true ||
          sortBy != null) {
        final response = await supabase.rpc(
          'advanced_search_providers',
          params: {
            if (searchTerm != null && searchTerm.isNotEmpty)
              'p_search_term': searchTerm,
            if (serviceId != null) 'p_service_id': serviceId,
            if (minRating != null) 'p_min_rating': minRating,
            if (minPrice != null) 'p_min_price': minPrice,
            if (maxPrice != null) 'p_max_price': maxPrice,
            if (maxDistance != null) 'p_max_distance_km': maxDistance,
            if (latitude != null) 'p_latitude': latitude,
            if (longitude != null) 'p_longitude': longitude,
            if (verifiedOnly != null) 'p_verified_only': verifiedOnly,
            if (availableToday != null) 'p_available_today': availableToday,
            if (sortBy != null) 'p_sort_by': sortBy,
          },
        );
        return _handleResponse(response);
      }

      // Use simple search for basic queries
      if (limit != null && (searchTerm == null || searchTerm.isEmpty)) {
        final response = await supabase.rpc(
          'get_top_providers',
          params: {
            'p_limit': limit,
            if (serviceId != null) 'p_service_id': serviceId,
          },
        );
        return _handleResponse(response);
      }

      final response = await supabase.rpc(
        'search_providers',
        params: {
          'p_search_term': searchTerm,
          if (serviceId != null) 'p_service_id': serviceId,
        },
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[SUPABASE API] Error getting providers: $e');
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getProviderById(String providerId) async {
    try {
      final response = await _composeProviderRecord(providerId);
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> _composeProviderRecord(String providerId) async {
    try {
      final profile =
          await supabase
              .from('user_profiles')
              .select()
              .eq('id', providerId)
              .single();

      debugPrint(
        '[COMPOSE PROVIDER] Profile fetched: ${profile['name']}, ${profile['id']}',
      );

      final provider =
          await supabase
              .from('providers')
              .select()
              .eq('id', providerId)
              .maybeSingle();

      debugPrint(
        '[COMPOSE PROVIDER] Provider record: ${provider != null ? 'exists' : 'null'}',
      );

      final services = await supabase
          .from('provider_services')
          .select('''
            id,
            provider_id,
            service_id,
            services(*),
            plans(*)
          ''')
          .eq('provider_id', providerId);

      debugPrint('[COMPOSE PROVIDER] Services count: ${services.length}');

      final addresses = await supabase
          .from('addresses')
          .select()
          .eq('user_id', providerId)
          .order('is_default', ascending: false)
          .order('created_at');

      debugPrint('[COMPOSE PROVIDER] Addresses count: ${addresses.length}');

      // If no addresses found, try to get city from most recent booking's address snapshot
      List<Map<String, dynamic>> finalAddresses = List<Map<String, dynamic>>.from(addresses);
      if (finalAddresses.isEmpty) {
        try {
          final recentBooking = await supabase
              .from('bookings')
              .select('address_city, address_full, latitude, longitude')
              .eq('provider_id', providerId)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

          if (recentBooking != null && recentBooking['address_city'] != null) {
            debugPrint('[COMPOSE PROVIDER] Using booking address snapshot: ${recentBooking['address_city']}');
            // Create a synthetic address from booking snapshot
            finalAddresses = [
              {
                'id': null,
                'user_id': providerId,
                'address_line1': recentBooking['address_full'] ?? '',
                'address_line2': null,
                'city': recentBooking['address_city'],
                'state': null,
                'postal_code': null,
                'country': null,
                'latitude': recentBooking['latitude'],
                'longitude': recentBooking['longitude'],
                'is_default': true,
                'created_at': null,
                'updated_at': null,
              }
            ];
          }
        } catch (e) {
          debugPrint('[COMPOSE PROVIDER] Error fetching booking address snapshot: $e');
        }
      }

      final result = {
        ...profile,
        'providers': provider ?? <String, dynamic>{},
        'provider_services': services,
        'addresses': finalAddresses,
      };

      debugPrint('[COMPOSE PROVIDER] Result keys: ${result.keys}');
      debugPrint('[COMPOSE PROVIDER] Result name: ${result['name']}');

      return result;
    } catch (e) {
      debugPrint('[COMPOSE PROVIDER] Error: $e');
      rethrow;
    }
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
      
      // Check if booking exists to mark as verified
      if (data['booking_id'] != null) {
        final booking = await supabase
            .from('bookings')
            .select('id, status')
            .eq('id', data['booking_id'])
            .maybeSingle();
        
        if (booking != null && booking['status'] == 'completed') {
          data['verified_booking'] = true;
        }
      }

      final response =
          await supabase.from('ratings').insert(data).select().single();

      return _handleResponse(response, statusCode: 201);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> voteReviewHelpful(
    String ratingId,
    bool isHelpful,
  ) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      // Upsert vote
      await supabase
          .from('review_helpful_votes')
          .upsert({
            'rating_id': ratingId,
            'user_id': userId,
            'is_helpful': isHelpful,
          });

      return _handleResponse({'message': 'Vote recorded'});
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> respondToReview(
    String ratingId,
    String responseText,
  ) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      // Get rating to verify provider
      final rating = await supabase
          .from('ratings')
          .select('provider_id')
          .eq('id', ratingId)
          .single();

      if (rating['provider_id'] != userId) {
        return _handleError('Unauthorized', statusCode: 403);
      }

      final response = await supabase
          .from('review_responses')
          .upsert({
            'rating_id': ratingId,
            'provider_id': userId,
            'response_text': responseText,
          })
          .select()
          .single();

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getReviewResponses(String providerId) async {
    try {
      final response = await supabase
          .from('review_responses')
          .select('''
            *,
            ratings!inner(id, review, rating, consumer_id)
          ''')
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getReviewsWithFilters(
    String providerId, {
    String? sortBy,
    bool? withPhotos,
    bool? verifiedOnly,
  }) async {
    try {
      var query = supabase
          .from('ratings')
          .select('''
            *,
            user_profiles!ratings_consumer_id_fkey(id, name, avatar),
            review_responses(*)
          ''')
          .eq('provider_id', providerId);

      if (withPhotos == true) {
        query = query.not('image_urls', 'eq', '{}');
      }

      if (verifiedOnly == true) {
        query = query.eq('verified_booking', true);
      }

      // Sort - apply ordering (must be last before execution)
      dynamic finalQuery = query;
      if (sortBy == 'helpful') {
        finalQuery = finalQuery.order('helpful_count', ascending: false);
      } else if (sortBy == 'recent') {
        finalQuery = finalQuery.order('created_at', ascending: false);
      } else {
        finalQuery = finalQuery.order('created_at', ascending: false);
      }

      final response = await finalQuery;
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Banner Operations
  Future<Map<String, dynamic>> getBanners({
    String? city,
    String? country,
  }) async {
    try {
      // Fetch all active banners, then filter by location client-side
      // This allows for fallback to 'all' when location-specific banners aren't available
      final allBanners = await supabase
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('display_order');

      // Filter by location: prefer location-specific, then 'all', then null
      List<dynamic> filteredBanners = allBanners;

      final hasLocation =
          (city != null && city.isNotEmpty) || (country != null && country.isNotEmpty);

      if (hasLocation) {
        filteredBanners = allBanners.where((banner) {
          final bannerCity = banner['city']?.toString().toLowerCase();
          final bannerCountry = banner['country']?.toString().toLowerCase();
          
          // Match if city/country matches, or is 'all', or is null
          final cityMatch = city == null || city.isEmpty || 
              bannerCity == null || 
              bannerCity == 'all' || 
              bannerCity == city.toLowerCase();
          
          final countryMatch = country == null || country.isEmpty || 
              bannerCountry == null || 
              bannerCountry == 'all' || 
              bannerCountry == country.toLowerCase();
          
          return cityMatch && countryMatch;
        }).toList();
        
        // If no location-specific banners found, fallback to 'all' or null
        if (filteredBanners.isEmpty) {
          filteredBanners = allBanners.where((banner) {
            final bannerCity = banner['city']?.toString().toLowerCase();
            final bannerCountry = banner['country']?.toString().toLowerCase();
            return (bannerCity == null || bannerCity == 'all') &&
                   (bannerCountry == null || bannerCountry == 'all');
          }).toList();
        }
      } else {
        // No location info available: only show truly global banners
        filteredBanners = allBanners.where((banner) {
          final bannerCity = banner['city']?.toString().toLowerCase();
          final bannerCountry = banner['country']?.toString().toLowerCase();
          return (bannerCity == null || bannerCity == 'all') &&
                 (bannerCountry == null || bannerCountry == 'all');
        }).toList();
      }

      return _handleResponse(filteredBanners);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getOnboardingSlides({
    String? locale,
    String? audience,
    String? city,
    String? country,
  }) async {
    try {
      // Fetch all active slides, then filter by location and audience client-side
      final allSlides = await supabase
          .from('onboarding_slides')
          .select('*, banners!inner(id, image, title)')
          .eq('is_active', true)
          .order('display_order');

      // Filter by location and audience
      List<dynamic> filteredSlides = allSlides;
      
      if (city != null && city.isNotEmpty || 
          country != null && country.isNotEmpty || 
          audience != null && audience.isNotEmpty) {
        filteredSlides = allSlides.where((slide) {
          final slideCity = slide['city']?.toString().toLowerCase();
          final slideCountry = slide['country']?.toString().toLowerCase();
          final slideAudience = slide['audience']?.toString().toLowerCase();
          
          // Location matching
          final cityMatch = city == null || city.isEmpty || 
              slideCity == null || 
              slideCity == 'all' || 
              slideCity == city.toLowerCase();
          
          final countryMatch = country == null || country.isEmpty || 
              slideCountry == null || 
              slideCountry == 'all' || 
              slideCountry == country.toLowerCase();
          
          // Audience matching
          final audienceMatch = audience == null || audience.isEmpty || 
              slideAudience == 'all' || 
              slideAudience == audience.toLowerCase();
          
          return cityMatch && countryMatch && audienceMatch;
        }).toList();
        
        // If no location-specific slides found, fallback to 'all' or null
        if (filteredSlides.isEmpty) {
          filteredSlides = allSlides.where((slide) {
            final slideCity = slide['city']?.toString().toLowerCase();
            final slideCountry = slide['country']?.toString().toLowerCase();
            final slideAudience = slide['audience']?.toString().toLowerCase();
            
            final locationMatch = (slideCity == null || slideCity == 'all') &&
                                 (slideCountry == null || slideCountry == 'all');
            final audienceMatch = audience == null || audience.isEmpty || 
                slideAudience == 'all' || 
                slideAudience == audience.toLowerCase();
            
            return locationMatch && audienceMatch;
          }).toList();
        }
      }

      return _handleResponse(filteredSlides);
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

  // Provider Documents
  Future<Map<String, dynamic>> getProviderDocuments() async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      final response = await supabase
          .from('provider_documents')
          .select()
          .eq('provider_id', userId)
          .order('created_at', ascending: false);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Provider Home Screen Data
  Future<Map<String, dynamic>> getProviderHomeScreenData() async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      // Get dashboard data - count bookings by status
      final allBookings = await supabase
          .from('bookings')
          .select('status')
          .eq('provider_id', userId);

      int pendingCount = 0;
      int acceptedCount = 0;
      int completedCount = 0;

      for (var booking in allBookings) {
        final status = booking['status'] as String?;
        if (status == 'pending') {
          pendingCount++;
        } else if (status == 'accepted') {
          acceptedCount++;
        } else if (status == 'completed') {
          completedCount++;
        }
      }

      // Get wallet balance
      final walletBalance =
          await supabase
              .from('wallet_balance')
              .select('balance')
              .eq('provider_id', userId)
              .maybeSingle();

      final ratingsQuery = await supabase
          .from('ratings')
          .select('''
            id,
            review,
            rating,
            created_at,
            user_profiles!ratings_consumer_id_fkey(id, name, avatar)
          ''')
          .eq('provider_id', userId)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> formattedRatings = [];
      double ratingSum = 0;

      for (final row in ratingsQuery) {
        // Use 'rating' column (database column name) but map to 'stars' for compatibility
        final ratingValue = row['rating'] ?? row['stars'];
        final stars = (ratingValue is num)
            ? (ratingValue as num).toDouble()
            : double.tryParse(ratingValue?.toString() ?? '0') ?? 0;
        ratingSum += stars;

        final consumerProfile = row['user_profiles'] as Map<String, dynamic>?;
        formattedRatings.add({
          'id': row['id']?.toString(),
          'review': row['review']?.toString() ?? '',
          'stars': stars,
          'consumer': {
            'id': consumerProfile?['id']?.toString() ?? '',
            'name': consumerProfile?['name']?.toString() ?? '',
            'avatar': consumerProfile?['avatar']?.toString(),
            'profile_photo_url': consumerProfile?['avatar']?.toString() ?? '',
          },
        });
      }

      final avgRating =
          formattedRatings.isEmpty ? 0 : ratingSum / formattedRatings.length;

      return _handleResponse({
        'overview': {
          'booking_request': pendingCount,
          'calendar': acceptedCount,
          'completed_bookings': completedCount,
          'wallet_balance': walletBalance?['balance'] ?? 0.0,
        },
        'ratings': {
          'ratingCount': formattedRatings.length,
          'average_rating': avgRating.toStringAsFixed(1),
          'ratings': formattedRatings,
        },
      });
    } catch (e) {
      return _handleError(e);
    }
  }

  // Provider Ratings
  Future<Map<String, dynamic>> getProviderRatings(String providerId) async {
    try {
      final response = await supabase
          .from('ratings')
          .select('''
            *,
            user_profiles!ratings_consumer_id_fkey(
              id,
              name,
              avatar
            )
          ''')
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      return _handleResponse(response);
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

  // Plans
  Future<Map<String, dynamic>> createPlan({
    required String serviceId,
    required String planTitle,
    required num planPrice,
    required List<String> includedService,
    required String planType,
  }) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      // First, get the provider_service_id
      final providerService =
          await supabase
              .from('provider_services')
              .select('id')
              .eq('provider_id', userId)
              .eq('service_id', serviceId)
              .maybeSingle();

      if (providerService == null) {
        return _handleError('Provider service not found', statusCode: 404);
      }

      final response =
          await supabase
              .from('plans')
              .insert({
                'provider_service_id': providerService['id'],
                'title': planTitle,
                'price': planPrice,
                'included_services': includedService,
                'plan_type': planType,
              })
              .select()
              .single();

      return _handleResponse(response, statusCode: 201);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get Plans for Provider
  Future<Map<String, dynamic>> getProviderPlans() async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      final response = await supabase
          .from('plans')
          .select('''
            *,
            provider_services!inner(
              id,
              service_id,
              services(*)
            )
          ''')
          .eq('provider_services.provider_id', userId)
          .order('created_at', ascending: false);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Get Provider Services
  Future<Map<String, dynamic>> getProviderServices() async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      final response = await supabase
          .from('provider_services')
          .select('''
            *,
            services(*)
          ''')
          .eq('provider_id', userId)
          .order('created_at', ascending: false);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Portfolio Operations
  Future<Map<String, dynamic>> getProviderPortfolios(
    String providerId, {
    String? serviceId,
  }) async {
    try {
      var query = supabase
          .from('provider_portfolios')
          .select()
          .eq('provider_id', providerId);

      if (serviceId != null) {
        query = query.eq('service_id', serviceId);
      }

      // Apply ordering after all filters
      final finalQuery = query
          .order('display_order', ascending: true)
          .order('created_at', ascending: false);

      final response = await finalQuery;
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createPortfolio(
    Map<String, dynamic> data,
  ) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      data['provider_id'] = userId;
      final response = await supabase
          .from('provider_portfolios')
          .insert(data)
          .select()
          .single();

      return _handleResponse(response, statusCode: 201);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updatePortfolio(
    String portfolioId,
    Map<String, dynamic> data,
  ) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      final response = await supabase
          .from('provider_portfolios')
          .update(data)
          .eq('id', portfolioId)
          .eq('provider_id', userId)
          .select()
          .single();

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deletePortfolio(String portfolioId) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      await supabase
          .from('provider_portfolios')
          .delete()
          .eq('id', portfolioId)
          .eq('provider_id', userId);

      return _handleResponse({'message': 'Portfolio deleted successfully'});
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> uploadPortfolioMedia(
    String filePath,
    List<int> fileBytes,
    String portfolioId,
  ) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      // Upload to portfolios bucket
      await supabase.storage
          .from('portfolios')
          .uploadBinary('$portfolioId/$filePath', Uint8List.fromList(fileBytes));

      // Get public URL
      final url = supabase.storage
          .from('portfolios')
          .getPublicUrl('$portfolioId/$filePath');

      return _handleResponse({
        'path': '$portfolioId/$filePath',
        'url': url,
      });
    } catch (e) {
      return _handleError(e);
    }
  }

  // Quote Operations
  Future<Map<String, dynamic>> createQuoteRequest(
    Map<String, dynamic> data,
  ) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      data['consumer_id'] = userId;
      if (data['expires_at'] == null) {
        // Default expiry: 7 days from now
        data['expires_at'] = DateTime.now()
            .add(const Duration(days: 7))
            .toIso8601String();
      }

      final response = await supabase
          .from('quote_requests')
          .insert(data)
          .select()
          .single();

      return _handleResponse(response, statusCode: 201);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getQuoteRequests({String? status}) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      var query = supabase
          .from('quote_requests')
          .select('''
            *,
            services(*),
            addresses(*)
          ''')
          .eq('consumer_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      // Apply ordering after all filters
      final finalQuery = query.order('created_at', ascending: false);

      final response = await finalQuery;
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> respondToQuote(
    String quoteRequestId,
    Map<String, dynamic> data,
  ) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      data['provider_id'] = userId;
      data['quote_request_id'] = quoteRequestId;

      final response = await supabase
          .from('quote_responses')
          .insert(data)
          .select()
          .single();

      // Update quote request status
      await supabase
          .from('quote_requests')
          .update({'status': 'responded'})
          .eq('id', quoteRequestId);

      return _handleResponse(response, statusCode: 201);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getQuoteResponses(String quoteRequestId) async {
    try {
      final response = await supabase
          .from('quote_responses')
          .select('''
            *,
            user_profiles!quote_responses_provider_id_fkey(id, name, avatar),
            providers!quote_responses_provider_id_fkey(average_rating, total_ratings)
          ''')
          .eq('quote_request_id', quoteRequestId)
          .order('price', ascending: true);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getServicePriceRange(String serviceId) async {
    try {
      final response = await supabase.rpc(
        'get_service_price_range',
        params: {'p_service_id': serviceId},
      );

      return _handleResponse(response.isNotEmpty ? response[0] : {});
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> compareProviderPrices(
    List<String> providerIds,
    String serviceId,
  ) async {
    try {
      final response = await supabase.rpc(
        'compare_provider_prices',
        params: {
          'p_service_id': serviceId,
          'p_provider_ids': providerIds,
        },
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> acceptQuoteResponse(
    String quoteResponseId,
  ) async {
    try {
      final userId = SupabaseClientService.currentUserId;
      if (userId == null) {
        return _handleError('User not authenticated', statusCode: 401);
      }

      // Get quote response to find quote request
      final quoteResponse = await supabase
          .from('quote_responses')
          .select('quote_request_id')
          .eq('id', quoteResponseId)
          .single();

      // Mark this response as accepted
      await supabase
          .from('quote_responses')
          .update({'is_accepted': true})
          .eq('id', quoteResponseId);

      // Mark all other responses for this request as not accepted
      await supabase
          .from('quote_responses')
          .update({'is_accepted': false})
          .eq('quote_request_id', quoteResponse['quote_request_id'])
          .neq('id', quoteResponseId);

      return _handleResponse({'message': 'Quote accepted successfully'});
    } catch (e) {
      return _handleError(e);
    }
  }
}
