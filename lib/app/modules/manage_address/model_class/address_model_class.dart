class AddressModelClass {
  String? id;
  String? userId;
  double? latitude;
  double? longitude;
  String? addressLine1;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  bool? isDefault;
  String? createdAt;
  String? updatedAt;

  AddressModelClass({
    this.id,
    this.userId,
    this.latitude,
    this.longitude,
    this.addressLine1,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  AddressModelClass.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    userId = json['user_id']?.toString();
    latitude = _parseDouble(json['latitude']);
    longitude = _parseDouble(json['longitude']);
    addressLine1 = json['address_line1'] ?? json['address'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    postalCode = json['postal_code']?.toString();
    isDefault = json['is_default'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
