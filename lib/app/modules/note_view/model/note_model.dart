import 'dart:convert';

class NotesResponse {
  final List<NoteModel> data;

  NotesResponse({required this.data});

  factory NotesResponse.fromJson(Map<String, dynamic> json) {
    return NotesResponse(
      data:
          (json['data'] as List<dynamic>)
              .map((item) => NoteModel.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.map((note) => note.toJson()).toList()};
  }
}

class NoteUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? googleId;
  final String? appleId;
  final String? bio;
  final String? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool? isFavorite;
  final String? averageRating;
  final String? twoFactorConfirmedAt;
  final String? currentTeamId;
  final String? profilePhotoPath;
  final String? profilePhotoUrl;

  NoteUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.googleId,
    this.appleId,
    this.bio,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite,
    this.averageRating,
    this.twoFactorConfirmedAt,
    this.currentTeamId,
    this.profilePhotoPath,
    this.profilePhotoUrl,
  });

  factory NoteUser.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return NoteUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      googleId: json['google_id']?.toString(),
      appleId: json['apple_id']?.toString(),
      bio: json['bio']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      isFavorite: json['is_favorite'] == true,
      averageRating: json['average_rating']?.toString(),
      twoFactorConfirmedAt: json['two_factor_confirmed_at']?.toString(),
      currentTeamId: json['current_team_id']?.toString(),
      profilePhotoPath: json['profile_photo_path']?.toString(),
      profilePhotoUrl: json['profile_photo_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'google_id': googleId,
      'apple_id': appleId,
      'bio': bio,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_favorite': isFavorite,
      'average_rating': averageRating,
      'two_factor_confirmed_at': twoFactorConfirmedAt,
      'current_team_id': currentTeamId,
      'profile_photo_path': profilePhotoPath,
      'profile_photo_url': profilePhotoUrl,
    };
  }

  // Get display avatar (prioritize avatar, fallback to profilePhotoUrl)
  String? get displayAvatar => avatar ?? profilePhotoUrl;
}

class NoteModel {
  final String id;
  final String bookingId;
  final String userType;
  final String userId;
  final String note;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NoteUser user;

  NoteModel({
    required this.id,
    required this.bookingId,
    required this.userType,
    required this.userId,
    required this.note,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    // Parse images from JSON string to List<String>
    List<String> imagesList = [];
    try {
      if (json['images'] is String) {
        final imagesJson = json['images'] as String;
        if (imagesJson.isNotEmpty && imagesJson != '[]') {
          final decoded = jsonDecode(imagesJson);
          if (decoded is List) {
            imagesList = decoded.cast<String>();
          }
        }
      } else if (json['images'] is List) {
        imagesList = (json['images'] as List).cast<String>();
      }
    } catch (e) {
      print('Error parsing images: $e');
      imagesList = [];
    }

    return NoteModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      userType: json['user_type']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      images: imagesList,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      user: NoteUser.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_type': userType,
      'user_id': userId,
      'note': note,
      'images': jsonEncode(images),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user.toJson(),
    };
  }

  // Helper method to get formatted date
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = months[createdAt.month - 1];
    final day = createdAt.day;
    final year = createdAt.year;
    final hour =
        createdAt.hour > 12
            ? createdAt.hour - 12
            : createdAt.hour == 0
            ? 12
            : createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';

    return 'Created $month $day, $year $hour:$minute $period';
  }

  // Helper method to check if note has images
  bool get hasImages => images.isNotEmpty;

  // Copy with method for immutable updates
  NoteModel copyWith({
    String? id,
    String? bookingId,
    String? userType,
    String? userId,
    String? note,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    NoteUser? user,
  }) {
    return NoteModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      userType: userType ?? this.userType,
      userId: userId ?? this.userId,
      note: note ?? this.note,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}
