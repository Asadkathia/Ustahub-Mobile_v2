class ProviderHomeScreenResponse {
  final bool status;
  final String message;
  final ProviderHomeScreenData data;

  ProviderHomeScreenResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProviderHomeScreenResponse.fromJson(Map<String, dynamic> json) {
    return ProviderHomeScreenResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ProviderHomeScreenData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data.toJson()};
  }
}

class ProviderHomeScreenData {
  final ProviderOverview overview;
  final ProviderRatingsData ratings;

  ProviderHomeScreenData({required this.overview, required this.ratings});

  factory ProviderHomeScreenData.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('pending_bookings')) {
      final overviewJson = {
        'booking_request': json['pending_bookings'] ?? 0,
        'calendar': json['accepted_bookings'] ?? 0,
      };
      final ratingsJson = {
        'ratingCount': json['completed_bookings'] ?? 0,
        'ratings': json['ratings'] ?? [],
        'average_rating': (json['wallet_balance'] ?? 0).toString(),
      };
      return ProviderHomeScreenData(
        overview: ProviderOverview.fromJson(overviewJson),
        ratings: ProviderRatingsData.fromJson(ratingsJson),
      );
    }

    return ProviderHomeScreenData(
      overview: ProviderOverview.fromJson(json['overview'] ?? {}),
      ratings: ProviderRatingsData.fromJson(json['ratings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'overview': overview.toJson(), 'ratings': ratings.toJson()};
  }
}

class ProviderOverview {
  final int bookingRequest;
  final int calendar;
  final int monthlyBookings;
  final double monthlyEarnings;

  ProviderOverview({
    required this.bookingRequest,
    required this.calendar,
    this.monthlyBookings = 0,
    this.monthlyEarnings = 0.0,
  });

  factory ProviderOverview.fromJson(Map<String, dynamic> json) {
    return ProviderOverview(
      bookingRequest:
          json['booking_request'] ?? json['pending_bookings'] ?? 0,
      calendar: json['calendar'] ?? json['accepted_bookings'] ?? 0,
      monthlyBookings: json['monthly_bookings'] ?? 0,
      monthlyEarnings: (json['monthly_earnings'] is num)
          ? (json['monthly_earnings'] as num).toDouble()
          : double.tryParse(json['monthly_earnings']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_request': bookingRequest,
      'calendar': calendar,
      'monthly_bookings': monthlyBookings,
      'monthly_earnings': monthlyEarnings,
    };
  }
}

class ProviderRatingsData {
  final int ratingCount;
  final List<ProviderHomeRating> ratings;
  final String averageRating;

  ProviderRatingsData({
    required this.ratingCount,
    required this.ratings,
    required this.averageRating,
  });

  factory ProviderRatingsData.fromJson(Map<String, dynamic> json) {
    return ProviderRatingsData(
      ratingCount: json['ratingCount'] ??
          json['ratings_count'] ??
          json['completed_bookings'] ??
          0,
      ratings:
          (json['ratings'] as List<dynamic>?)
              ?.map(
                (rating) =>
                    ProviderHomeRating.fromJson(rating as Map<String, dynamic>),
              )
              .toList() ??
          [],
      averageRating: json['average_rating'] ??
          (json['wallet_balance']?.toString()) ??
          '0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ratingCount': ratingCount,
      'ratings': ratings.map((rating) => rating.toJson()).toList(),
      'average_rating': averageRating,
    };
  }
}

class ProviderHomeRating {
  final String id;
  final String review;
  final String? image;
  final int stars;
  final String userId;
  final RatingConsumer consumer;

  ProviderHomeRating({
    required this.id,
    required this.review,
    this.image,
    required this.stars,
    required this.userId,
    required this.consumer,
  });

  factory ProviderHomeRating.fromJson(Map<String, dynamic> json) {
    return ProviderHomeRating(
      id: json['id']?.toString() ?? '',
      review: json['review']?.toString() ?? '',
      image: json['image']?.toString(),
      stars: int.tryParse(json['stars']?.toString() ?? '0') ?? 0,
      userId: json['user_id']?.toString() ?? '',
      consumer: RatingConsumer.fromJson(json['consumer'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'review': review,
      'image': image,
      'stars': stars,
      'user_id': userId,
      'consumer': consumer.toJson(),
    };
  }
}

class RatingConsumer {
  final String id;
  final String name;
  final String? avatar;
  final String profilePhotoUrl;

  RatingConsumer({
    required this.id,
    required this.name,
    this.avatar,
    required this.profilePhotoUrl,
  });

  factory RatingConsumer.fromJson(Map<String, dynamic> json) {
    return RatingConsumer(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      profilePhotoUrl: json['profile_photo_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'profile_photo_url': profilePhotoUrl,
    };
  }
}
