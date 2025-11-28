import 'package:flutter/foundation.dart';

class ProviderDetailsModelClass {
  final ProviderModel? provider;
  final Overview? overview;

  ProviderDetailsModelClass({
    this.provider,
    this.overview,
  });

  factory ProviderDetailsModelClass.fromJson(Map<String, dynamic> json) {
    final providerRow = json['providers'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['providers'] as Map)
        : <String, dynamic>{};

    final services = (json['provider_services'] as List?)
            ?.map((record) =>
                Service.fromSupabase(Map<String, dynamic>.from(record as Map)))
            .toList() ??
        <Service>[];

    final addresses = (json['addresses'] as List?)
            ?.map(
              (address) =>
                  Address.fromSupabase(Map<String, dynamic>.from(address as Map)),
            )
            .toList() ??
        <Address>[];

    final provider = ProviderModel.fromSupabaseRecord(
      profile: json,
      providerRow: providerRow,
      services: services,
      addresses: addresses,
    );

    return ProviderDetailsModelClass(
      provider: provider,
      overview: Overview.fromSupabase(
        profile: json,
        providerRow: providerRow,
        addresses: addresses,
      ),
    );
  }
}

class ProviderModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? bio;
  final bool? isVerified;
  final bool? isFavorite;
  final String? businessName;
  final String? averageRating;
  final List<Service> services;
  final List<Plan> plans;
  final List<Address> addresses;

  ProviderModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.bio,
    this.isVerified,
    this.isFavorite,
    this.businessName,
    this.averageRating,
    this.services = const [],
    this.plans = const [],
    this.addresses = const [],
  });

  factory ProviderModel.fromSupabaseRecord({
    required Map<String, dynamic> profile,
    required Map<String, dynamic> providerRow,
    required List<Service> services,
    required List<Address> addresses,
  }) {
    // Get name from profile, with fallbacks
    final name = profile['name'] as String? ?? 
                 profile['email'] as String? ?? 
                 providerRow['business_name'] as String? ??
                 'Provider';
    
    return ProviderModel(
      id: profile['id']?.toString(),
      name: name,
      email: profile['email'] as String?,
      phone: profile['phone'] as String?,
      avatar: profile['avatar'] as String?,
      bio: providerRow['bio'] as String? ?? profile['bio'] as String?,
      businessName: providerRow['business_name'] as String?,
      isVerified:
          providerRow['is_verified'] as bool? ?? profile['is_verified'] as bool? ?? false,
      isFavorite: providerRow['is_favorite'] as bool? ?? false,
      averageRating:
          (providerRow['average_rating'] ?? profile['average_rating'])?.toString() ?? '0.0',
      services: services,
      plans: services.expand((s) => s.plans ?? const <Plan>[]).toList(),
      addresses: addresses,
    );
  }
}

class Service {
  final String? id;
  final String? name;
  final Pivot? pivot;
  final List<Plan>? plans;

  Service({this.id, this.name, this.pivot, this.plans});

  factory Service.fromSupabase(Map<String, dynamic> record) {
    final serviceData = record['services'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(record['services'] as Map)
        : const <String, dynamic>{};

    final serviceId =
        record['service_id']?.toString() ?? serviceData['id']?.toString();

    final plansData =
        (record['plans'] as List?)
                ?.map((plan) => Map<String, dynamic>.from(plan as Map))
                .toList() ??
            [];

    final plans = plansData
        .map(
          (plan) => Plan.fromSupabase(
            plan,
            providerServiceId: record['id']?.toString(),
            serviceId: serviceId,
          ),
        )
        .toList();

    return Service(
      id: serviceId,
      name: serviceData['name'] as String?,
      pivot: Pivot(
        providerId: record['provider_id']?.toString(),
        serviceId: serviceId,
      ),
      plans: plans,
    );
  }
}

class Pivot {
  final String? providerId;
  final String? serviceId;

  Pivot({this.providerId, this.serviceId});
}

class Plan {
  final String? id;
  final String? serviceId;
  final String? providerServiceId;
  final String? planType;
  final String? planTitle;
  final String? planPrice;
  final List<String>? includedService;
  final String? description;

  Plan({
    this.id,
    this.serviceId,
    this.providerServiceId,
    this.planType,
    this.planTitle,
    this.planPrice,
    this.includedService,
    this.description,
  });

  factory Plan.fromSupabase(
    Map<String, dynamic> json, {
    String? serviceId,
    String? providerServiceId,
  }) {
    final features = json['features'];
    List<String>? included = features is List
        ? features.map((e) => e.toString()).toList()
        : null;

    return Plan(
      id: json['id']?.toString(),
      serviceId: serviceId ?? json['service_id']?.toString(),
      providerServiceId:
          providerServiceId ?? json['provider_service_id']?.toString(),
      planType: json['plan_type'] as String?,
      planTitle:
          json['plan_title'] as String? ?? json['plan_type'] as String?,
      planPrice: json['plan_price']?.toString(),
      includedService: included,
      description: json['description'] as String?,
    );
  }
}

class Address {
  final String? id;
  final String? userId;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final bool? isDefault;
  final double? latitude;
  final double? longitude;

  Address({
    this.id,
    this.userId,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.isDefault,
    this.latitude,
    this.longitude,
  });

  factory Address.fromSupabase(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      addressLine1: json['address_line1'] as String?,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postal_code'] as String?,
      isDefault: json['is_default'] as bool?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }
}

class Overview {
  final String? registeredSince;
  final int? totalBookings;
  final String? city;
  final String? backgroundCheckStatus;

  Overview({
    this.registeredSince,
    this.totalBookings,
    this.city,
    this.backgroundCheckStatus,
  });

  factory Overview.fromSupabase({
    required Map<String, dynamic> profile,
    required Map<String, dynamic> providerRow,
    List<Address> addresses = const [],
  }) {
    final dynamic createdAtValue =
        providerRow['created_at'] ?? profile['created_at'];
    final DateTime? createdAt = createdAtValue is String
        ? DateTime.tryParse(createdAtValue)
        : createdAtValue is DateTime
            ? createdAtValue
            : null;

    // Get background check status from provider row
    final String? bgCheckStatus = providerRow['background_check_status'] as String?;
    
    // Format background check status for display
    String? formattedBgCheck;
    if (bgCheckStatus != null && bgCheckStatus.isNotEmpty) {
      // Capitalize first letter
      formattedBgCheck = bgCheckStatus[0].toUpperCase() + 
                         (bgCheckStatus.length > 1 ? bgCheckStatus.substring(1) : '');
    }

    // Use completed_bookings for "Times hired" as it represents actual completed work
    final int completedBookings = providerRow['completed_bookings'] as int? ?? 0;
    final int totalBookings = providerRow['total_bookings'] as int? ?? 0;
    
    debugPrint('[OVERVIEW] completed_bookings: $completedBookings, total_bookings: $totalBookings');
    debugPrint('[OVERVIEW] addresses count: ${addresses.length}');
    
    // Get city from addresses - try default first, then any address
    String? city;
    if (addresses.isNotEmpty) {
      final defaultAddress = addresses.firstWhere(
        (addr) => addr.isDefault == true,
        orElse: () => addresses.first,
      );
      city = defaultAddress.city;
      debugPrint('[OVERVIEW] Found city: $city from address: ${defaultAddress.addressLine1}');
    } else {
      debugPrint('[OVERVIEW] No addresses found for provider');
    }

    return Overview(
      registeredSince: _humanizeSince(createdAt),
      totalBookings: completedBookings,
      city: city,
      backgroundCheckStatus: formattedBgCheck ?? 'Not verified',
    );
  }

  static String? _humanizeSince(DateTime? date) {
    if (date == null) return null;
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays >= 365) {
      final years = diff.inDays ~/ 365;
      return '$years year${years > 1 ? 's' : ''} ago';
    }
    if (diff.inDays >= 30) {
      final months = diff.inDays ~/ 30;
      return '$months month${months > 1 ? 's' : ''} ago';
    }
    if (diff.inDays >= 7) {
      final weeks = diff.inDays ~/ 7;
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    }
    if (diff.inDays >= 1) {
      final days = diff.inDays;
      return '$days day${days > 1 ? 's' : ''} ago';
    }
    if (diff.inHours >= 1) {
      final hours = diff.inHours;
      return '$hours hour${hours > 1 ? 's' : ''} ago';
    }
    final minutes = diff.inMinutes;
    return minutes <= 1 ? 'just now' : '$minutes minutes ago';
  }
}