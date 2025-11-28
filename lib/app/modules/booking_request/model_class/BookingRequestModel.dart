class BookingRequestModel {
  final String id;
  final String bookingId;
  final String consumerId;
  final String providerId;
  final String serviceId;
  final String? planId;
  final String addressId;
  final String bookingDate;
  final String bookingTime;
  final String? note;
  final String status;
  final String? remark;
  final String? otp;
  final String createdAt;
  final String updatedAt;
  final ConsumerModel? consumer;
  final AddressModel? address;
  final PlanModel? plan;
  final ServiceModel? service;

  BookingRequestModel({
    required this.id,
    required this.bookingId,
    required this.consumerId,
    required this.providerId,
    required this.serviceId,
    this.planId,
    required this.addressId,
    required this.bookingDate,
    required this.bookingTime,
    this.note,
    required this.status,
    this.remark,
    this.otp,
    required this.createdAt,
    required this.updatedAt,
    this.consumer,
    this.address,
    this.plan,
    this.service,
  });

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      consumerId: json['consumer_id']?.toString() ?? '',
      providerId: json['provider_id']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      planId: json['plan_id']?.toString(),
      addressId: json['address_id']?.toString() ?? '',
      bookingDate: json['booking_date']?.toString() ?? '',
      bookingTime: json['booking_time']?.toString() ?? '',
      note: json['note']?.toString(),
      status: json['status']?.toString() ?? '',
      remark: json['remark']?.toString(),
      otp: json['otp']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      consumer:
          json['consumer'] != null
              ? ConsumerModel.fromJson(json['consumer'])
              : null,
      address:
          json['address'] != null
              ? AddressModel.fromJson(json['address'])
              : null,
      plan: json['plan'] != null ? PlanModel.fromJson(json['plan']) : null,
      service:
          json['service'] != null
              ? ServiceModel.fromJson(json['service'])
              : null,
    );
  }
}

class ConsumerModel {
  final String id;
  final String name;
  final String profilePhotoUrl;

  ConsumerModel({
    required this.id,
    required this.name,
    required this.profilePhotoUrl,
  });

  factory ConsumerModel.fromJson(Map<String, dynamic> json) {
    return ConsumerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      profilePhotoUrl: json['profile_photo_url']?.toString() ?? '',
    );
  }
}

class AddressModel {
  final String id;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  AddressModel({
    required this.id,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
    );
  }
}

class PlanModel {
  final String id;
  final String planType;

  PlanModel({required this.id, required this.planType});

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id']?.toString() ?? '',
      planType: json['plan_type']?.toString() ?? '',
    );
  }
}

class ServiceModel {
  final String id;
  final String name;

  ServiceModel({required this.id, required this.name});

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
