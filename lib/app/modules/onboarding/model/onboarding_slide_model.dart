class OnboardingSlideModel {
  final String id;
  final String? bannerId;
  final String? title;
  final String? subtitle;
  final String? description;
  final String? locale;
  final String audience;
  final String? ctaText;
  final String? ctaRoute;
  final String? imageOverride;
  final bool isActive;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? bannerImage;

  const OnboardingSlideModel({
    required this.id,
    this.bannerId,
    this.title,
    this.subtitle,
    this.description,
    this.locale,
    this.audience = 'all',
    this.ctaText,
    this.ctaRoute,
    this.imageOverride,
    this.isActive = true,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
    this.bannerImage,
  });

  factory OnboardingSlideModel.fromJson(Map<String, dynamic> json) {
    final bannerJson = json['banners'] ?? json['banner'] ?? {};
    return OnboardingSlideModel(
      id: json['id']?.toString() ?? '',
      bannerId: json['banner_id']?.toString(),
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      description: json['description']?.toString(),
      locale: json['locale']?.toString(),
      audience: json['audience']?.toString() ?? 'all',
      ctaText: json['cta_text']?.toString(),
      ctaRoute: json['cta_route']?.toString(),
      imageOverride: json['image_override']?.toString(),
      isActive: json['is_active'] == null
          ? true
          : json['is_active'] == true || json['is_active'].toString() == 'true',
      displayOrder: json['display_order'] is int
          ? json['display_order']
          : int.tryParse(json['display_order']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      bannerImage: bannerJson['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'banner_id': bannerId,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'locale': locale,
      'audience': audience,
      'cta_text': ctaText,
      'cta_route': ctaRoute,
      'image_override': imageOverride,
      'is_active': isActive,
      'display_order': displayOrder,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'banners': {
        'image': bannerImage,
      },
    };
  }

  String? get resolvedImage {
    if (imageOverride != null && imageOverride!.isNotEmpty) {
      return imageOverride;
    }
    if (bannerImage != null && bannerImage!.isNotEmpty) {
      return bannerImage;
    }
    return null;
  }
}

