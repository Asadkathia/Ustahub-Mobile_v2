class ProviderProfieModelClass {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? bio;
  final String? emailVerifiedAt;
  final double? averageRating;
  final bool? isVerified;
  final String? businessName;

  ProviderProfieModelClass({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.bio,
    this.emailVerifiedAt,
    this.averageRating,
    this.isVerified,
    this.businessName,
  });

  factory ProviderProfieModelClass.fromJson(Map<String, dynamic> json) {
    // Handle nested providers object safely
    Map<String, dynamic>? provider;
    if (json['providers'] != null) {
      if (json['providers'] is Map<String, dynamic>) {
        provider = Map<String, dynamic>.from(json['providers']);
      } else if (json['providers'] is List && (json['providers'] as List).isNotEmpty) {
        // Handle case where providers might be a list
        final firstProvider = (json['providers'] as List).first;
        if (firstProvider is Map<String, dynamic>) {
          provider = Map<String, dynamic>.from(firstProvider);
        }
      }
    }

    return ProviderProfieModelClass(
      id: json['id']?.toString(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      averageRating: _parseDouble(
        json['average_rating'] ?? provider?['average_rating'],
      ),
      isVerified: provider?['is_verified'] as bool? ?? false,
      businessName: provider?['business_name'] as String?,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
