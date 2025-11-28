class ProviderRatingsResponse {
  final bool status;
  final List<ProviderRating> ratings;

  ProviderRatingsResponse({required this.status, required this.ratings});

  factory ProviderRatingsResponse.fromJson(Map<String, dynamic> json) {
    return ProviderRatingsResponse(
      status: json['status'] ?? false,
      ratings:
          (json['ratings'] as List<dynamic>?)
              ?.map(
                (rating) =>
                    ProviderRating.fromJson(rating as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'ratings': ratings.map((rating) => rating.toJson()).toList(),
    };
  }
}

class ProviderRating {
  final String id;
  final String userId;
  final String providerId;
  final int stars;
  final String review;
  final String? image;
  final String createdAt;
  final String updatedAt;
  final RatingConsumer consumer;

  ProviderRating({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.stars,
    required this.review,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.consumer,
  });

  factory ProviderRating.fromJson(Map<String, dynamic> json) {
    // Supabase `ratings` table uses `rating` column (DECIMAL), but older code expected `stars`.
    final dynamic ratingValue = json['stars'] ?? json['rating'];
    
    // Handle both int and double/decimal ratings
    int starsInt = 0;
    if (ratingValue is num) {
      starsInt = ratingValue.round();
    } else if (ratingValue != null) {
      // Try parsing as double first, then int
      final double? ratingDouble = double.tryParse(ratingValue.toString());
      starsInt = ratingDouble?.round() ?? 0;
    }

    // Join alias in the select is `user_profiles!ratings_consumer_id_fkey`
    // which comes through as `user_profiles`, not `consumer`.
    final dynamic consumerJson = json['consumer'] ?? json['user_profiles'] ?? {};

    return ProviderRating(
      id: json['id']?.toString() ?? '',
      userId: json['consumer_id']?.toString() ??
          json['user_id']?.toString() ??
          '',
      providerId: json['provider_id']?.toString() ?? '',
      stars: starsInt,
      review: json['review']?.toString() ?? '',
      image: json['image']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      consumer: RatingConsumer.fromJson(
        consumerJson is Map<String, dynamic> ? consumerJson : <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'provider_id': providerId,
      'stars': stars,
      'review': review,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'consumer': consumer.toJson(),
    };
  }

  // Helper method for formatted date
  String get formattedDate {
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  // Helper method for star rating as double
  double get starRating => stars.toDouble();
}

class RatingConsumer {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? emailVerifiedAt;
  final String? twoFactorConfirmedAt;
  final String? currentTeamId;
  final String? profilePhotoPath;
  final String createdAt;
  final String updatedAt;
  final String? googleId;
  final String? avatar;
  final String profilePhotoUrl;

  RatingConsumer({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.emailVerifiedAt,
    this.twoFactorConfirmedAt,
    this.currentTeamId,
    this.profilePhotoPath,
    required this.createdAt,
    required this.updatedAt,
    this.googleId,
    this.avatar,
    required this.profilePhotoUrl,
  });

  factory RatingConsumer.fromJson(Map<String, dynamic> json) {
    // API only selects (id, name, avatar) from user_profiles, so other fields will be null
    return RatingConsumer(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      twoFactorConfirmedAt: json['two_factor_confirmed_at']?.toString(),
      currentTeamId: json['current_team_id']?.toString(),
      profilePhotoPath: json['profile_photo_path']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      googleId: json['google_id']?.toString(),
      avatar: json['avatar']?.toString(),
      profilePhotoUrl: json['profile_photo_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'email_verified_at': emailVerifiedAt,
      'two_factor_confirmed_at': twoFactorConfirmedAt,
      'current_team_id': currentTeamId,
      'profile_photo_path': profilePhotoPath,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'google_id': googleId,
      'avatar': avatar,
      'profile_photo_url': profilePhotoUrl,
    };
  }

  // Get the best available image URL
  String get imageUrl {
    if (avatar != null && avatar!.isNotEmpty) {
      return avatar!;
    }
    return profilePhotoUrl;
  }
}
