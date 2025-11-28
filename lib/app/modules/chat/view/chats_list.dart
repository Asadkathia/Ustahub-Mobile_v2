import 'package:ustahub/app/export/exports.dart';
import 'package:ustahub/app/modules/chat/controller/chat_controller.dart';
import 'package:ustahub/app/modules/chat/model/chat_model.dart';
import 'package:ustahub/app/modules/chat/view/chat_view.dart';

class BookingChatListPage extends StatelessWidget {
  const BookingChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingChatController());

    return Scaffold(
        appBar: AppBar(
        title: const Text('Chat'),
        automaticallyImplyLeading: false,
        ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.chats.isEmpty) {
          return const Center(child: Text('No chats yet'));
        }

        return ListView.separated(
          itemCount: controller.chats.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final BookingChatItem item = controller.chats[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: item.counterpartyAvatar != null &&
                        item.counterpartyAvatar!.isNotEmpty
                    ? NetworkImage(item.counterpartyAvatar!)
                    : null,
                child: (item.counterpartyAvatar == null ||
                        item.counterpartyAvatar!.isEmpty)
                    ? Text(
                        item.counterpartyName.isNotEmpty
                            ? item.counterpartyName[0].toUpperCase()
                            : '?',
                      )
                    : null,
              ),
              title: Text(item.counterpartyName),
              subtitle: Text(
                item.addressPreview ?? item.bookingNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                item.updatedAt != null
                    ? TimeOfDay.fromDateTime(item.updatedAt!)
                        .format(context)
                    : '',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
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
            );
          },
        );
      }),
    );
  }
}

