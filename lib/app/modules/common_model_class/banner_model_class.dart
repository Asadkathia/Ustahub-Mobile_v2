class BannerResponse {
  bool? status;
  List<BannerModelClass>? banners;

  BannerResponse({this.status, this.banners});

  BannerResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['banners'] != null) {
      banners = <BannerModelClass>[];
      json['banners'].forEach((v) {
        banners!.add(BannerModelClass.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (banners != null) {
      data['banners'] = banners!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BannerModelClass {
  String? id;
  String? userType;
  String? userId;
  String? image;
  String? createdAt;
  String? updatedAt;

  BannerModelClass({
    this.id,
    this.userType,
    this.userId,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  BannerModelClass.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    userType = json['user_type']?.toString();
    userId = json['user_id']?.toString();
    image = json['image']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_type'] = userType;
    data['user_id'] = userId;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
