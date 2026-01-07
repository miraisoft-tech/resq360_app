// import 'dart:async';

// 
// import 'package:resq360/__lib.dart';
// import 'package:resq360/core/bloc/general-chat-bloc/chat_bloc.dart';
// import 'package:resq360/features/customer/chat/data/models/chat/chat_response.dart';
// import 'package:resq360/features/customer/chat/data/models/chat/message_response.dart';
// import 'package:resq360/features/customer/chat/data/models/chat/send_message_request.dart';
// import 'package:resq360/features/provider/authentication/view_models/auth_vm.dart';
// import 'package:resq360/features/provider/chat/screens/provider_generate_invoice.dialog.dart';
// import 'package:resq360/features/provider/chat/widgets/provider_chat_invoice_card_widget.dart';
// import 'package:resq360/features/widgets/chat_box_widget.dart';
// import 'package:resq360/features/widgets/chat_bubble.dart';
// import 'package:resq360/features/widgets/dialogs/complete_payment_option.dialog.dart';
// import 'package:resq360/features/widgets/dialogs/payment_option.dialog.dart';

// class ProviderChatDetailScreen extends StatefulWidget {
//   const ProviderChatDetailScreen({required this.chat, super.key});

//   final ChatResponse chat;

//   @override
//   State<ProviderChatDetailScreen> createState() =>
//       _ProviderChatDetailScreenState();
// }

// class _ProviderChatDetailScreenState extends State<ProviderChatDetailScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final List<MessageResponse> _messages = [];
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       unawaited(_initializeChat());
//     });
//   }

//   Future<void> _initializeChat() async {
//     final chatBloc = context.read<ChatBloc>()..add(ConnectChatSocketEvent());
//     Future.delayed(const Duration(milliseconds: 300), () {
//       chatBloc.add(GetChatMessagesEvent(chatId: widget.chat.id!));
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final appColors = context.appColors;
//     final auth = ProviderAuthProvider.instance.authInfo;
//     final currentUserId = auth?.user.id;

//     final displayTitle = getChatDisplayTitle(widget.chat, currentUserId!);

//     return Scaffold(
//       backgroundColor: appColors.whiteColor,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: appColors.whiteColor,
//         forceMaterialTransparency: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: appColors.black),
//           onPressed: () => pop(context),
//         ),
//         title: Row(
//           children: [
//             const CircleAvatar(
//               backgroundImage: AssetImage(
//                 AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
//               ),
//               radius: 25,
//             ),
//             8.horizontalSpace,
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   GenText(
//                     displayTitle,
//                     weight: FontWeight.w500,
//                     color: appColors.black,
//                   ),
//                   GenText(
//                     'Online',
//                     size: 13,
//                     color: appColors.success.shade600,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: AppAssets.ASSETS_ICONS_PHONE_ICON_SVG.svg,
//           ),
//         ],
//       ),
//       body: BlocConsumer<ChatBloc, ChatState>(
//         listener: (context, state) {
//           if (state is ChatSocketConnected) {
//             context.read<ChatBloc>().add(JoinChatEvent(widget.chat.id!));
//           }
//           if (state is NewMessageState) {
//             setState(() => _messages.insert(0, state.message));
//             _scrollToBottom();
//           }
//           if (state is MessagesLoaded) {
//             setState(() {
//               _messages
//                 ..clear()
//                 ..addAll(state.messages.messages.reversed);
//             });
//             _scrollToBottom();
//           }
//           if (state is MessageSent) {
//             setState(() {
//               _messages.insert(0, state.message);
//             });
//             _scrollToBottom();
//           }
//         },
//         builder: (context, state) {
//           if (state is FetchingMessagesState && _messages.isEmpty) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           return SafeArea(
//             child: Column(
//               children: [
//                 const ListDivider(),
//                 Expanded(
//                   child: ListView.builder(
//                     reverse: true,
//                     padding: EdgeInsets.only(
//                       left: 16.w,
//                       right: 16.w,
//                       bottom: 50.h,
//                       top: 10.h,
//                     ),
//                     itemCount: _messages.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       final message = _messages[index];

//                       final senderType = message.senderType?.toUpperCase();
//                       final senderId = message.senderId;
//                       // log(
//                       //   'senderType: $senderType, senderId: $senderId, currentUserId: $currentUserId, content: ${message.content}',
//                       // );

//                       String? content;

//                       if (message.content != null) {
//                         content = message.content;
//                       }

//                       // log('content: $content');
//                       final isSentByCurrentUser =
//                           senderType == 'PROVIDER' && senderId == currentUserId;
//                       // log(
//                       //   'current user $currentUserId and message sender ${message.senderId}',
//                       // );

//                       final amount = message.metadata?.amount?.toString() ?? '';
                     
//                       return Column(
//                         children: [
//                           if (message.messageType == 'TEXT')
//                             ChatBubble(
//                               type:
//                                   isSentByCurrentUser
//                                       ? MessageType.sent
//                                       : MessageType.received,
//                               message: content ?? '',
//                               time: formatMessageTime(
//                                 message.createdAt?.toIso8601String() ?? '',
//                               ),
//                             )
//                           else if (message.messageType == 'SYSTEM')
//                             ProviderChatInvoiceCardWidget(
//                               onTapPay: () async {
//                                 await GeneralDialogs.showCustomDialog<void>(
//                                   context,
//                                   body: PaymentOptionDialog(
//                                     onPaymentSelected: (option) async {
//                                       await GeneralDialogs.showCustomDialog<void>(
//                                         context,
//                                         body: CompletePaymentDialog(
//                                           amount: amount,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 );
//                               },
//                               paymentStatus: PaymentStatus.pending, metadata: message.metadata!, messageCreatedAt: formatMessageTime(
//                                 message.createdAt?.toIso8601String() ?? '',
//                               ),
//                             ),
//                           20.verticalSpace,
//                         ],
//                       );
//                     },
//                     // children: [
//                     //   ProviderChatInvoiceCardWidget(
//                     //     onTapPay: () async {
//                     //       await GeneralDialogs.showCustomDialog<void>(
//                     //         context,
//                     //         body: PaymentOptionDialog(
//                     //           onPaymentSelected: (option) async {
//                     //             await GeneralDialogs.showCustomDialog<void>(
//                     //               context,
//                     //               body: const CompletePaymentDialog(
//                     //                 amount: '₦15,0000',
//                     //               ),
//                     //             );
//                     //           },
//                     //         ),
//                     //       );
//                     //     },
//                     //   ),
//                     //   20.verticalSpace,
//                     //   const ChatBubble(
//                     //     type: MessageType.received,
//                     //     message:
//                     //         '''Hi! I'm Jacob from QuickTow. I see you need towing assistance. Can you tell me your location and what type of vehicle needs to be towed?''',
//                     //     time: '2:50 pm',
//                     //   ),
//                     //   20.verticalSpace,
//                     //   const ChatBubble(
//                     //     type: MessageType.sent,
//                     //     message:
//                     //         '''Hi Jacob! My car broke down on Gwarimpa highway. It's a 2018 Honda Civic. The engine just stopped working.''',
//                     //     time: '2:50 pm',
//                     //   ),
//                     // 30.verticalSpace,
//                     // GestureDetector(
//                     //   onTap: () async {
//                     //     await pushScreen(context, const ServiceDetailScreen());
//                     //   },
//                     //   child: GenText(
//                     //     'View Service details',
//                     //     weight: FontWeight.w500,
//                     //     color: appColors.primary.shade500,
//                     //     decoration: TextDecoration.underline,
//                     //     textAlign: TextAlign.center,
//                     //   ),
//                     // ),
//                     // ],
//                   ),
//                 ),
//                 ChatBoxWidget(
//                   onAttachment: () async {
//                     await _showAttachmentMenu(context, widget.chat);
//                   },
//                   onSend: (text) {
//                     if (text.trim().isNotEmpty) {
//                       final localMessage = MessageResponse(
//                         id: DateTime.now().millisecondsSinceEpoch * -1,
//                         chatId: widget.chat.id,
//                         senderType: 'PROVIDER',
//                         senderId: currentUserId,
//                         messageType: 'TEXT',
//                         content: text,
//                         createdAt: DateTime.now(),
//                       );
//                       final request = SendMessageRequest(
//                         chatId: widget.chat.id!,
//                         messageType: 'TEXT',
//                         content: text.trim(),
//                       );
//                       context.read<ChatBloc>().add(
//                         SendMessageEvent(
//                           messageRequest: request,
//                           localMessage: localMessage,
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _showAttachmentMenu(
//     BuildContext context,
//     ChatResponse? chat,
//   ) async {
//     final button = context.findRenderObject()! as RenderBox;
//     final overlay =
//         Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
//     final position = RelativeRect.fromRect(
//       Rect.fromPoints(
//         button.localToGlobal(Offset(0, 800.h), ancestor: overlay),
//         button.localToGlobal(
//           button.size.bottomRight(Offset.zero),
//           ancestor: overlay,
//         ),
//       ),
//       Offset.zero & overlay.size,
//     );

//     await showMenu<String>(
//       context: context,
//       position: position,
//       color: Colors.white,
//       items: [
//         PopupMenuItem<String>(
//           value: 'media',
//           child: Row(
//             children: [
//               const GenText('Media'),
//               70.horizontalSpace,
//               AppAssets.ASSETS_ICONS_ATTACH_IMAGE_SVG.svg,
//             ],
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'location',
//           child: Row(
//             children: [
//               const GenText('Location'),
//               50.horizontalSpace,
//               AppAssets.ASSETS_ICONS_ATTACH_LOCATION_SVG.svg,
//             ],
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'document',
//           child: Row(
//             children: [
//               const GenText('Document'),
//               45.horizontalSpace,
//               AppAssets.ASSETS_ICONS_ATTACH_DOC_SVG.svg,
//             ],
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'invoice',
//           child: Row(
//             children: [
//               const GenText('Generate Invoice'),
//               5.horizontalSpace,
//               AppAssets.ASSETS_ICONS_ATTACH_INVOICE_SVG.svg,
//             ],
//           ),
//         ),
//       ],
//     ).then((String? result) async {
//       if (!context.mounted) return;

//       if (result != null) {
//         switch (result) {
//           case 'media':
//             _onMediaTap();
//           case 'location':
//             _onLocationTap();
//           case 'document':
//             _onDocumentTap();
//           case 'invoice':
//             await _onInvoiceTap(context, chat!);
//         }
//       }
//     });
//   }

//   void _onMediaTap() {}

//   void _onLocationTap() {}

//   void _onDocumentTap() {}

//   Future<void> _onInvoiceTap(BuildContext context, ChatResponse chat) async {
//     await GeneralDialogs.showCustomDialog<void>(
//       context,
//       body: ProviderGenerateInvoiceDialog(
//         chat: chat,
//       ),
//     );
//   }

//   String formatMessageTime(String? createdAt) {
//     if (createdAt == null) return '';
//     final dt = DateTime.tryParse(createdAt);
//     if (dt == null) return '';
//     return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
//   }

//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 300), () async {
//       if (_scrollController.hasClients) {
//         await _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 250),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   String getChatDisplayTitle(ChatResponse chat, int viewerId) {
//     final participants = chat.participants ?? [];
//     final other = participants.firstWhere(
//       (p) => p.participantId != viewerId,
//       orElse: () => participants.first,
//     );
//     if (other.participantType == 'PROVIDER') {
//       return other.role ?? 'Provider';
//     } else {
//       return 'User';
//     }
//   }
// }
import 'dart:async';


import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/general-chat-bloc/chat_details_bloc/bloc/chat_details_bloc.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_models.dart';
import 'package:resq360/features/provider/authentication/view_models/auth_vm.dart';
import 'package:resq360/features/provider/chat/screens/provider_generate_invoice.dialog.dart';
import 'package:resq360/features/provider/chat/widgets/provider_chat_invoice_card_widget.dart';
import 'package:resq360/features/widgets/chat_box_widget.dart';
import 'package:resq360/features/widgets/chat_bubble.dart';
import 'package:resq360/features/widgets/dialogs/complete_payment_option.dialog.dart';
import 'package:resq360/features/widgets/dialogs/payment_option.dialog.dart';

class ProviderChatDetailScreen extends StatelessWidget {
  const ProviderChatDetailScreen({required this.chatId, super.key});

  final int chatId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatDetailBloc(chatId: chatId)
        ..add(OpenChatDetail(chatId)),
      child: _ProviderChatDetailView(chatId),
    );
  }
}

class _ProviderChatDetailView extends StatefulWidget {
  const _ProviderChatDetailView(this.chatId);

  final int chatId;
  @override
  State<_ProviderChatDetailView> createState() => _ProviderChatDetailViewState();
}

class _ProviderChatDetailViewState extends State<_ProviderChatDetailView> {
  final ScrollController _scrollController = ScrollController();

  int? get _currentUserId =>
      ProviderAuthProvider.instance.authInfo?.id;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final appColors = context.appColors;

  return BlocConsumer<ChatDetailBloc, ChatDetailState>(
    listener: _onChatStateChanged,
    builder: (context, state) {
      return Scaffold(
        backgroundColor: appColors.whiteColor,
        appBar: _buildAppBar(
          state is ChatDetailReady 
              ? (state.chat.title ?? 'Chat')
              : 'Chat',
        ),
        body: SafeArea(
          child: Column(
            children: [
              const ListDivider(),
              Expanded(
                child: _buildChatContent(state),
              ),
              IgnorePointer(
                ignoring: state is! ChatDetailReady,
                child: Opacity(
                  opacity: state is ChatDetailReady ? 1.0 : 0.5,
                  child: ChatBoxWidget(
                    onAttachment: () async {
                      if (state is ChatDetailReady) {
                        await _showAttachmentMenu(context, state.chat);
                      }
                    },
                    onSend: (text) {
                      final userid = _currentUserId;
                      if (text.trim().isNotEmpty && 
                          userid != null && 
                          state is ChatDetailReady) {
                        context.read<ChatDetailBloc>().add(
                          SendTextMessage(text, userid, 'PROVIDER'),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildChatContent(ChatDetailState state) {
  final appColors = context.appColors;
  
  if (state is ChatDetailLoading) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          16.verticalSpace,
          GenText(
            'Loading messages...',
            color: appColors.neutral.shade400,
          ),
        ],
      ),
    );
  }

  if (state is ChatDetailFailure) {
    return ErrorMessageAndButton(
      error: state.error,
      onPressed: () => context.read<ChatDetailBloc>().add(
        OpenChatDetail(widget.chatId),
      ),
    );
  }

  if (state is ChatDetailReady) {
    return _MessageList(
      controller: _scrollController,
      messages: state.messages,
      currentUserId: _currentUserId,
      chat: state.chat,
    );
  }

  return const SizedBox.shrink();
}

  PreferredSizeWidget _buildAppBar(String title) {
    final appColors = context.appColors;

    return AppBar(
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
            backgroundImage:
                AssetImage(AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG),
            radius: 22,
          ),
          8.horizontalSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GenText(
                title,
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
          onPressed: () {
          },
          icon: AppAssets.ASSETS_ICONS_PHONE_ICON_SVG.svg,
        ),
      ],
    );
  }

  void _onChatStateChanged(
    BuildContext context,
    ChatDetailState state,
  ) {
    if (state is ChatDetailReady) {
      _scrollToBottom();
    }
    // if(state is MessageSent ){}
  }

  Future<void> _showAttachmentMenu(BuildContext context, ChatResponse chat) async {
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
            await _onInvoiceTap(context, chat);
        }
      }
    });
  }

  void _onMediaTap() {
  }

  void _onLocationTap() {
  }

  void _onDocumentTap() {
  }

  Future<void> _onInvoiceTap(BuildContext context, ChatResponse chat) async {
    await GeneralDialogs.showCustomDialog<void>(
      context,
      body: BlocProvider.value(
        value: context.read<ChatDetailBloc>(),
        child: ProviderGenerateInvoiceDialog(
          chat: chat,
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.controller,
    required this.messages,
    required this.currentUserId,
    required this.chat,
  });

  final ScrollController controller;
  final List<MessageResponse> messages;
  final int? currentUserId;
  final ChatResponse chat;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      reverse: true,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 50.h),
      itemCount: messages.length,
      itemBuilder: (_, index) {
        final message = messages[index];
        final isMine =
            message.senderType == 'PROVIDER' &&
            message.senderId == currentUserId;

        if (message.messageType == 'SYSTEM') {
          return Column(
            children: [
              ProviderChatInvoiceCardWidget(
                metadata: message.metadata!,
                message: message,
                chat: chat,
                paymentStatus: chat.paymentStatus == PaymentStatus.paid.name ? PaymentStatus.paid :PaymentStatus.pending  ,
                onTapPay: () => _handleInvoicePayment(context, message),
              ),
              20.verticalSpace,
            ],
          );
        }

        return Column(
          children: [
            ChatBubble(
              type: isMine
                  ? MessageType.sent
                  : MessageType.received,
              message: message.content ?? '',
              time: _formatTime(message.createdAt!),
            ),
            20.verticalSpace,
          ],
        );
      },
    );
  }

  Future<void> _handleInvoicePayment(BuildContext context, MessageResponse message) async {
    final amount = message.metadata?.amount?.toString() ?? '';
    
    await GeneralDialogs.showCustomDialog<void>(
      context,
      body: PaymentOptionDialog(
        onPaymentSelected: (option) async {
          await GeneralDialogs.showCustomDialog<void>(
            context,
            body: CompletePaymentDialog(
              amount: amount,
            ),
          );
        },
      ),
    );
  }


  String _formatTime(DateTime dt) =>
      '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}
