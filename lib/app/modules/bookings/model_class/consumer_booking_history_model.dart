import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConsumerBookingHistoryResponse {
  final bool status;
  final int count;
  final List<ConsumerHistoryBooking> bookings;

  ConsumerBookingHistoryResponse({
    required this.status,
    required this.count,
    required this.bookings,
  });

  factory ConsumerBookingHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ConsumerBookingHistoryResponse(
      status: json['status'] ?? false,
      count: json['count'] ?? 0,
      bookings:
          (json['bookings'] as List<dynamic>?)
              ?.map(
                (booking) => ConsumerHistoryBooking.fromJson(
                  booking as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'count': count,
      'bookings': bookings.map((booking) => booking.toJson()).toList(),
    };
  }
}

class ConsumerHistoryBooking {
  final String id;
  final String bookingId;
  final String consumerId;
  final String providerId;
  final String serviceId;
  final String addressId;
  final String bookingDate;
  final String bookingTime;
  final String? note;
  final String status;
  final String? remark;
  final String? otp;
  final String createdAt;
  final String updatedAt;
  final ConsumerHistoryProvider provider;
  final ConsumerHistoryService service;
  final ConsumerBookingPayment? bookingPayment;

  ConsumerHistoryBooking({
    required this.id,
    required this.bookingId,
    required this.consumerId,
    required this.providerId,
    required this.serviceId,
    required this.addressId,
    required this.bookingDate,
    required this.bookingTime,
    this.note,
    required this.status,
    this.remark,
    this.otp,
    required this.createdAt,
    required this.updatedAt,
    required this.provider,
    required this.service,
    this.bookingPayment,
  });

  factory ConsumerHistoryBooking.fromJson(Map<String, dynamic> json) {
    return ConsumerHistoryBooking(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      consumerId: json['consumer_id']?.toString() ?? '',
      providerId: json['provider_id']?.toString() ?? '',
      serviceId: json['service_id']?.toString() ?? '',
      addressId: json['address_id']?.toString() ?? '',
      bookingDate: json['booking_date'] ?? '',
      bookingTime: json['booking_time'] ?? '',
      note: json['note'],
      status: json['status'] ?? '',
      remark: json['remark'],
      otp: json['otp'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      provider: ConsumerHistoryProvider.fromJson(json['provider'] ?? {}),
      service: ConsumerHistoryService.fromJson(json['service'] ?? {}),
      bookingPayment:
          json['booking_payment'] != null
              ? ConsumerBookingPayment.fromJson(json['booking_payment'])
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
      'created_at': createdAt,
      'updated_at': updatedAt,
      'provider': provider.toJson(),
      'service': service.toJson(),
      'booking_payment': bookingPayment?.toJson(),
    };
  }

  // Helper methods for formatted display
  String get formattedDate {
    try {
      final date = DateTime.parse(bookingDate);
      return DateFormat('EEE, MMM dd, yyyy').format(date);
    } catch (e) {
      return bookingDate;
    }
  }

  String get formattedTime {
    try {
      final time = DateFormat('HH:mm:ss').parse(bookingTime);
      return DateFormat('hh:mm a').format(time);
    } catch (e) {
      return bookingTime;
    }
  }

  String get formattedCreatedDate {
    try {
      final date = DateTime.parse(createdAt);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return createdAt;
    }
  }

  // Status color mapping
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'start':
      case 'ongoing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      case 'not_started':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Display status text
  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'start':
        return 'In Progress';
      case 'not_started':
        return 'Not Started';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  // Total amount from booking payment
  String get totalAmount {
    return bookingPayment?.total ?? '0.00';
  }

  // Visiting charge from booking payment
  String get visitingCharge {
    return bookingPayment?.visitingCharge ?? '0.00';
  }
}

class ConsumerHistoryProvider {
  final String id;
  final String name;
  final bool isFavorite;
  final double? averageRating;

  ConsumerHistoryProvider({
    required this.id,
    required this.name,
    required this.isFavorite,
    this.averageRating,
  });

  factory ConsumerHistoryProvider.fromJson(Map<String, dynamic> json) {
    return ConsumerHistoryProvider(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      isFavorite: json['is_favorite'] ?? false,
      averageRating:
          json['average_rating'] != null
              ? double.tryParse(json['average_rating'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_favorite': isFavorite,
      'average_rating': averageRating,
    };
  }
}

class ConsumerHistoryService {
  final String id;
  final String name;

  ConsumerHistoryService({required this.id, required this.name});

  factory ConsumerHistoryService.fromJson(Map<String, dynamic> json) {
    return ConsumerHistoryService(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class ConsumerBookingPayment {
  final String id;
  final String bookingId;
  final String itemTotal;
  final String visitingCharge;
  final String? discount;
  final String serviceFee;
  final String total;
  final String createdAt;
  final String updatedAt;

  ConsumerBookingPayment({
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

  factory ConsumerBookingPayment.fromJson(Map<String, dynamic> json) {
    return ConsumerBookingPayment(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      itemTotal: json['item_total']?.toString() ?? '0.00',
      visitingCharge: json['visiting_charge']?.toString() ?? '0.00',
      discount: json['discount']?.toString(),
      serviceFee: json['service_fee']?.toString() ?? '0.00',
      total: json['total']?.toString() ?? '0.00',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
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
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper method for formatted total amount
  String get formattedTotal {
    try {
      final amount = double.parse(total);
      return amount.toStringAsFixed(2);
    } catch (e) {
      return total;
    }
  }

  // Helper method for formatted visiting charge
  String get formattedVisitingCharge {
    try {
      final amount = double.parse(visitingCharge);
      return amount.toStringAsFixed(2);
    } catch (e) {
      return visitingCharge;
    }
  }
}
