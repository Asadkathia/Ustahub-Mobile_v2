import 'dart:convert';

ProviderBookingModel providerBookingModelFromJson(String str) =>
    ProviderBookingModel.fromJson(json.decode(str));

// String rBookingModelToJson(ProviderBookingModel data) =>
//     json.encode(providedata.toJson());

class ProviderBookingModel {
  bool? status;
  String? type;
  int? count;
  List<Booking>? bookings;

  ProviderBookingModel({
    this.status,
    this.type,
    this.count,
    this.bookings,
  });

  factory ProviderBookingModel.fromJson(Map<String, dynamic> json) =>
      ProviderBookingModel(
        status: json["status"],
        type: json["type"],
        count: json["count"],
        bookings: json["bookings"] == null
            ? []
            : List<Booking>.from(
                json["bookings"]!.map((x) => Booking.fromJson(x))),
      );


}

class Booking {
  String? id;
  String? bookingId;
  String? consumerId;
  String? providerId;
  String? serviceId;
  String? addressId;
  String? bookingDate;
  String? bookingTime;
  dynamic note;
  String? status;
  dynamic remark;
  dynamic otp;
  DateTime? createdAt;
  DateTime? updatedAt;
  Consumer? consumer;
  Service? service;
  BookingPayment? bookingPayment;

  Booking({
    this.id,
    this.bookingId,
    this.consumerId,
    this.providerId,
    this.serviceId,
    this.addressId,
    this.bookingDate,
    this.bookingTime,
    this.note,
    this.status,
    this.remark,
    this.otp,
    this.createdAt,
    this.updatedAt,
    this.consumer,
    this.service,
    this.bookingPayment,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json["id"]?.toString(),
        bookingId: json["booking_id"]?.toString(),
        consumerId: json["consumer_id"]?.toString(),
        providerId: json["provider_id"]?.toString(),
        serviceId: json["service_id"]?.toString(),
        addressId: json["address_id"]?.toString(),
        bookingDate: json["booking_date"],
        bookingTime: json["booking_time"],
        note: json["note"],
        status: json["status"],
        remark: json["remark"],
        otp: json["otp"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        consumer: json["consumer"] == null
            ? null
            : Consumer.fromJson(json["consumer"]),
        service:
            json["service"] == null ? null : Service.fromJson(json["service"]),
        bookingPayment: json["booking_payment"] == null
            ? null
            : BookingPayment.fromJson(json["booking_payment"]),
      );

 
}

class BookingPayment {
  String? id;
  String? bookingId;
  String? itemTotal;
  String? visitingCharge;
  dynamic discount;
  String? serviceFee;
  String? total;
  DateTime? createdAt;
  DateTime? updatedAt;

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

  factory BookingPayment.fromJson(Map<String, dynamic> json) => BookingPayment(
        id: json["id"]?.toString(),
        bookingId: json["booking_id"]?.toString(),
        itemTotal: json["item_total"],
        visitingCharge: json["visiting_charge"],
        discount: json["discount"],
        serviceFee: json["service_fee"],
        total: json["total"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "booking_id": bookingId,
        "item_total": itemTotal,
        "visiting_charge": visitingCharge,
        "discount": discount,
        "service_fee": serviceFee,
        "total": total,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class Consumer {
  String? id;
  String? name;
  String? profilePhotoUrl;

  Consumer({
    this.id,
    this.name,
    this.profilePhotoUrl,
  });

  factory Consumer.fromJson(Map<String, dynamic> json) => Consumer(
        id: json["id"]?.toString(),
        name: json["name"],
        profilePhotoUrl: json["profile_photo_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "profile_photo_url": profilePhotoUrl,
      };
}

class Service {
  String? id;
  String? name;

  Service({
    this.id,
    this.name,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json["id"]?.toString(),
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
