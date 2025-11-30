class PortfolioModel {
  final String? id;
  final String? providerId;
  final String? serviceId;
  final String? title;
  final String? description;
  final DateTime? projectDate;
  final List<String> imageUrls;
  final String? videoUrl;
  final List<String> tags;
  final bool isFeatured;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PortfolioModel({
    this.id,
    this.providerId,
    this.serviceId,
    this.title,
    this.description,
    this.projectDate,
    this.imageUrls = const [],
    this.videoUrl,
    this.tags = const [],
    this.isFeatured = false,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PortfolioModel();

    // Helper to parse date
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    // Helper to parse array
    List<String> parseStringArray(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    return PortfolioModel(
      id: json['id']?.toString(),
      providerId: json['provider_id']?.toString(),
      serviceId: json['service_id']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      projectDate: parseDate(json['project_date']),
      imageUrls: parseStringArray(json['image_urls']),
      videoUrl: json['video_url']?.toString(),
      tags: parseStringArray(json['tags']),
      isFeatured: json['is_featured'] == true,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (serviceId != null) 'service_id': serviceId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (projectDate != null) 'project_date': projectDate!.toIso8601String().split('T')[0],
      'image_urls': imageUrls,
      if (videoUrl != null) 'video_url': videoUrl,
      'tags': tags,
      'is_featured': isFeatured,
      'display_order': displayOrder,
    };
  }

  PortfolioModel copyWith({
    String? id,
    String? providerId,
    String? serviceId,
    String? title,
    String? description,
    DateTime? projectDate,
    List<String>? imageUrls,
    String? videoUrl,
    List<String>? tags,
    bool? isFeatured,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PortfolioModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      title: title ?? this.title,
      description: description ?? this.description,
      projectDate: projectDate ?? this.projectDate,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

