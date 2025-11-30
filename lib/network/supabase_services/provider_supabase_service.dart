import 'package:flutter/foundation.dart';
import 'package:ustahub/network/supabase_client.dart';

/// Service for provider listing and search operations
class ProviderSupabaseService {
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
  }) async {
    try {
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
}

