import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/general-chat-bloc/chat_bloc.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_response.dart';
import 'package:resq360/features/customer/chat/data/models/chat/message_response.dart';
import 'package:resq360/features/customer/chat/data/models/chat/send_message_request.dart';
import 'package:resq360/features/provider/authentication/view_models/auth_vm.dart';
import 'package:resq360/features/provider/chat/screens/provider_generate_invoice.dialog.dart';
import 'package:resq360/features/widgets/chat_box_widget.dart';
import 'package:resq360/features/widgets/chat_bubble.dart';


class ProviderChatDetailScreen extends StatefulWidget {
  const ProviderChatDetailScreen({required this.chat, super.key});

  final ChatResponse chat;

  @override
  State<ProviderChatDetailScreen> createState() =>
      _ProviderChatDetailScreenState();
}

class _ProviderChatDetailScreenState extends State<ProviderChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<MessageResponse> _messages = [];
  // bool _isFetching = false;

  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeChat();
  });
  }

  Future<void> _initializeChat() async {
    final chatBloc = context.read<ChatBloc>()
    ..add(ConnectChatSocketEvent());

     await Future.delayed(const Duration(milliseconds: 300));
    chatBloc.add(GetChatMessagesEvent(chatId: widget.chat.id!));
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
          if (state is ChatSocketConnected) {
            context.read<ChatBloc>().add(JoinChatEvent(widget.chat.id!));
          }
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
            if (state is MessageSent) {
            setState(() {
              _messages.insert(0, state.message);
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
                      final auth = ProviderAuthProvider.instance.authInfo;
                      final currentUserId = auth?.user.id?.toString();

                      final senderType = message.senderType?.toUpperCase();
                      final senderId = message.senderId?.toString();
                      log(
                        'senderType: $senderType, senderId: $senderId, currentUserId: $currentUserId, content: ${message.content}',
                      );

                      String? content;

                      if (message.content != null) {
                        content = message.content;
                      }

                      log('content: $content');
                      // Determine if message was sent by current logged-in user
                      final isSentByCurrentUser =
                          senderType == 'PROVIDER' && senderId == currentUserId;
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
                            message: content ?? '',
                            time: formatMessageTime(
                              message.createdAt.toString(),
                            ),
                          ),
                          20.verticalSpace,
                        ],
                      );
                    },
                    // children: [
                    //   ProviderChatInvoiceCardWidget(
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
                    // 30.verticalSpace,
                    // GestureDetector(
                    //   onTap: () async {
                    //     await pushScreen(context, const ServiceDetailScreen());
                    //   },
                    //   child: GenText(
                    //     'View Service details',
                    //     weight: FontWeight.w500,
                    //     color: appColors.primary.shade500,
                    //     decoration: TextDecoration.underline,
                    //     textAlign: TextAlign.center,
                    //   ),
                    // ),
                    // ],
                  ),
                ),
                ChatBoxWidget(
                  onAttachment: () async {
                    await _showAttachmentMenu(context);
                  },
                  // () => _showAttachmentMenu(context),
                  onSend: (text) {
                    if (text.trim().isNotEmpty) {
                      final request = SendMessageRequest(
                        chatId: widget.chat.id!,
                        messageType: 'TEXT',
                        content: text.trim(),
                      );
                      context.read<ChatBloc>().add(SendMessageEvent(messageRequest: request),);
                    }
                  },
                ),
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
              50.horizontalSpace,
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
        PopupMenuItem<String>(
          value: 'invoice',
          child: Row(
            children: [
              const GenText('Generate Invoice'),
              5.horizontalSpace,
              AppAssets.ASSETS_ICONS_ATTACH_INVOICE_SVG.svg,
            ],
          ),
        ),
      ],
    ).then((String? result) async {
      if (!context.mounted) return;

      if (result != null) {
        switch (result) {
          case 'media':
            _onMediaTap();
          case 'location':
            _onLocationTap();
          case 'document':
            _onDocumentTap();
          case 'invoice':
            await _onInvoiceTap(context);
        }
      }
    });
  }

  void _onMediaTap() {}

  void _onLocationTap() {}

  void _onDocumentTap() {}

  Future<void> _onInvoiceTap(
    BuildContext context,
  ) async {
    await GeneralDialogs.showCustomDialog(
      context,
      body: const ProviderGenerateInvoiceDialog(),
    );
  }

  String formatMessageTime(String? createdAt) {
    if (createdAt == null) return '';
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return '';
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

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
}
