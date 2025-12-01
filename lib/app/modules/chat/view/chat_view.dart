import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/chat/controller/chat_controller.dart';
import 'package:ustahub/app/modules/chat/model/chat_model.dart';
import 'package:ustahub/app/ui_v2/components/navigation/app_app_bar_v2.dart';
import 'package:ustahub/app/ui_v2/components/cards/app_card.dart';
import 'package:ustahub/app/ui_v2/components/feedback/empty_state_v2.dart';
import 'package:ustahub/app/ui_v2/design_system/colors/app_colors_v2.dart';
import 'package:ustahub/app/ui_v2/design_system/spacing/app_spacing.dart';
import 'package:ustahub/app/ui_v2/design_system/typography/app_text_styles.dart';

class BookingChatPage extends StatefulWidget {
  final String bookingId;
  final String bookingNumber;
  final String counterpartyName;

  const BookingChatPage({
    super.key,
    required this.bookingId,
    required this.bookingNumber,
    required this.counterpartyName,
  });

  @override
  State<BookingChatPage> createState() => _BookingChatPageState();
}

class _BookingChatPageState extends State<BookingChatPage> {
  late final BookingChatController _controller;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure the chat controller exists even when navigating directly
    // from booking details (without going through the chat tab first).
    if (Get.isRegistered<BookingChatController>()) {
      _controller = Get.find<BookingChatController>();
    } else {
      _controller = Get.put(BookingChatController());
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    await _controller.sendMessage(
      bookingId: widget.bookingId,
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: widget.counterpartyName,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: Center(
              child: Text(
                widget.bookingNumber,
                style: AppTextStyles.captionSmall,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<BookingChatMessage>>(
              stream:
                  _controller.messagesForBooking(widget.bookingId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? const [];
                if (messages.isEmpty) {
                  return EmptyStateV2(
                    icon: Icons.chat_bubble_outline,
                    title: 'No messages yet',
                    subtitle: 'Start the conversation with a quick hello.',
                  );
                }

                final myId = _controller.currentUserId;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final mine = msg.isMine(myId);
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: AppSpacing.xsVertical),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.smVertical,
                        ),
                        decoration: BoxDecoration(
                          color: mine ? AppColorsV2.primary : AppColorsV2.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.text,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: mine ? AppColorsV2.textOnPrimary : AppColorsV2.textPrimary,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xsVertical),
                            Text(
                              TimeOfDay.fromDateTime(msg.createdAt).format(context),
                              style: AppTextStyles.captionSmall.copyWith(
                                color: mine
                                    ? AppColorsV2.textOnPrimary.withOpacity(0.7)
                                    : AppColorsV2.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
                vertical: AppSpacing.smVertical,
              ),
              child: AppCard(
                bordered: true,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: AppColorsV2.primary,
                      onPressed: _send,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
