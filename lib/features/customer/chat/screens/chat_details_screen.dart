import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/chat/data/bloc/customer_chat_bloc.dart';
import 'package:resq360/features/customer/chat/data/models/chat_model.dart';
import 'package:resq360/features/customer/chat/screens/service_detail_screen.dart';
import 'package:resq360/features/customer/chat/widgets/chat_invoice_card_widget.dart';
import 'package:resq360/features/widgets/chat_box_widget.dart';
import 'package:resq360/features/widgets/chat_bubble.dart';
import 'package:resq360/features/widgets/dialogs/complete_payment_option.dialog.dart';
import 'package:resq360/features/widgets/dialogs/payment_option.dialog.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({required this.chat, super.key});

  final ChatResponse chat;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  Timer? _pollingTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMessages();

    // 🔁 Poll every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchMessages();
    });
  }

  void _fetchMessages() {
    context.read<CustomerChatBloc>().add(
      GetChatMessagesEvent(chatId: widget.chat.id.toString()),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appColors.whiteColor,
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.black),
          onPressed: () => pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage(
                AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
              ),
              radius: 25,
            ),
            8.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GenText(
                  widget.chat.title ?? 'QuickTow Emergency',
                  weight: FontWeight.w500,
                  color: appColors.black,
                ),
                GenText(
                  'Online',
                  size: 13,
                  color: appColors.success.shade600,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: AppAssets.ASSETS_ICONS_PHONE_ICON_SVG.svg,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const ListDivider(),
            Expanded(
              child: BlocBuilder<CustomerChatBloc, CustomerChatState>(
                builder: (context, state) {
                  if (state is CustomerChatLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CustomerChatErrorState) {
                    return Center(
                      child: GenText(state.message, color: appColors.error),
                    );
                  }

                  if (state is MessagesLoaded) {
                    final messages = state.messages.messages;
                    if (messages.isEmpty) {
                      return const Center(
                        child: GenText(
                          'No messages yet. Start the conversation!',
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        bottom: 50.h,
                        top: 10.h,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final message = messages[index];
                        return Column(
                          children: [
                            ChatBubble(
                              type:
                                  message.messageType == 'USER'
                                      ? MessageType.sent
                                      : MessageType.received,
                              message: message.content!,
                              time: formatMessageTime(
                                message.createdAt.toString(),
                              ),
                            ),
                            20.verticalSpace,
                          ],
                        );
                      },

                      // children: [
                      //   ChatInvoiceCardWidget(
                      //     onTapPay: () async {
                      //       await GeneralDialogs.showCustomDialog(
                      //         context,
                      //         body: PaymentOptionDialog(
                      //           onPaymentSelected: (option) async {
                      //             await GeneralDialogs.showCustomDialog(
                      //               context,
                      //               body: const CompletePaymentDialog(
                      //                 amount: '₦15,0000',
                      //               ),
                      //             );
                      //           },
                      //         ),
                      //       );
                      //     },
                      //   ),
                      //   20.verticalSpace,
                      //   const ChatBubble(
                      //     type: MessageType.received,
                      //     message:
                      //         '''Hi! I'm Jacob from QuickTow. I see you need towing assistance. Can you tell me your location and what type of vehicle needs to be towed?''',
                      //     time: '2:50 pm',
                      //   ),
                      //   20.verticalSpace,
                      //   const ChatBubble(
                      //     type: MessageType.sent,
                      //     message:
                      //         '''Hi Jacob! My car broke down on Gwarimpa highway. It's a 2018 Honda Civic. The engine just stopped working.''',
                      //     time: '2:50 pm',
                      //   ),
                      //   30.verticalSpace,
                      //   GestureDetector(
                      //     onTap: () async {
                      //       await pushScreen(
                      //         context,
                      //         const ServiceDetailScreen(),
                      //       );
                      //     },
                      //     child: GenText(
                      //       'View Service details',
                      //       weight: FontWeight.w500,
                      //       color: appColors.primary.shade500,
                      //       decoration: TextDecoration.underline,
                      //       textAlign: TextAlign.center,
                      //     ),
                      //   ),
                      // ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            ChatBoxWidget(
              onAttachment: () => _showAttachmentMenu(context),
              onSend: (text) {
                context.read<CustomerChatBloc>().add(
                  SendMessageEvent(
                    messageRequest: SendMessageRequest(
                      chatId: widget.chat.id!,
                      messageType: 'TEXT',
                      content: text,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Format message time safely
  String formatMessageTime(String? createdAt) {
    if (createdAt == null) return '';
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return '';
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showAttachmentMenu(BuildContext context) async {
    final button = context.findRenderObject()! as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, 800.h), ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      items: [
        PopupMenuItem<String>(
          value: 'media',
          child: Row(
            children: [
              const GenText('Media'),
              70.horizontalSpace,
              AppAssets.ASSETS_ICONS_ATTACH_IMAGE_SVG.svg,
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'location',
          child: Row(
            children: [
              const GenText('Location'),
              55.horizontalSpace,
              AppAssets.ASSETS_ICONS_ATTACH_LOCATION_SVG.svg,
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'document',
          child: Row(
            children: [
              const GenText('Document'),
              45.horizontalSpace,
              AppAssets.ASSETS_ICONS_ATTACH_DOC_SVG.svg,
            ],
          ),
        ),
      ],
    ).then((String? result) {
      if (result != null) {
        switch (result) {
          case 'media':
            _onMediaTap();
          case 'location':
            _onLocationTap();
          case 'document':
            _onDocumentTap();
        }
      }
    });
  }

  void _onMediaTap() {}

  void _onLocationTap() {}

  void _onDocumentTap() {}
}
