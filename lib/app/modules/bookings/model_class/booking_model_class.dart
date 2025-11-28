class BookingModel {
  String? id;
  String? bookingId;
  String? consumerId;
  String? providerId;
  String? serviceId;
  String? planId;
  String? addressId;
  String? bookingDate;
  String? bookingTime;
  String? note;
  String? status;
  String? remark;
  String? createdAt;
  String? updatedAt;
  Provider? provider;
  Service? service;
  Plan? plan;
  BookingPayment? bookingPayment;

  BookingModel({
    this.id,
    this.bookingId,
    this.consumerId,
    this.providerId,
    this.serviceId,
    this.planId,
    this.addressId,
    this.bookingDate,
    this.bookingTime,
    this.note,
    this.status,
    this.remark,
    this.createdAt,
    this.updatedAt,
    this.provider,
    this.service,
    this.plan,
    this.bookingPayment,
  });

  factory BookingModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BookingModel();
    
    // Helper to safely convert to String
    String? safeStringId(dynamic value) {
      if (value == null) return null;
      return value.toString();
    }
    
    return BookingModel(
      id: safeStringId(json['id']),
      bookingId: json['booking_id']?.toString(),
      consumerId: safeStringId(json['consumer_id']),
      providerId: safeStringId(json['provider_id']),
      serviceId: safeStringId(json['service_id']),
      planId: safeStringId(json['plan_id']),
      addressId: safeStringId(json['address_id']),
      bookingDate: json['booking_date']?.toString(),
      bookingTime: json['booking_time']?.toString(),
      note: json['note']?.toString(),
      status: json['status']?.toString(),
      remark: json['remark']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      provider: Provider.fromJson(json['provider']),
      service: Service.fromJson(json['service']),
      plan: Plan.fromJson(json['plan']),
      bookingPayment: BookingPayment.fromJson(json['booking_payment']),
    );
  }
}
class Provider {
  String? id;
  String? name;
  String? avatar;
  bool? isFavorite;
  String? averageRating;

  Provider({
    this.id,
    this.name,
    this.avatar,
    this.isFavorite,
    this.averageRating,
  });

  factory Provider.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Provider();

    // Handle provider data - could be from user_profiles, providers, or booking snapshots
    return Provider(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? json['business_name']?.toString(),
      avatar: json['profile_photo_url']?.toString() ?? json['avatar']?.toString(),
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 'true',
      averageRating: json['average_rating']?.toString(),
    );
  }
}

class Service {
  String? id;
  String? name;

  Service({
    this.id,
    this.name,
  });

  factory Service.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Service();
    return Service(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
    );
  }
}

class Plan {
  String? id;
  String? planTitle;
  String? planPrice;

  Plan({
    this.id,
    this.planTitle,
    this.planPrice,
  });

  factory Plan.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Plan();
    return Plan(
      id: json['id']?.toString(),
      planTitle: json['plan_title']?.toString() ?? json['plan_type']?.toString(),
      planPrice: json['plan_price']?.toString() ?? json['price']?.toString(),
    );
  }
}
class BookingPayment {
  String? id;
  String? bookingId;
  String? itemTotal;
  String? visitingCharge;
  String? discount;
  String? serviceFee;
  String? total;
  String? createdAt;
  String? updatedAt;

  BookingPayment({
    this.id,
    this.bookingId,
    this.itemTotal,
    this.visitingCharge,
    this.discount,
    this.serviceFee,
    this.total,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingPayment.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BookingPayment();
    return BookingPayment(
      id: json['id']?.toString(),
      bookingId: json['booking_id']?.toString(),
      itemTotal: json['item_total']?.toString(),
      visitingCharge: json['visiting_charge']?.toString(),
      discount: json['discount']?.toString(),
      serviceFee: json['service_fee']?.toString(),
      total: json['total']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
