import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/general-chat-bloc/chat_bloc.dart';
import 'package:resq360/features/customer/authentication/view_models/auth_vm.dart';
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
  final ScrollController _scrollController = ScrollController();
  final List<MessageResponse> _messages = [];
  bool _isFetching = false;
  @override
  void initState() {
    super.initState();
    // 🔌 Connect socket and join the chat room
    context.read<ChatBloc>().add(ConnectChatSocketEvent());
    context.read<ChatBloc>().add(
      GetChatMessagesEvent(chatId: widget.chat.id!),
    );
    _fetchMessages();
  }

  void _fetchMessages() {
    if (_isFetching) return;
    _isFetching = true;

    context.read<ChatBloc>().add(
      GetChatMessagesEvent(chatId: widget.chat.id!),
    );
  }

  @override
  void dispose() {
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
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is NewMessageState) {
            setState(() => _messages.insert(0, state.message));
            _scrollToBottom();
          }
          if (state is MessagesLoaded) {
            setState(() {
              _messages
                ..clear()
                ..addAll(state.messages.messages.reversed);
            });
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          // 🌀 Show loading only for fetching messages
          if (state is FetchingMessagesState && _messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            child: Column(
              children: [
                const ListDivider(),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      bottom: 50.h,
                      top: 10.h,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final message = _messages[index];
                      final auth = CustomerAuthProvider.instance.authInfo;
                      final currentUserId = auth?.user.id;
                      log(message.senderType?.toUpperCase());

                      // Determine if message was sent by current logged-in user
                      final isSentByCurrentUser =
                          message.senderType?.toUpperCase() == 'USER' &&
                          message.senderId == currentUserId;
                      log(
                        'current user $currentUserId and message sender ${message.senderId}',
                      );
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
                  ),
                ),

                ChatBoxWidget(
                  onAttachment: (file, fileName, mimeType) {},
                  onSend: (text) {
                    if (text.trim().isNotEmpty) {
                      final request = SendMessageRequest(
                        chatId: widget.chat.id!,
                        messageType: 'TEXT',
                        content: text.trim(),
                      );
                      context.read<ChatBloc>().add(
                        SendMessageEvent(messageRequest: request),
                      );
                    }
                  },
                ),

                // ChatBoxWidget(
                //   onSend: (text) {
                //     context.read<ChatBloc>().add(
                //       SendMessageEvent(
                //         messageRequest: SendMessageRequest(
                //           chatId: widget.chat.id!,
                //           messageType: 'TEXT',
                //           content: text,
                //         ),
                //       ),
                //     );
                //   },
                //   onAttachment: (file, fileName, mimeType) {
                //     context.read<ChatBloc>().add(
                //       SendMessageEvent(
                //         messageRequest: SendMessageRequest(
                //           chatId: widget.chat.id!,
                //           messageType: 'FILE',
                //           fileName: fileName,
                //           mimeType: mimeType,
                //           content: '',
                //           // You'll likely upload the file first to get fileUrl:
                //           // fileUrl: uploadedFileUrl,
                //           // fileSize: file.lengthSync(),
                //         ),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          );
        },
      ),
    );
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

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
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
