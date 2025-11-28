class UserProfileModel {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? profilePhotoUrl;
  final String? bio;

  UserProfileModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.profilePhotoUrl,
    this.bio,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      bio: json['bio'] as String?,
    );
  }
}
