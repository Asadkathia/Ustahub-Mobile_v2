class QuoteRequestModel {
  final String? id;
  final String? consumerId;
  final String? serviceId;
  final String? addressId;
  final String? description;
  final DateTime? preferredDate;
  final String? status;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? service;
  final Map<String, dynamic>? address;

  QuoteRequestModel({
    this.id,
    this.consumerId,
    this.serviceId,
    this.addressId,
    this.description,
    this.preferredDate,
    this.status,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.service,
    this.address,
  });

  factory QuoteRequestModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return QuoteRequestModel();

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return QuoteRequestModel(
      id: json['id']?.toString(),
      consumerId: json['consumer_id']?.toString(),
      serviceId: json['service_id']?.toString(),
      addressId: json['address_id']?.toString(),
      description: json['description']?.toString(),
      preferredDate: parseDate(json['preferred_date']),
      status: json['status']?.toString(),
      expiresAt: parseDate(json['expires_at']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      service: json['services'] is Map
          ? json['services'] as Map<String, dynamic>
          : null,
      address: json['addresses'] is Map
          ? json['addresses'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (serviceId != null) 'service_id': serviceId,
      if (addressId != null) 'address_id': addressId,
      if (description != null) 'description': description,
      if (preferredDate != null)
        'preferred_date': preferredDate!.toIso8601String().split('T')[0],
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }
}

class QuoteResponseModel {
  final String? id;
  final String? quoteRequestId;
  final String? providerId;
  final double price;
  final String? description;
  final String? estimatedDuration;
  final bool isAccepted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? provider;
  final Map<String, dynamic>? providerStats;

  QuoteResponseModel({
    this.id,
    this.quoteRequestId,
    this.providerId,
    required this.price,
    this.description,
    this.estimatedDuration,
    this.isAccepted = false,
    this.createdAt,
    this.updatedAt,
    this.provider,
    this.providerStats,
  });

  factory QuoteResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return QuoteResponseModel(price: 0.0);

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return QuoteResponseModel(
      id: json['id']?.toString(),
      quoteRequestId: json['quote_request_id']?.toString(),
      providerId: json['provider_id']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString(),
      estimatedDuration: json['estimated_duration']?.toString(),
      isAccepted: json['is_accepted'] == true,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      provider: json['user_profiles'] is Map
          ? json['user_profiles'] as Map<String, dynamic>
          : null,
      providerStats: json['providers'] is Map
          ? json['providers'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (quoteRequestId != null) 'quote_request_id': quoteRequestId,
      'price': price,
      if (description != null) 'description': description,
      if (estimatedDuration != null) 'estimated_duration': estimatedDuration,
    };
  }
}

class PriceRangeModel {
  final double? minPrice;
  final double? maxPrice;
  final double? avgPrice;

  PriceRangeModel({
    this.minPrice,
    this.maxPrice,
    this.avgPrice,
  });

  factory PriceRangeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PriceRangeModel();

    return PriceRangeModel(
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      avgPrice: (json['avg_price'] as num?)?.toDouble(),
    );
  }
}

class ProviderPriceComparisonModel {
  final String? providerId;
  final String? providerName;
  final String? providerAvatar;
  final double? minPrice;
  final double? maxPrice;
  final double? avgPrice;
  final int planCount;
  final double? averageRating;
  final int totalRatings;

  ProviderPriceComparisonModel({
    this.providerId,
    this.providerName,
    this.providerAvatar,
    this.minPrice,
    this.maxPrice,
    this.avgPrice,
    this.planCount = 0,
    this.averageRating,
    this.totalRatings = 0,
  });

  factory ProviderPriceComparisonModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProviderPriceComparisonModel();

    return ProviderPriceComparisonModel(
      providerId: json['provider_id']?.toString(),
      providerName: json['provider_name']?.toString(),
      providerAvatar: json['provider_avatar']?.toString(),
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      avgPrice: (json['avg_price'] as num?)?.toDouble(),
      planCount: (json['plan_count'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      totalRatings: (json['total_ratings'] as num?)?.toInt() ?? 0,
    );
  }
}

