import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/chat/model/chat_model.dart';
import 'package:ustahub/network/booking_api_service.dart';
import 'package:ustahub/network/supabase_client.dart';

class BookingChatController extends GetxController {
  final BookingApiService _bookingApi = BookingApiService();
  final _client = SupabaseClientService.instance;

  final RxList<BookingChatItem> chats = <BookingChatItem>[].obs;
  final RxBool isLoading = false.obs;

  String? get currentUserId => SupabaseClientService.currentUserId;

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  Future<void> loadChats() async {
    try {
      isLoading.value = true;
      final role = await Sharedprefhelper.getRole() ?? 'consumer';

      final response = await _bookingApi.listBookings(
        role: role,
        status: 'all',
        page: 1,
        pageSize: 50,
      );

      final body = response['body'] as Map<String, dynamic>? ?? {};
      final items = body['data'] as List<dynamic>? ?? [];

      chats.value = items.map((raw) {
        final map = Map<String, dynamic>.from(raw as Map);
        final scheduled = map['scheduled'] as Map<String, dynamic>? ?? {};
        final date = scheduled['date']?.toString();
        final time = scheduled['time']?.toString();

        DateTime? updatedAt;
        if (map['updatedAt'] != null) {
          updatedAt = DateTime.tryParse(map['updatedAt'].toString());
        }

        final counterparty = map['counterparty'] as Map<String, dynamic>? ?? {};

        return BookingChatItem(
          bookingId: map['id']?.toString() ?? '',
          bookingNumber: map['bookingNumber']?.toString() ?? '',
          status: map['status']?.toString() ?? '',
          counterpartyName:
              counterparty['name']?.toString().isNotEmpty == true
                  ? counterparty['name'].toString()
                  : 'Customer',
          counterpartyAvatar: counterparty['avatar']?.toString(),
          addressPreview: map['addressPreview']?.toString().isNotEmpty == true
              ? map['addressPreview'].toString()
              : [date, time].whereType<String>().join(' • '),
          updatedAt: updatedAt,
        );
      }).toList();
    } catch (e) {
      debugPrint('[CHAT] Error loading chats: $e');
      CustomToast.error('Failed to load chats');
    } finally {
      isLoading.value = false;
    }
  }

  Stream<List<BookingChatMessage>> messagesForBooking(String bookingId) {
    return _client
        .from('booking_messages')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .order('created_at', ascending: true)
        .map(
          (rows) => rows
              .map(
                (row) => BookingChatMessage.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .toList(),
        );
  }

  Future<void> sendMessage({
    required String bookingId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    final senderId = currentUserId;
    if (senderId == null) {
      CustomToast.error('You must be logged in to send messages');
      return;
    }

    try {
      // Use send-message Edge Function which handles message insertion and notifications
      final response = await _bookingApi.sendMessage(
        bookingId: bookingId,
        text: text.trim(),
      );

      final body = response['body'] as Map<String, dynamic>? ?? {};
      if (response['statusCode'] == 200 && body['success'] == true) {
        debugPrint('[CHAT] Message sent successfully');
        // Message will appear via realtime stream
      } else {
        final errorMsg = body['message']?.toString() ?? 'Failed to send message';
        debugPrint('[CHAT] Error sending message: $errorMsg');
        CustomToast.error(errorMsg);
      }
    } catch (e) {
      debugPrint('[CHAT] Error sending message: $e');
      CustomToast.error('Failed to send message');
    }
  }
}


