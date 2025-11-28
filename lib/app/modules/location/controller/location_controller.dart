import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ustahub/components/custom_toast.dart';

class LocationController extends GetxController {
  // Google Maps iOS SDK API Key (for Maps SDK, not Geocoding API)
  // Note: This key is for iOS Maps SDK. For Geocoding API, you need a separate key
  // or enable Geocoding API in Google Cloud Console for this key.
  // Currently using native geocoding as primary method (works without API key).
  static const String _googleMapsApiKey =
      'AIzaSyCihk-1twQc1HoRdm_xZrXvz97sFBoV-Y8';

  // Base URLs for Google Maps APIs
  static const String _geocodingBaseUrl =
      'https://maps.googleapis.com/maps/api/geocoding/json';

  // Observable variables for location data
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxString currentAddress = ''.obs;
  final RxString city = ''.obs;
  final RxString state = ''.obs;
  final RxString country = ''.obs;
  final RxString postalCode = ''.obs;
  final RxString street = ''.obs;
  final RxString locality = ''.obs;
  final RxString administrativeArea = ''.obs;
  final RxBool isLocationLoading = false.obs;

  // Test Google Maps API key validity
  Future<bool> testGoogleMapsApiKey() async {
    try {
      print("[LOCATION DEBUG] 🧪 Testing Google Maps API key...");

      // Use a simple known location for testing
      final testUrl =
          'https://maps.googleapis.com/maps/api/geocoding/json?latlng=40.7128,-74.0060&key=$_googleMapsApiKey';
      final response = await http.get(Uri.parse(testUrl));

      print("[LOCATION DEBUG] 🧪 Test Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          print("[LOCATION DEBUG] ✅ Google Maps API key is working!");
          return true;
        } else {
          print("[LOCATION DEBUG] ❌ API Error: ${data['status']}");
          if (data['error_message'] != null) {
            print(
              "[LOCATION DEBUG] 💬 Error Message: ${data['error_message']}",
            );
          }
        }
      } else {
        print("[LOCATION DEBUG] ❌ HTTP Error: ${response.statusCode}");
        String responsePreview =
            response.body.length > 200
                ? '${response.body.substring(0, 200)}...'
                : response.body;
        print("[LOCATION DEBUG] 📄 Response: $responsePreview");
      }
      return false;
    } catch (e) {
      print("[LOCATION DEBUG] ❌ API test exception: $e");
      return false;
    }
  }

  // Check if location services are enabled
  Future<bool> _isLocationServiceEnabled() async {
    print("[LOCATION DEBUG] 🔍 Checking if location services are enabled...");
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("[LOCATION DEBUG] 📍 Location services enabled: $serviceEnabled");

    if (!serviceEnabled) {
      CustomToast.error(
        'Location services are disabled. Please enable location services in your device settings.',
      );
      return false;
    }
    return true;
  }

  // Check and request location permissions
  Future<bool> _checkLocationPermissions() async {
    print("[LOCATION DEBUG] 🔐 Checking location permissions...");
    LocationPermission permission = await Geolocator.checkPermission();
    print("[LOCATION DEBUG] 🔐 Current permission: $permission");

    if (permission == LocationPermission.denied) {
      print("[LOCATION DEBUG] 📱 Requesting location permission...");
      permission = await Geolocator.requestPermission();
      print("[LOCATION DEBUG] 📱 Permission after request: $permission");

      if (permission == LocationPermission.denied) {
        CustomToast.error(
          'Location permissions are required to use this feature. Please grant location access.',
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      CustomToast.error(
        'Location permissions are permanently denied. Please enable location permissions in your device settings for this app.',
      );
      return false;
    }

    print("[LOCATION DEBUG] ✅ Location permissions granted");
    return true;
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      isLocationLoading.value = true;
      print("[LOCATION DEBUG] 🚀 Starting location fetch...");

      // Check if location services are enabled
      if (!await _isLocationServiceEnabled()) {
        return null;
      }

      // Check permissions
      if (!await _checkLocationPermissions()) {
        return null;
      }

      print("[LOCATION DEBUG] 📡 Getting current position...");
      
      // Force fresh location by not using cached position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
          distanceFilter: 0, // Don't filter by distance, get fresh location
        ),
        forceAndroidLocationManager: false,
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;

      print(
        "[LOCATION DEBUG] 📍 Location found: ${position.latitude}, ${position.longitude}",
      );
      print(
        "[LOCATION DEBUG] ⚠️ Note: iOS Simulator uses a fixed location. For real device location, test on a physical device or set custom location in Simulator > Features > Location.",
      );
      return position;
    } catch (e) {
      print("[LOCATION DEBUG] ❌ Error getting location: $e");
      // CustomToast.error('Failed to get current location: ${e.toString()}');
      return null;
    } finally {
      isLocationLoading.value = false;
    }
  }

  // Reverse geocoding with native geocoding (primary) and Google Maps API (fallback) - convert lat/lng to address
  Future<void> getAddressFromCoordinates(double lat, double lng) async {
    try {
      print(
        "[LOCATION DEBUG] 🔄 Converting coordinates to address: $lat, $lng",
      );

      // Use native geocoding as primary (works without API key)
      bool nativeSuccess = await _tryNativeReverseGeocoding(lat, lng);
      
      if (nativeSuccess) {
        return;
      }

      // Fallback to Google Maps API if native fails
      print("[LOCATION DEBUG] 🔄 Falling back to Google Maps API...");
      await _tryGoogleMapsReverseGeocoding(lat, lng);
    } catch (e) {
      print("[LOCATION DEBUG] ❌ Error in reverse geocoding: $e");
      // CustomToast.error('Failed to get address: ${e.toString()}');
    }
  }

  // Try Google Maps reverse geocoding
  Future<bool> _tryGoogleMapsReverseGeocoding(double lat, double lng) async {
    try {
      print("[LOCATION DEBUG] 🌐 Trying Google Maps API...");
      print(
        "[LOCATION DEBUG] 🔑 API Key (first 10 chars): ${_googleMapsApiKey.substring(0, 10)}...",
      );

      // Test if this is a valid Google API key format
      if (!_googleMapsApiKey.startsWith('AIza') ||
          _googleMapsApiKey.length < 30) {
        print("[LOCATION DEBUG] ❌ Invalid API key format detected");
        return false;
      }

      // Construct URL with proper encoding
      final uri = Uri.parse(_geocodingBaseUrl).replace(
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': _googleMapsApiKey,
        },
      );
      print("[LOCATION DEBUG] 🌐 Request URL: $uri");

      // Use Uri.parse to ensure proper encoding
      final response = await http.get(uri);

      print("[LOCATION DEBUG] 📊 Response Status: ${response.statusCode}");
      print("[LOCATION DEBUG] 📊 Response Headers: ${response.headers}");

      // Always print first 500 characters of response for debugging
      String responsePreview =
          response.body.length > 500
              ? '${response.body.substring(0, 500)}...'
              : response.body;
      print("[LOCATION DEBUG] 📊 Response Preview: $responsePreview");

      // Special handling for 404 errors
      if (response.statusCode == 404) {
        print("[LOCATION DEBUG] ❌ 404 Error - API endpoint not found");
        print("[LOCATION DEBUG] 🔍 This usually means:");
        print(
          "[LOCATION DEBUG] 1. The Geocoding API is not enabled in Google Cloud Console",
        );
        print(
          "[LOCATION DEBUG] 2. The API key doesn't have access to Geocoding API",
        );
        print("[LOCATION DEBUG] 3. There might be billing issues");
        print(
          "[LOCATION DEBUG] 4. API key restrictions might be blocking the request",
        );
        print(
          "[LOCATION DEBUG] 📝 To fix: Go to Google Cloud Console > APIs & Services > Enable 'Geocoding API'",
        );

        // Try a simple connectivity test
        try {
          final testResponse = await http.get(
            Uri.parse('https://maps.googleapis.com'),
          );
          print(
            "[LOCATION DEBUG] 🌐 Google Maps connectivity test: ${testResponse.statusCode}",
          );
        } catch (e) {
          print("[LOCATION DEBUG] ❌ Connectivity test failed: $e");
        }
        return false;
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final components = result['address_components'] as List;
          print("[LOCATION DEBUG] 📍 Google Maps Address found: $components");

          // Reset values
          street.value = '';
          locality.value = '';
          city.value = '';
          state.value = '';
          country.value = '';
          postalCode.value = '';
          administrativeArea.value = '';

          // Parse address components
          for (var component in components) {
            final types = component['types'] as List;
            final longName = component['long_name'] as String;

            if (types.contains('street_number')) {
              street.value = '$longName ${street.value}';
            } else if (types.contains('route')) {
              street.value = '${street.value}$longName'.trim();
            } else if (types.contains('sublocality') ||
                types.contains('sublocality_level_1')) {
              locality.value = longName;
            } else if (types.contains('locality')) {
              city.value = longName;
            } else if (types.contains('administrative_area_level_1')) {
              state.value = longName;
              administrativeArea.value = longName;
            } else if (types.contains('country')) {
              country.value = longName;
            } else if (types.contains('postal_code')) {
              postalCode.value = longName;
            }
          }

          // Build full formatted address
          currentAddress.value = result['formatted_address'] ?? '';

          // If street is empty, use formatted address parts
          if (street.value.isEmpty) {
            List<String> addressParts = [];
            if (locality.value.isNotEmpty) addressParts.add(locality.value);
            if (city.value.isNotEmpty) addressParts.add(city.value);
            street.value = addressParts.join(', ');
          }

          print("[LOCATION DEBUG] 🏠 Google Maps Address found:");
          print("[LOCATION DEBUG] 📧 Street: ${street.value}");
          print("[LOCATION DEBUG] 🏘️ Locality: ${locality.value}");
          print("[LOCATION DEBUG] 🏙️ City: ${city.value}");
          print("[LOCATION DEBUG] 🗺️ State: ${state.value}");
          print("[LOCATION DEBUG] 🌍 Country: ${country.value}");
          print("[LOCATION DEBUG] 📮 Postal Code: ${postalCode.value}");
          print("[LOCATION DEBUG] 📍 Full Address: ${currentAddress.value}");

          return true;
        } else {
          print("[LOCATION DEBUG] ❌ Google Maps API Error: ${data['status']}");
          if (data['status'] == 'REQUEST_DENIED') {
            print(
              "[LOCATION DEBUG] 🔑 API Key issue - check if Geocoding API is enabled and billing is set up",
            );
          }
          return false;
        }
      } else {
        print("[LOCATION DEBUG] ❌ HTTP Error: ${response.statusCode}");
        if (response.statusCode == 403) {
          print(
            "[LOCATION DEBUG] 🔑 403 Error - API key might be invalid or restricted",
          );
        }
        return false;
      }
    } catch (e) {
      print("[LOCATION DEBUG] ❌ Google Maps API Exception: $e");
      return false;
    }
  }

  // Native geocoding (primary method - works without API key)
  Future<bool> _tryNativeReverseGeocoding(double lat, double lng) async {
    try {
      print("[LOCATION DEBUG] 📱 Using native geocoding...");

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        print("[LOCATION DEBUG] 📍 Native Placemark found: ${place.toJson()}");

        // Use improved address formatting similar to your reference code
        String formattedAddress = await _formatNativeAddress(
          placemarks,
          lat,
          lng,
        );

        // Extract individual components
        street.value = place.street ?? '';
        locality.value = place.subLocality ?? '';
        city.value = place.locality ?? '';
        state.value = place.administrativeArea ?? '';
        country.value = place.country ?? '';
        postalCode.value = place.postalCode ?? '';
        administrativeArea.value = place.administrativeArea ?? '';

        // Use the formatted address as the main address
        currentAddress.value = formattedAddress;

        // If street is empty, use formatted address parts
        if (street.value.isEmpty) {
          // Get street info from multiple placemarks for better accuracy
          var streets = placemarks.reversed
              .map((placemark) => placemark.street)
              .where((street) => street != null && street.isNotEmpty);

          // Filter out unwanted parts - Plus Codes, city names, etc.
          streets = streets.where(
            (street) => street!.toLowerCase() != place.locality?.toLowerCase(),
          );
          // Filter out Google Plus Codes (format: XXXX+XXX)
          streets = streets.where(
            (street) =>
                !RegExp(r'^[A-Z0-9]{4}\+[A-Z0-9]{2,3}$').hasMatch(street!),
          );
          // Filter out any codes with + symbol
          streets = streets.where((street) => !street!.contains('+'));

          if (streets.isNotEmpty) {
            street.value = streets.join(', ');
          } else {
            // Fallback: try to build street from other address components
            List<String> fallbackParts = [];

            // Try thoroughfare (main street name) if available
            if (place.thoroughfare != null &&
                place.thoroughfare!.isNotEmpty &&
                !place.thoroughfare!.contains('+') &&
                !RegExp(
                  r'^[A-Z0-9]{4}\+[A-Z0-9]{2,3}$',
                ).hasMatch(place.thoroughfare!)) {
              fallbackParts.add(place.thoroughfare!);
            }

            // Add subThoroughfare (street number) if available
            if (place.subThoroughfare != null &&
                place.subThoroughfare!.isNotEmpty &&
                !place.subThoroughfare!.contains('+')) {
              fallbackParts.insert(0, place.subThoroughfare!);
            }

            // If we still don't have a good street, use locality
            if (fallbackParts.isEmpty) {
              if (locality.value.isNotEmpty) fallbackParts.add(locality.value);
              if (city.value.isNotEmpty &&
                  !fallbackParts.contains(city.value)) {
                fallbackParts.add(city.value);
              }
            }

            street.value = fallbackParts.join(', ');
          }
        } else {
          // Check if the existing street value is a Plus Code and replace it
          if (RegExp(r'^[A-Z0-9]{4}\+[A-Z0-9]{2,3}$').hasMatch(street.value) ||
              street.value.contains('+')) {
            print(
              "[LOCATION DEBUG] 🚫 Detected Plus Code in street: ${street.value}, replacing...",
            );

            List<String> replacementParts = [];

            // Try thoroughfare and subThoroughfare
            if (place.thoroughfare != null &&
                place.thoroughfare!.isNotEmpty &&
                !place.thoroughfare!.contains('+') &&
                !RegExp(
                  r'^[A-Z0-9]{4}\+[A-Z0-9]{2,3}$',
                ).hasMatch(place.thoroughfare!)) {
              replacementParts.add(place.thoroughfare!);
            }

            if (place.subThoroughfare != null &&
                place.subThoroughfare!.isNotEmpty &&
                !place.subThoroughfare!.contains('+')) {
              replacementParts.insert(0, place.subThoroughfare!);
            }

            // Fallback to locality and city
            if (replacementParts.isEmpty) {
              if (locality.value.isNotEmpty) {
                replacementParts.add(locality.value);
              }
              if (city.value.isNotEmpty) replacementParts.add(city.value);
            }

            street.value = replacementParts.join(', ');
          }
        }

        print("[LOCATION DEBUG] 🏠 Native Address found:");
        print("[LOCATION DEBUG] 📧 Street: ${street.value}");
        print("[LOCATION DEBUG] 🏘️ Locality: ${locality.value}");
        print("[LOCATION DEBUG] 🏙️ City: ${city.value}");
        print("[LOCATION DEBUG] 🗺️ State: ${state.value}");
        print("[LOCATION DEBUG] 🌍 Country: ${country.value}");
        print("[LOCATION DEBUG] 📮 Postal Code: ${postalCode.value}");
        print("[LOCATION DEBUG] 📍 Full Address: ${currentAddress.value}");
        return true;
      } else {
        print("[LOCATION DEBUG] ❌ No address found for coordinates");
        // CustomToast.error('Could not get address from location');
        return false;
      }
    } catch (e) {
      print("[LOCATION DEBUG] ❌ Error in native reverse geocoding: $e");
      // CustomToast.error('Failed to get address: ${e.toString()}');
      return false;
    }
  }

  // Format native address similar to your reference code
  Future<String> _formatNativeAddress(
    List<Placemark> placemarks,
    double lat,
    double lng,
  ) async {
    try {
      var address = '';

      if (placemarks.isNotEmpty) {
        final lastPlacemark = placemarks.reversed.last;

        // Concatenate non-null street components
        var streets = placemarks.reversed
            .map((placemark) => placemark.street)
            .where((street) => street != null && street.isNotEmpty);

        // Filter out unwanted parts
        streets = streets.where(
          (street) =>
              street!.toLowerCase() != lastPlacemark.locality?.toLowerCase(),
        );
        // Filter out Google Plus Codes (format: XXXX+XXX)
        streets = streets.where(
          (street) =>
              !RegExp(r'^[A-Z0-9]{4}\+[A-Z0-9]{2,3}$').hasMatch(street!),
        );
        // Filter out any codes with + symbol
        streets = streets.where((street) => !street!.contains('+'));

        if (streets.isNotEmpty) {
          address += streets.join(', ');
        }

        // Add other address components with proper formatting
        final components = [
          lastPlacemark.subLocality,
          lastPlacemark.locality,
          lastPlacemark.subAdministrativeArea,
          lastPlacemark.administrativeArea,
          lastPlacemark.postalCode,
          lastPlacemark.country,
        ];

        for (final component in components) {
          if (component != null && component.isNotEmpty) {
            if (address.isNotEmpty) {
              address += ', ';
            }
            address += component;
          }
        }

        // Clean up any double commas or leading commas
        address = address.replaceAll(', ,', ',').replaceAll(',,', ',');
        if (address.startsWith(', ')) {
          address = address.substring(2);
        }
      }

      print("[LOCATION DEBUG] 🎯 Formatted address for ($lat, $lng): $address");

      return address.isNotEmpty ? address : "No Address Found";
    } catch (e) {
      print("[LOCATION DEBUG] ❌ Error formatting address: $e");
      return "No Address Found";
    }
  }

  // Forward geocoding with Google Maps API and native fallback - convert address to lat/lng
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      print("[LOCATION DEBUG] 🔍 Converting address to coordinates: $address");

      // First try Google Maps API
      Position? googleResult = await _tryGoogleMapsForwardGeocoding(address);

      if (googleResult != null) {
        return googleResult;
      }

      // Fallback to native geocoding
      print("[LOCATION DEBUG] 🔄 Falling back to native geocoding...");
      return await _tryNativeForwardGeocoding(address);
    } catch (e) {
      print("[LOCATION DEBUG] ❌ Error in forward geocoding: $e");
      // CustomToast.error('Failed to get coordinates: ${e.toString()}');
      return null;
    }
  }

  // Try Google Maps forward geocoding
  Future<Position?> _tryGoogleMapsForwardGeocoding(String address) async {
    try {
      print("[LOCATION DEBUG] 🌐 Trying Google Maps forward geocoding...");

      // Construct URI properly to avoid encoding issues
      final uri = Uri.parse(_geocodingBaseUrl).replace(
        queryParameters: {'address': address, 'key': _googleMapsApiKey},
      );

      print("[LOCATION DEBUG] 🌐 API URI: $uri");

      final response = await http.get(uri);

      print("[LOCATION DEBUG] 📊 Response Status: ${response.statusCode}");
      print("[LOCATION DEBUG] 📊 Response Headers: ${response.headers}");

      // Only print response body if it's not HTML (to avoid spam)
      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        print("[LOCATION DEBUG] 📊 Response Body: ${response.body}");
      } else {
        print(
          "[LOCATION DEBUG] 📊 Response Body Type: ${response.headers['content-type']}",
        );
        print(
          "[LOCATION DEBUG] 📊 Response Body Length: ${response.body.length}",
        );
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final geometry = result['geometry'];
          final location = geometry['location'];

          final lat = location['lat'] as double;
          final lng = location['lng'] as double;

          latitude.value = lat;
          longitude.value = lng;

          print(
            "[LOCATION DEBUG] 📍 Google Maps Coordinates found: $lat, $lng",
          );

          return Position(
            latitude: lat,
            longitude: lng,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        } else {
          print("[LOCATION DEBUG] ❌ Google Maps API Error: ${data['status']}");
          if (data['status'] == 'REQUEST_DENIED') {
            print(
              "[LOCATION DEBUG] 🔑 API Key issue - check if Geocoding API is enabled and billing is set up",
            );
          }
          return null;
        }
      } else {
        print("[LOCATION DEBUG] ❌ HTTP Error: ${response.statusCode}");
        if (response.statusCode == 403) {
          print(
            "[LOCATION DEBUG] 🔑 403 Error - API key might be invalid or restricted",
          );
        }
        return null;
      }
    } catch (e) {
      print("[LOCATION DEBUG] ❌ Google Maps forward geocoding exception: $e");
      return null;
    }
  }

  // Native forward geocoding fallback
  Future<Position?> _tryNativeForwardGeocoding(String address) async {
    try {
      print("[LOCATION DEBUG] 📱 Using native forward geocoding...");

      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location location = locations[0];

        latitude.value = location.latitude;
        longitude.value = location.longitude;

        print(
          "[LOCATION DEBUG] 📍 Native Coordinates found: ${location.latitude}, ${location.longitude}",
        );

        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      } else {
        print("[LOCATION DEBUG] ❌ No coordinates found for address");
        // CustomToast.error('Could not find location for this address');
        return null;
      }
    } catch (e) {
      print("[LOCATION DEBUG] ❌ Error in native forward geocoding: $e");
      // CustomToast.error('Failed to get coordinates: ${e.toString()}');
      return null;
    }
  }

  // Get current location and address in one call
  Future<bool> getCurrentLocationAndAddress() async {
    try {
      print("[LOCATION DEBUG] 🚀 Getting current location and address...");

      Position? position = await getCurrentLocation();
      if (position != null) {
        await getAddressFromCoordinates(position.latitude, position.longitude);
        // CustomToast.success('Location fetched successfully!');
        return true;
      }
      return false;
    } catch (e) {
      print("[LOCATION DEBUG] ❌ Error getting location and address: $e");
      // CustomToast.error('Failed to get location and address');
      return false;
    }
  }

  // Clear all location data
  void clearLocationData() {
    print("[LOCATION DEBUG] 🧹 Clearing location data...");
    latitude.value = 0.0;
    longitude.value = 0.0;
    currentAddress.value = '';
    city.value = '';
    state.value = '';
    country.value = '';
    postalCode.value = '';
    street.value = '';
  }

  // Get location summary for display
  String getLocationSummary() {
    if (currentAddress.value.isNotEmpty) {
      return currentAddress.value;
    } else if (city.value.isNotEmpty && state.value.isNotEmpty) {
      return '${city.value}, ${state.value}';
    } else if (latitude.value != 0.0 && longitude.value != 0.0) {
      return '${latitude.value.toStringAsFixed(6)}, ${longitude.value.toStringAsFixed(6)}';
    } else {
      return 'No location selected';
    }
  }

  // Check if location data is available
  bool get hasLocationData => latitude.value != 0.0 && longitude.value != 0.0;

  // Get coordinates as a map
  Map<String, double> get coordinates => {
    'latitude': latitude.value,
    'longitude': longitude.value,
  };

  // Get address components as a map
  Map<String, String> get addressComponents => {
    'street': street.value,
    'city': city.value,
    'state': state.value,
    'country': country.value,
    'postalCode': postalCode.value,
    'fullAddress': currentAddress.value,
  };

  @override
  void onInit() {
    super.onInit();
    print("[LOCATION DEBUG] 🎯 Location Controller initialized");
  }

  @override
  void onClose() {
    clearLocationData();
    super.onClose();
    print("[LOCATION DEBUG] 👋 Location Controller disposed");
  }
}
