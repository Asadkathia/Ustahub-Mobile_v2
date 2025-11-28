import 'package:flutter/material.dart';

class ProviderBookingHistoryResponse {
  final bool status;
  final int count;
  final List<HistoryBooking> bookings;

  ProviderBookingHistoryResponse({
    required this.status,
    required this.count,
    required this.bookings,
  });

  factory ProviderBookingHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ProviderBookingHistoryResponse(
      status: json['status'] ?? false,
      count: json['count'] ?? 0,
      bookings:
          (json['bookings'] as List<dynamic>?)
              ?.map((e) => HistoryBooking.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'count': count,
      'bookings': bookings.map((e) => e.toJson()).toList(),
    };
  }
}

class HistoryBooking {
  final String id;
  final String bookingId;
  final String consumerId;
  final String providerId;
  final String serviceId;
  final String addressId;
  final String bookingDate;
  final String bookingTime;
  final String note;
  final String status;
  final String? remark;
  final String otp;
  final DateTime createdAt;
  final DateTime updatedAt;
  final HistoryCounterparty counterparty; // Can be consumer or provider depending on role
  final HistoryService service;
  final HistoryBookingPayment? bookingPayment;
  final HistoryAddress? address;

  HistoryBooking({
    required this.id,
    required this.bookingId,
    required this.consumerId,
    required this.providerId,
    required this.serviceId,
    required this.addressId,
    required this.bookingDate,
    required this.bookingTime,
    required this.note,
    required this.status,
    this.remark,
    required this.otp,
    required this.createdAt,
    required this.updatedAt,
    required this.counterparty,
    required this.service,
    this.bookingPayment,
    this.address,
  });

  factory HistoryBooking.fromJson(Map<String, dynamic> json) {
    // Parse dates safely
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    // Counterparty can be either 'consumer' or 'provider' depending on who is viewing
    final counterpartyData = json['consumer'] ?? json['provider'] ?? {};

    return HistoryBooking(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      consumerId: json['consumer_id']?.toString() ?? '',
      providerId: json['provider_id']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      addressId: json['address_id']?.toString() ?? '',
      bookingDate: json['booking_date']?.toString() ?? '',
      bookingTime: json['booking_time']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      remark: json['remark']?.toString(),
      otp: json['otp']?.toString() ?? '',
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      counterparty: HistoryCounterparty.fromJson(counterpartyData),
      service: HistoryService.fromJson(json['service'] ?? {}),
      bookingPayment: json['booking_payment'] != null
          ? HistoryBookingPayment.fromJson(json['booking_payment'])
          : null,
      address: json['address'] != null
          ? HistoryAddress.fromJson(json['address'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'consumer_id': consumerId,
      'provider_id': providerId,
      'service_id': serviceId,
      'address_id': addressId,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'note': note,
      'status': status,
      'remark': remark,
      'otp': otp,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'counterparty': counterparty.toJson(),
      'service': service.toJson(),
      if (bookingPayment != null) 'booking_payment': bookingPayment!.toJson(),
      if (address != null) 'address': address!.toJson(),
    };
  }

  // Helper to get counterparty name (consumer or provider)
  String get counterpartyName => counterparty.name;
  String? get counterpartyAvatar => counterparty.profilePhotoUrl;

  // Helper methods
  String get formattedDate {
    try {
      final date = DateTime.parse(bookingDate);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '$difference days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return bookingDate;
    }
  }

  String get formattedTime {
    try {
      final time = DateTime.parse('2000-01-01 $bookingTime');
      final hour = time.hour;
      final minute = time.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return bookingTime;
    }
  }

  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'start':
        return 'Started';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      default:
        return status.toUpperCase();
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'start':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

/// Unified counterparty model - can represent either consumer or provider
class HistoryCounterparty {
  final String id;
  final String name;
  final String? profilePhotoUrl;
  final bool isFavorite;
  final double? averageRating;

  HistoryCounterparty({
    required this.id,
    required this.name,
    this.profilePhotoUrl,
    this.isFavorite = false,
    this.averageRating,
  });

  factory HistoryCounterparty.fromJson(Map<String, dynamic> json) {
    return HistoryCounterparty(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      profilePhotoUrl: json['profile_photo_url']?.toString() ?? json['avatar']?.toString(),
      isFavorite: json['is_favorite'] == true,
      averageRating: json['average_rating'] != null
          ? double.tryParse(json['average_rating'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_photo_url': profilePhotoUrl,
      'is_favorite': isFavorite,
      'average_rating': averageRating,
    };
  }
}

/// Address model for booking history
class HistoryAddress {
  final String? id;
  final String address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  HistoryAddress({
    this.id,
    required this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory HistoryAddress.fromJson(Map<String, dynamic> json) {
    return HistoryAddress(
      id: json['id']?.toString(),
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      postalCode: json['postal_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
    };
  }

  String get fullAddress {
    final parts = <String>[];
    if (address.isNotEmpty) parts.add(address);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (postalCode != null && postalCode!.isNotEmpty) parts.add(postalCode!);
    return parts.join(', ');
  }
}

class HistoryService {
  final String id;
  final String name;

  HistoryService({required this.id, required this.name});

  factory HistoryService.fromJson(Map<String, dynamic> json) {
    return HistoryService(id: json['id']?.toString() ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class HistoryBookingPayment {
  final String id;
  final String bookingId;
  final String itemTotal;
  final String visitingCharge;
  final String? discount;
  final String serviceFee;
  final String total;
  final DateTime createdAt;
  final DateTime updatedAt;

  HistoryBookingPayment({
    required this.id,
    required this.bookingId,
    required this.itemTotal,
    required this.visitingCharge,
    this.discount,
    required this.serviceFee,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HistoryBookingPayment.fromJson(Map<String, dynamic> json) {
    return HistoryBookingPayment(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      itemTotal: json['item_total']?.toString() ?? '0.00',
      visitingCharge: json['visiting_charge']?.toString() ?? '0.00',
      discount: json['discount']?.toString(),
      serviceFee: json['service_fee']?.toString() ?? '0.00',
      total: json['total']?.toString() ?? '0.00',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'item_total': itemTotal,
      'visiting_charge': visitingCharge,
      'discount': discount,
      'service_fee': serviceFee,
      'total': total,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  String get formattedTotal =>
      double.tryParse(total)?.toStringAsFixed(2) ?? total;
  String get formattedVisitingCharge =>
      double.tryParse(visitingCharge)?.toStringAsFixed(2) ?? visitingCharge;
  String get formattedItemTotal =>
      double.tryParse(itemTotal)?.toStringAsFixed(2) ?? itemTotal;
}
