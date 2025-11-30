import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:ustahub/network/supabase_client.dart';

/// Service for user profile and related operations
class UserSupabaseService {
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

  // Provider Documents
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

      // Get monthly KPIs
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfMonthStr = startOfMonth.toIso8601String();

      // Monthly bookings count
      final monthlyBookings = await supabase
          .from('bookings')
          .select('id')
          .eq('provider_id', userId)
          .gte('created_at', startOfMonthStr);
      final monthlyBookingsCount = monthlyBookings.length;

      // Monthly earnings - sum of total_amount from completed bookings this month
      final monthlyEarningsData = await supabase
          .from('bookings')
          .select('total')
          .eq('provider_id', userId)
          .eq('status', 'completed')
          .gte('created_at', startOfMonthStr);
      
      double monthlyEarnings = 0.0;
      for (var booking in monthlyEarningsData) {
        final total = booking['total'];
        if (total != null) {
          if (total is num) {
            monthlyEarnings += total.toDouble();
          } else {
            monthlyEarnings += double.tryParse(total.toString()) ?? 0.0;
          }
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
          'monthly_bookings': monthlyBookingsCount,
          'monthly_earnings': monthlyEarnings,
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

  // Helper method for composing provider record
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
}

