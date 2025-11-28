class BookingDetailsModelClass {
  String? id;
  String? bookingId;
  String? consumerId;
  String? providerId;
  String? serviceId;
  String? addressId;
  String? bookingDate;
  String? bookingTime;
  String? note;
  String? status;
  String? remark;
  String? otp;
  String? createdAt;
  String? updatedAt;
  Consumer? consumer;
  BookingProvider? provider;
  Service? service;
  Address? address;
  BookingPayment? bookingPayment;

  BookingDetailsModelClass({
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
    this.provider,
    this.service,
    this.address,
    this.bookingPayment,
  });

  BookingDetailsModelClass copyWith({
    String? id,
    String? bookingId,
    String? consumerId,
    String? providerId,
    String? serviceId,
    String? addressId,
    String? bookingDate,
    String? bookingTime,
    String? note,
    String? status,
    String? remark,
    String? otp,
    String? createdAt,
    String? updatedAt,
    Consumer? consumer,
    BookingProvider? provider,
    Service? service,
    Address? address,
    BookingPayment? bookingPayment,
  }) {
    return BookingDetailsModelClass(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      consumerId: consumerId ?? this.consumerId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      addressId: addressId ?? this.addressId,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      note: note ?? this.note,
      status: status ?? this.status,
      remark: remark ?? this.remark,
      otp: otp ?? this.otp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      consumer: consumer ?? this.consumer,
      provider: provider ?? this.provider,
      service: service ?? this.service,
      address: address ?? this.address,
      bookingPayment: bookingPayment ?? this.bookingPayment,
    );
  }

  factory BookingDetailsModelClass.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BookingDetailsModelClass();

    // Support both legacy shape (bookings + nested objects) and the new booking-detail payload.
    final bookingData = json['booking'] ?? json['bookings'] ?? json;
    final consumerData = json['consumer'] ?? bookingData['consumer'];
    final providerData = json['provider'] ?? bookingData['provider'];
    final serviceData = json['service'] ?? bookingData['service'];
    final addressData = json['address'] ?? bookingData['address'];
    final paymentData =
        json['booking_payment'] ?? bookingData['booking_payment'];

    String? _stringify(dynamic value, {List<String> fallbacks = const []}) {
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
      for (final key in fallbacks) {
        final nested = bookingData[key];
        if (nested != null && nested.toString().isNotEmpty) {
          return nested.toString();
        }
      }
      return null;
    }

    String? asString(dynamic value) {
      if (value == null) return null;
      final text = value.toString();
      return text.isEmpty || text == 'null' ? null : text;
    }

    try {
      return BookingDetailsModelClass(
        id: asString(bookingData['id'] ?? bookingData['booking']?['id']),
        bookingId: asString(bookingData['booking_id']) ??
            asString(bookingData['bookingId']) ??
            asString(bookingData['booking_number']) ??
            asString(bookingData['bookingNumber']),
        consumerId: asString(bookingData['consumer_id'] ?? bookingData['consumerId']),
        providerId: asString(bookingData['provider_id'] ?? bookingData['providerId']),
        serviceId: asString(bookingData['service_id'] ?? bookingData['serviceId']),
        addressId: asString(bookingData['address_id'] ?? bookingData['addressId']),
        bookingDate: _stringify(
          bookingData['booking_date'],
          fallbacks: const ['bookingDate'],
        ),
        bookingTime: _stringify(
          bookingData['booking_time'],
          fallbacks: const ['bookingTime'],
        ),
        note: bookingData['note'],
        status: bookingData['status'],
        remark: bookingData['remark'],
        otp: bookingData['otp'],
        createdAt: _stringify(
          bookingData['created_at'],
          fallbacks: const ['createdAt'],
        ),
        updatedAt: _stringify(
          bookingData['updated_at'],
          fallbacks: const ['updatedAt'],
        ),
        consumer: consumerData != null ? Consumer.fromJson(consumerData) : null,
        provider:
            providerData != null ? BookingProvider.fromJson(providerData) : null,
        service: serviceData != null ? Service.fromJson(serviceData) : null,
        address: addressData != null ? Address.fromJson(addressData) : null,
        bookingPayment:
            paymentData != null ? BookingPayment.fromJson(paymentData) : null,
      );
    } catch (e) {
      // Rethrow with context so callers can log/debug; avoid using Flutter-only debugPrint here.
      throw Exception(
        'BookingDetailsModelClass.fromJson parse error: $e; payload keys=${json.keys.toList()}',
      );
    }
  }
}

class BookingProvider {
  String? id;
  String? name;
  String? avatar;
  bool? isFavorite;
  String? averageRating;

  BookingProvider({
    this.id,
    this.name,
    this.avatar,
    this.isFavorite,
    this.averageRating,
  });

  BookingProvider copyWith({
    String? id,
    String? name,
    String? avatar,
    bool? isFavorite,
    String? averageRating,
  }) {
    return BookingProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isFavorite: isFavorite ?? this.isFavorite,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  factory BookingProvider.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BookingProvider();
    return BookingProvider(
      id: json['id']?.toString(),
      name: json['name'],
      avatar: json['profile_photo_url'] ?? json['avatar'],
      isFavorite: json['is_favorite'],
      averageRating: json['average_rating']?.toString(),
    );
  }
}

class Consumer {
  String? id;
  String? name;
  String? profilePhotoUrl;

  Consumer({this.id, this.name, this.profilePhotoUrl});

  factory Consumer.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Consumer();
    return Consumer(
      id: json['id']?.toString(),
      name: json['name'] ?? json['full_name'],
      profilePhotoUrl: json['profile_photo_url'] ?? json['avatar'],
    );
  }
}

class Service {
  String? id;
  String? name;

  Service({this.id, this.name});

  factory Service.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Service();
    return Service(id: json['id']?.toString(), name: json['name']);
  }
}

class Address {
  String? id;
  String? userId;
  String? latitude;
  String? longitude;
  String? address;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  bool? isDefault;
  String? createdAt;
  String? updatedAt;

  Address({
    this.id,
    this.userId,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Address();
    
    // Helper to safely get string value
    String safeString(dynamic value) {
      if (value == null) return '';
      final str = value.toString().trim();
      return (str == 'null' || str.isEmpty) ? '' : str;
    }
    
    final addressLine1 = safeString(
      json['address_line1'] ?? json['address'] ?? json['full'],
    );
    final addressLine2 = safeString(json['address_line2']);
    final fullAddress = addressLine2.isNotEmpty 
        ? '$addressLine1, $addressLine2' 
        : addressLine1;
    
    return Address(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      latitude: safeString(json['latitude']),
      longitude: safeString(json['longitude']),
      address: fullAddress.isNotEmpty ? fullAddress : null,
      city: safeString(json['city']),
      state: safeString(json['state']),
      country: safeString(json['country']),
      postalCode: safeString(json['postal_code'] ?? json['postalCode']),
      isDefault: json['is_default'] ?? false,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
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
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
