import 'package:flutter/material.dart';
import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/chat/controller/chat_controller.dart';
import 'package:ustahub/app/modules/chat/model/chat_model.dart';
import '../../components/navigation/app_app_bar_v2.dart';
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
          return Center(
            child: CircularProgressIndicator(
              color: AppColorsV2.primary,
            ),
          );
        }

        if (controller.chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: AppSpacing.iconXLarge,
                  color: AppColorsV2.textTertiary,
                ),
                SizedBox(height: AppSpacing.mdVertical),
                Text(
                  'No conversations found',
                  style: AppTextStyles.bodyMediumSecondary,
                ),
              ],
            ),
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
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColorsV2.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorsV2.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
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

