import 'package:ustahub/app/export/exports.dart';

class BookingChatItem {
  final String bookingId;
  final String bookingNumber;
  final String status;
  final String counterpartyName;
  final String? counterpartyAvatar;
  final String? addressPreview;
  final DateTime? updatedAt;

  BookingChatItem({
    required this.bookingId,
    required this.bookingNumber,
    required this.status,
    required this.counterpartyName,
    this.counterpartyAvatar,
    this.addressPreview,
    this.updatedAt,
  });
}

class BookingChatMessage {
  final String id;
  final String bookingId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  BookingChatMessage({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory BookingChatMessage.fromJson(Map<String, dynamic> json) {
    return BookingChatMessage(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  bool isMine(String? currentUserId) => senderId == currentUserId;
}


