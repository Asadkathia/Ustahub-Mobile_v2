import 'package:flutter/material.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/chat/controller/chat_controller.dart';
import 'package:ustahub/app/modules/chat/model/chat_model.dart';
import '../../components/navigation/app_app_bar_v2.dart';
import '../../components/cards/app_card.dart';
import '../../components/feedback/skeleton_loader_v2.dart';
import '../../components/feedback/empty_state_v2.dart';
import '../../design_system/colors/app_colors_v2.dart';
import '../../design_system/typography/app_text_styles.dart';
import '../../design_system/spacing/app_spacing.dart';

class ChatScreenV2 extends StatelessWidget {
  ChatScreenV2({super.key});
  final BookingChatController controller = Get.put(BookingChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.background,
      appBar: AppAppBarV2(
        title: AppLocalizations.of(context)!.chat,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ListView.builder(
            padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
            itemCount: 6,
            itemBuilder: (_, __) => const SkeletonListItemV2(),
          );
        }

        if (controller.chats.isEmpty) {
          return EmptyStateV2(
            icon: Icons.chat_bubble_outline,
            title: 'No conversations found',
            subtitle: 'Start a booking to chat with providers or customers.',
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingHorizontal,
            vertical: AppSpacing.mdVertical,
          ),
          itemCount: controller.chats.length,
          separatorBuilder: (_, __) => SizedBox(height: AppSpacing.smVertical),
          itemBuilder: (context, index) {
            final BookingChatItem item = controller.chats[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingChatPage(
                      bookingId: item.bookingId,
                      bookingNumber: item.bookingNumber,
                      counterpartyName: item.counterpartyName,
                    ),
                  ),
                );
              },
              child: AppCard(
                enableShadow: true,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28.r,
                      backgroundColor: AppColorsV2.primary.withOpacity(0.1),
                      backgroundImage: (item.counterpartyAvatar != null &&
                              item.counterpartyAvatar!.isNotEmpty)
                          ? NetworkImage(item.counterpartyAvatar!)
                          : null,
                      child: (item.counterpartyAvatar == null ||
                              item.counterpartyAvatar!.isEmpty)
                          ? Text(
                              item.counterpartyName.isNotEmpty
                                  ? item.counterpartyName[0].toUpperCase()
                                  : '?',
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColorsV2.primary,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.counterpartyName,
                            style: AppTextStyles.heading4,
                          ),
                          SizedBox(height: AppSpacing.xsVertical),
                          Text(
                            item.addressPreview ?? item.bookingNumber,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.updatedAt != null
                              ? TimeOfDay.fromDateTime(item.updatedAt!)
                                  .format(context)
                              : '',
                          style: AppTextStyles.captionSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

