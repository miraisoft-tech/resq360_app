import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/authentication/view_models/auth_vm.dart';
import 'package:resq360/features/customer/chat/data/bloc/customer_chat_bloc.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_models.dart';
import 'package:resq360/features/widgets/chat_box_widget.dart';
import 'package:resq360/features/widgets/chat_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({required this.chat, super.key});

  final ChatResponse chat;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  Timer? _pollingTimer;
  final ScrollController _scrollController = ScrollController();
  bool _isFetching = false;
  @override
  void initState() {
    super.initState();
    _fetchMessages();

    // 🔁 Poll every 5 seconds safely
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isFetching) _fetchMessages();
    });
  }

  void _fetchMessages() {
    if (_isFetching) return; // 👈 guard
    _isFetching = true;

    context.read<CustomerChatBloc>().add(
      GetChatMessagesEvent(chatId: widget.chat.id!),
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
            Expanded(
              child: Column(
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
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.amber,
                      ),
                    );
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
                        final auth = CustomerAuthProvider.instance.authInfo;
                        final currentUserId = auth?.user.id;

                        // Determine if message was sent by current logged-in user
                        final isSentByCurrentUser =
                            message.senderType?.toUpperCase() == 'USER' &&
                            message.senderId == currentUserId;
                        return Column(
                          children: [
                            ChatBubble(
                              type:
                                  isSentByCurrentUser
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
              onAttachment: (file, fileName, mimeType) {
                context.read<CustomerChatBloc>().add(
                  SendMessageEvent(
                    messageRequest: SendMessageRequest(
                      chatId: widget.chat.id!,
                      messageType: 'FILE',
                      fileName: fileName,
                      mimeType: mimeType,
                      content: '',
                      // You'll likely upload the file first to get fileUrl:
                      // fileUrl: uploadedFileUrl,
                      // fileSize: file.lengthSync(),
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

  // void _onMediaTap() {}

  // void _onLocationTap() {}

  // void _onDocumentTap() {}
}
