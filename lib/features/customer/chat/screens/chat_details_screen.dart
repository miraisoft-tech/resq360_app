import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/general-chat-bloc/chat_bloc.dart';
import 'package:resq360/features/customer/authentication/view_models/auth_vm.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_models.dart';
import 'package:resq360/features/customer/chat/screens/payment_completed.dialog.dart';
import 'package:resq360/features/customer/chat/widgets/chat_invoice_card_widget.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/payment_bloc/customer_payment_bloc.dart';
import 'package:resq360/features/customer/dashboard/screens/paystack_webview.dart';
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
  final ScrollController _scrollController = ScrollController();
  final List<MessageResponse> _messages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeChat());
    });
  }

  Future<void> _initializeChat() async {
    final chatBloc = context.read<ChatBloc>()..add(ConnectChatSocketEvent());

    Future.delayed(const Duration(milliseconds: 300), () {
      chatBloc.add(GetChatMessagesEvent(chatId: widget.chat.id!));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final auth = CustomerAuthProvider.instance.authInfo;
    final currentUserId = auth?.user.id;

    return BlocListener<CustomerPaymentBloc, CustomerPaymentState>(
      listener: (context, state) async {
        if (state is CustomerPaymentSuccessState) {
          final url = state.payment.authorizationUrl;
          final reference = state.payment.reference;
          if (!mounted) return;
          final finished = await Navigator.of(
            context,
            rootNavigator: true,
          ).push<bool>(
            MaterialPageRoute(
              builder:
                  (_) => PaystackWebViewPage(
                    authorizationUrl: url,
                    reference: reference,
                    callbackUrl: 'https://example.com/callback',
                  ),
            ),
          );

          log(finished.toString());

          if (!mounted) return;
          // // If finished is true -> trigger verification
          if (finished ?? false) {
            context.read<CustomerPaymentBloc>().add(
              CustomerVerifyPaymentEvent(reference),
            );
          } else {
            await showErrorSnackbar(context, 'Payment cancelled');
          }
        }

        if (state is CustomerPaymentVerifiedState) {
          await GeneralDialogs.showCustomDialog(
            context,
            body: const PaymentCompleted(),
          );
          context.read<ChatBloc>().add(
            GetChatMessagesEvent(chatId: widget.chat.id!),
          );
        }

        if (state is CustomerPaymentFailureState) {
          await showErrorSnackbar(context, state.error);
        }
      },
      child: Scaffold(
        backgroundColor: appColors.whiteColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appColors.whiteColor,
          forceMaterialTransparency: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: appColors.black),
            onPressed: () => pop(context, {'refresh': true}),
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
            if (state is FetchingMessagesState && _messages.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChatErrorState) {
              return ErrorMessageAndButton(error: state.error);
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

                        // log(message.senderType?.toUpperCase());

                        final isSentByCurrentUser =
                            message.senderType?.toUpperCase() == 'USER' &&
                            message.senderId == currentUserId;
                        // log(
                        //   'current user $currentUserId and message sender ${message.senderId}',
                        // );
                        final amount =
                            message.metadata?.amount?.toString() ?? '';
                        return Column(
                          children: [
                            if (message.messageType == 'TEXT')
                              ChatBubble(
                                type:
                                    isSentByCurrentUser
                                        ? MessageType.sent
                                        : MessageType.received,
                                message: message.content!,
                                time: formatMessageTime(
                                  message.createdAt.toString(),
                                ),
                              )
                            else if (message.messageType == 'SYSTEM')
                              ChatInvoiceCardWidget(
                                onTapPay: () async {
                                  await GeneralDialogs.showCustomDialog(
                                    context,
                                    body: PaymentOptionDialog(
                                      onPaymentSelected: (option) async {
                                        await GeneralDialogs.showCustomDialog(
                                          context,
                                          body: ClientPaymentConfirmDialog(
                                            amount: int.parse(amount),
                                            title: 'Quick Tow Emergency',
                                            invoiceNumber:
                                                message.metadata!.invoiceNo!,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                metadata: message.metadata!,
                                messageCreatedAt: formatMessageTime(
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
                    onAttachment: () {
                      unawaited(_showAttachmentMenu(context));
                    },
                    onSend: (text) {
                      if (text.trim().isNotEmpty) {
                        // still waiting for response from BE on how they send notification.
                        final localMessage = MessageResponse(
                          id: DateTime.now().millisecondsSinceEpoch * -1,
                          chatId: widget.chat.id,
                          senderType: 'USER',
                          senderId: currentUserId,
                          messageType: 'TEXT',
                          content: text,
                          createdAt: DateTime.now(),
                        );
                        final request = SendMessageRequest(
                          chatId: widget.chat.id!,
                          messageType: 'TEXT',
                          content: text,
                        );
                        context.read<ChatBloc>().add(
                          SendMessageEvent(
                            messageRequest: request,
                            localMessage: localMessage,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
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
          _scrollController.position.minScrollExtent,
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
