import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:ustahub/network/supabase_client.dart';
import 'package:ustahub/network/supabase_services/user_supabase_service.dart';
import 'package:ustahub/network/supabase_services/provider_supabase_service.dart';
import 'package:ustahub/network/supabase_services/booking_supabase_service.dart';

/// Facade class that delegates to specialized services
/// Maintains backward compatibility with existing code
class SupabaseApiServices {
  final supabase = SupabaseClientService.instance;
  
  // Specialized services
  final _userService = UserSupabaseService();
  final _providerService = ProviderSupabaseService();
  final _bookingService = BookingSupabaseService();

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

  // User Profile Operations - Delegated to UserSupabaseService
  Future<Map<String, dynamic>> getProfile() async {
    return _userService.getProfile();
  }

  Future<Map<String, dynamic>> getProviderProfile() async {
    return _userService.getProviderProfile();
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return _userService.updateProfile(data);
  }

  Future<Map<String, dynamic>> upsertProviderDocuments(
    List<Map<String, dynamic>> documents,
  ) async {
    return _userService.upsertProviderDocuments(documents);
  }

  // Address Operations - Delegated to UserSupabaseService
  Future<Map<String, dynamic>> getAddresses() async {
    return _userService.getAddresses();
  }

  Future<Map<String, dynamic>> addAddress(Map<String, dynamic> data) async {
    return _userService.addAddress(data);
  }

  Future<Map<String, dynamic>> updateAddress(
    String addressId,
    Map<String, dynamic> data,
  ) async {
    return _userService.updateAddress(addressId, data);
  }

  Future<Map<String, dynamic>> setDefaultAddress(String addressId) async {
    return _userService.setDefaultAddress(addressId);
  }

  // Service Operations - Delegated to ProviderSupabaseService
  Future<Map<String, dynamic>> getServices() async {
    return _providerService.getServices();
  }

  // Provider Operations - Delegated to ProviderSupabaseService
  Future<Map<String, dynamic>> getProviders({
    String? serviceId,
    String? searchTerm,
    int? limit,
  }) async {
    return _providerService.getProviders(
      serviceId: serviceId,
      searchTerm: searchTerm,
      limit: limit,
    );
  }

  Future<Map<String, dynamic>> getProviderById(String providerId) async {
    return _providerService.getProviderById(providerId);
  }

  // Keep _composeProviderRecord for backward compatibility (deprecated)
  @Deprecated('Use ProviderSupabaseService.getProviderById instead')
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

  // Booking Operations - Delegated to BookingSupabaseService
  Future<Map<String, dynamic>> getBookingSlots(
    String providerId,
    String bookingDate,
  ) async {
    return _bookingService.getBookingSlots(providerId, bookingDate);
  }

  Future<Map<String, dynamic>> bookService(Map<String, dynamic> data) async {
    return _bookingService.bookService(data);
  }

  Future<Map<String, dynamic>> getBookings({
    String? status,
    List<String>? statuses,
    bool? forProvider,
  }) async {
    return _bookingService.getBookings(
      status: status,
      statuses: statuses,
      forProvider: forProvider,
    );
  }

  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    return _bookingService.getBookingDetails(bookingId);
  }

  // Favorite Operations - Delegated to BookingSupabaseService
  Future<Map<String, dynamic>> toggleFavorite(String providerId) async {
    return _bookingService.toggleFavorite(providerId);
  }

  // Rating Operations - Delegated to BookingSupabaseService
  Future<Map<String, dynamic>> rateProvider(Map<String, dynamic> data) async {
    return _bookingService.rateProvider(data);
  }

  // Banner Operations - Delegated to ProviderSupabaseService
  Future<Map<String, dynamic>> getBanners({
    String? city,
    String? country,
  }) async {
    return _providerService.getBanners(city: city, country: country);
  }

  Future<Map<String, dynamic>> getOnboardingSlides({
    String? locale,
    String? audience,
    String? city,
    String? country,
  }) async {
    return _providerService.getOnboardingSlides(
      locale: locale,
      audience: audience,
      city: city,
      country: country,
    );
  }

  // Edge Function Calls - Delegated to BookingSupabaseService
  Future<Map<String, dynamic>> callEdgeFunction(
    String functionName,
    Map<String, dynamic> body,
  ) async {
    return _bookingService.callEdgeFunction(functionName, body);
  }

  // FCM Token Operations - Delegated to BookingSupabaseService
  Future<Map<String, dynamic>> storeFcmToken(String token) async {
    return _bookingService.storeFcmToken(token);
  }

  // Booking Workflow - Delegated to BookingSupabaseService
  Future<Map<String, dynamic>> bookingAction(
    String action,
    String bookingId, {
    String? remark,
  }) async {
    return _bookingService.bookingAction(action, bookingId, remark: remark);
  }

  // Wallet Operations - Delegated to BookingSupabaseService
  Future<Map<String, dynamic>> walletAction(
    String action, {
    double? amount,
    String? description,
  }) async {
    return _bookingService.walletAction(
      action,
      amount: amount,
      description: description,
    );
  }

  // Provider Documents - Delegated to UserSupabaseService
  Future<Map<String, dynamic>> getProviderDocuments() async {
    return _userService.getProviderDocuments();
  }

  // Provider Home Screen Data - Delegated to UserSupabaseService
  Future<Map<String, dynamic>> getProviderHomeScreenData() async {
    return _userService.getProviderHomeScreenData();
  }

  // Provider Ratings - Delegated to UserSupabaseService
  Future<Map<String, dynamic>> getProviderRatings(String providerId) async {
    return _userService.getProviderRatings(providerId);
  }

  // Booking Notes - Delegated to BookingSupabaseService
  Future<Map<String, dynamic>> getBookingNotes(String bookingId) async {
    return _bookingService.getBookingNotes(bookingId);
  }

  Future<Map<String, dynamic>> addBookingNote({
    required String bookingId,
    required String note,
    List<String>? imageUrls,
  }) async {
    return _bookingService.addBookingNote(
      bookingId: bookingId,
      note: note,
      imageUrls: imageUrls,
    );
  }

  // Plans - Delegated to UserSupabaseService
  Future<Map<String, dynamic>> createPlan({
    required String serviceId,
    required String planTitle,
    required num planPrice,
    required List<String> includedService,
    required String planType,
  }) async {
    return _userService.createPlan(
      serviceId: serviceId,
      planTitle: planTitle,
      planPrice: planPrice,
      includedService: includedService,
      planType: planType,
    );
  }

  // Get Plans for Provider - Delegated to UserSupabaseService
  Future<Map<String, dynamic>> getProviderPlans() async {
    return _userService.getProviderPlans();
  }

  // Get Provider Services - Delegated to UserSupabaseService
  Future<Map<String, dynamic>> getProviderServices() async {
    return _userService.getProviderServices();
  }
}
