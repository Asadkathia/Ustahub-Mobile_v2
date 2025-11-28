class ProvidersListModelClass {
  final String? id;
  final String? name;
  final String? email;
  final String? bio;
  final String? avatar;
  final bool? isFavorite;
  final bool? isVerified;
  final double? averageRating;
  final int? totalRatings;
  final List<ProviderServiceTag>? services;

  ProvidersListModelClass({
    this.id,
    this.name,
    this.email,
    this.bio,
    this.avatar,
    this.isFavorite,
    this.isVerified,
    this.averageRating,
    this.totalRatings,
    this.services,
  });

  factory ProvidersListModelClass.fromJson(Map<String, dynamic> json) {
    List<dynamic>? rawServices;
    if (json['services'] is List) {
      rawServices = json['services'] as List;
    } else if (json['provider_services'] is List) {
      rawServices = (json['provider_services'] as List)
          .map((e) => (e as Map<String, dynamic>)['services'])
          .where((e) => e != null)
          .toList();
    }

    return ProvidersListModelClass(
      id: (json['provider_id'] ?? json['id'])?.toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      avatar: json['avatar'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      averageRating: json['average_rating'] is num
          ? (json['average_rating'] as num).toDouble()
          : double.tryParse(json['average_rating']?.toString() ?? ''),
      totalRatings: json['total_ratings'] as int?,
      services: rawServices
          ?.map((e) => ProviderServiceTag.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'provider_id': id,
        'name': name,
        'avatar': avatar,
        'is_favorite': isFavorite,
        'average_rating': averageRating,
        'total_ratings': totalRatings,
        'services': services?.map((e) => e.toJson()).toList(),
      };
}

class ProviderServiceTag {
  final String? id;
  final String? name;

  ProviderServiceTag({
    this.id,
    this.name,
  });

  factory ProviderServiceTag.fromJson(Map<String, dynamic> json) {
    return ProviderServiceTag(
      id: json['id']?.toString(),
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
