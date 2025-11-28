class RateProviderRequest {
  final String providerId;
  final int stars;
  final String review;

  RateProviderRequest({
    required this.providerId,
    required this.stars,
    required this.review,
  });

  Map<String, dynamic> toJson() {
    return {'provider_id': providerId, 'stars': stars, 'review': review};
  }
}

class RateProviderResponse {
  final bool status;
  final String message;
  final RatingData? data;

  RateProviderResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory RateProviderResponse.fromJson(Map<String, dynamic> json) {
    return RateProviderResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? RatingData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data?.toJson()};
  }
}

class RatingData {
  final String? id;
  final String? providerId;
  final String? consumerId;
  final String? stars;
  final String? review;
  final String? createdAt;
  final String? updatedAt;

  RatingData({
    this.id,
    this.providerId,
    this.consumerId,
    this.stars,
    this.review,
    this.createdAt,
    this.updatedAt,
  });

  factory RatingData.fromJson(Map<String, dynamic> json) {
    return RatingData(
      id: json['id']?.toString(),
      providerId: json['provider_id']?.toString(),
      consumerId: json['consumer_id']?.toString(),
      stars: json['stars']?.toString(),
      review: json['review']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'consumer_id': consumerId,
      'stars': stars,
      'review': review,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
