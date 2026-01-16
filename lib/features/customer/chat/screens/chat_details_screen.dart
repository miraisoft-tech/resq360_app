import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/general-chat-bloc/chat_details_bloc/bloc/chat_details_bloc.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/core/utils/dialer_util.dart';
import 'package:resq360/features/customer/authentication/view_models/customer_auth_vm.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_models.dart';
import 'package:resq360/features/customer/chat/screens/payment_completed.dialog.dart';
import 'package:resq360/features/customer/chat/widgets/chat_invoice_card_widget.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/payment_bloc/customer_payment_bloc.dart';
import 'package:resq360/features/customer/dashboard/screens/paystack_webview.dart';
import 'package:resq360/features/provider/chat/data/models/message_type.enum.dart';
import 'package:resq360/features/widgets/chat_box_widget.dart';
import 'package:resq360/features/widgets/chat_bubble.dart';
import 'package:resq360/features/widgets/dialogs/complete_payment_option.dialog.dart';
import 'package:resq360/features/widgets/dialogs/payment_option.dialog.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({required this.chatId, super.key});

  final int chatId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => ChatDetailBloc(chatId: chatId)..add(OpenChatDetail(chatId)),
      child: _ChatDetailView(chatId),
    );
  }
}

class _ChatDetailView extends StatefulWidget {
  const _ChatDetailView(this.chatId);
  final int chatId;

  @override
  State<_ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<_ChatDetailView> {
  final ScrollController _scrollController = ScrollController();

  int? get _currentUserId => CustomerAuthProvider.instance.authInfo?.id;

  int _previousMessageCount = 0;
  bool _showJumpButton = false;
  bool _hasScrolledToBottomOnce = false;

  bool _isRequestingMore = false;
  double? _beforeLoadMaxScrollExtent;
  double? _beforeLoadOffset;
  bool _pendingOlderMessagesInsert = false;

  bool _isAtBottom() {
    if (!_scrollController.hasClients) return false;
    final currentScroll = _scrollController.offset;
    return currentScroll <= 50;
  }

  Future<void> _scrollToBottom() async {
    if (!_scrollController.hasClients) return;

    await _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );

    if (!mounted) return;

    setState(() {
      _showJumpButton = false;
      _hasScrolledToBottomOnce = true;
    });
  }

  void _requestLoadMore() {
    if (_isRequestingMore || !_scrollController.hasClients) return;

    _isRequestingMore = true;
    _beforeLoadMaxScrollExtent = _scrollController.position.maxScrollExtent;
    _beforeLoadOffset = _scrollController.offset;
    _pendingOlderMessagesInsert = true;

    context.read<ChatDetailBloc>().add(LoadMoreMessages());
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final atBottomNow = _isAtBottom();
      if (mounted && _showJumpButton != !atBottomNow) {
        setState(() {
          _showJumpButton = !atBottomNow;
        });
      }

      final position = _scrollController.position;
      if (_hasScrolledToBottomOnce &&
          position.pixels >= position.maxScrollExtent - 80) {
        _requestLoadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await CustomerAuthProvider.instance.init();
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

    return MultiBlocListener(
      listeners: [
        BlocListener<CustomerPaymentBloc, CustomerPaymentState>(
          listener: _handlePaymentState,
        ),
      ],
      child: BlocConsumer<ChatDetailBloc, ChatDetailState>(
        listener: _onChatStateChanged,
        builder: (context, state) {
          var title = '';
          var isActive = false;
          var phone = '';
          var imageurl = '';

          if (state is ChatDetailReady) {
            final chat = state.chat;
            title = chat.title ?? 'Chat';
            phone = chat.provider?.phoneNumber ?? '';
            isActive = chat.isActive ?? false;
            imageurl = chat.image ?? '';
            log(imageurl);
          }
          return Scaffold(
            backgroundColor: appColors.whiteColor,
            appBar: _buildAppBar(title, isActive, phone, imageurl),
            body: SafeArea(
              child: Column(
                children: [
                  const ListDivider(),
                  Expanded(
                    child: _buildChatContent(state),
                  ),
                  5.verticalSpace,
                  IgnorePointer(
                    ignoring: state is! ChatDetailReady,
                    child: Opacity(
                      opacity: state is ChatDetailReady ? 1.0 : 0.5,
                      child: ChatBoxWidget(
                        onAttachment: () {
                          unawaited(_showAttachmentMenu(context));
                        },
                        onSend: (text) {
                          final userId = _currentUserId;
                          final currentState =
                              context.read<ChatDetailBloc>().state;

                          if (text.trim().isNotEmpty &&
                              userId != null &&
                              currentState is ChatDetailReady) {
                            context.read<ChatDetailBloc>().add(
                              SendTextMessage(text, userId, 'USER'),
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
      ),
    );
  }

  Widget _buildChatContent(ChatDetailState state) {
    final appColors = context.appColors;

    if (state is ChatDetailLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: appColors.primary,
            ),
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
        onPressed: () {
          context.read<ChatDetailBloc>().add(OpenChatDetail(widget.chatId));
        },
      );
    }

    if (state is ChatDetailReady) {
      return Stack(
        children: [
          _MessageList(
            controller: _scrollController,
            messages: state.messages,
            currentUserId: _currentUserId,
            chat: state.chat,
            isLoadingMore: state.isLoadingMore,
            hasMoreMessages: state.hasMoreMessages,
          ),
          if (_showJumpButton)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: _scrollToBottom,
                backgroundColor: appColors.primary,
                child: Icon(
                  Icons.arrow_downward,
                  color: appColors.whiteColor,
                ),
              ),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  PreferredSizeWidget _buildAppBar(
    String title,
    bool isActive,
    String phoneNumber,
    String imageurl,
  ) {
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
          PictureWidget(
            image: imageurl,
          ),
          8.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GenText(
                  title.capitalize,
                  weight: FontWeight.w500,
                  color: appColors.black,
                  maxLines: 1,
                ),
                GenText(
                  isActive ? 'Online' : 'Offline',
                  size: 13,
                  color:
                      isActive
                          ? appColors.success.shade600
                          : appColors.error.shade600,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            SizedBox(
              width: 35.w,
              child: IconButton(
                onPressed: () async {
                  await DialerUtil.open(phoneNumber);
                },
                icon: AppAssets.ASSETS_ICONS_PHONE_ICON_SVG.svg,
              ),
            ),
            10.horizontalSpace,
          ],
        ),
      ],
    );
  }

  void _onChatStateChanged(
    BuildContext context,
    ChatDetailState state,
  ) {
    if (state is ChatDetailReady) {
      final messages = state.messages;
      final messageCount = messages.length;

      // Determine if the last message is from the current user
      final lastMessage = messages.isNotEmpty ? messages.first : null;
      final isLastMessageFromMe =
          lastMessage?.senderId == _currentUserId ||
          lastMessage?.senderType == 'USER';

      // Capture scroll position BEFORE the frame callback (like trip_chat)
      final wasAtBottom = _isAtBottom();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        final isInitialLoad = _previousMessageCount == 0 && messageCount > 0;

        if (isInitialLoad) {
          await _scrollToBottom();
          _previousMessageCount = messageCount;
          return;
        }

        if (messageCount > _previousMessageCount) {
          if (!state.isLoadingMore) {
            // Only scroll if: user sent the message OR was already at bottom
            if (isLastMessageFromMe || wasAtBottom) {
              await _scrollToBottom();
            } else {
              // Show jump button for incoming messages when not at bottom
              if (mounted) {
                setState(() => _showJumpButton = true);
              }
            }
          }
          _previousMessageCount = messageCount;
        }

        if (_pendingOlderMessagesInsert &&
            !state.isLoadingMore &&
            _scrollController.hasClients) {
          final beforeMax = _beforeLoadMaxScrollExtent;
          final beforeOffset = _beforeLoadOffset;
          if (beforeMax != null && beforeOffset != null) {
            final newMax = _scrollController.position.maxScrollExtent;
            final delta = newMax - beforeMax;
            final newOffset = beforeOffset + delta;
            _scrollController.jumpTo(
              newOffset.clamp(
                _scrollController.position.minScrollExtent,
                _scrollController.position.maxScrollExtent,
              ),
            );
          }
          _pendingOlderMessagesInsert = false;
          _isRequestingMore = false;
        }
      });
    }
  }

  Future<void> _handlePaymentState(
    BuildContext context,
    CustomerPaymentState state,
  ) async {
    // Loading states
    if (state is ServicePaymentLoadingState ||
        state is ServiceRequestPaymentVerifying) {
      showLoadingDialog(context);
      return;
    }

    // Card payment initiated - navigate to webview
    if (state is ServiceRequestPaymentInitiatedState) {
      Navigator.pop(context); // Close loading dialog

      final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (_) => PaystackWebViewPage(
                authorizationUrl: state.payment.authorizationUrl,
                reference: state.payment.reference,
                callbackUrl: 'https://example.com/callback',
              ),
        ),
      );

      if (completed ?? false) {
        context.read<CustomerPaymentBloc>().add(
          CustomerVerifyServiceRequestPaymentEvent(
            state.payment.reference,
          ),
        );
      } else {
        await showErrorSnackbar(context, 'Payment cancelled');
      }
      return;
    }

    if (state is ServiceRequestPaymentCompletedState) {
      Navigator.pop(context);

      context.read<ChatDetailBloc>().add(OpenChatDetail(widget.chatId));
      context.read<ChatDetailBloc>().add(RefreshMessages());

      await GeneralDialogs.showCustomDialog<void>(
        context,
        body: const PaymentCompleted(),
      );
      return;
    }

    if (state is ServicePaymentFailureState) {
      Navigator.pop(context);
      await showErrorSnackbar(context, state.error);
    }
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

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.controller,
    required this.messages,
    required this.currentUserId,
    required this.chat,
    required this.isLoadingMore,
    required this.hasMoreMessages,
  });

  final ScrollController controller;
  final List<MessageResponse> messages;
  final int? currentUserId;
  final ChatResponse chat;
  final bool isLoadingMore;
  final bool hasMoreMessages;

  @override
  Widget build(BuildContext context) {
    final itemCount = messages.length + (isLoadingMore ? 1 : 0);

    return ListView.builder(
      controller: controller,
      reverse: true,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 50.h),
      itemCount: itemCount,
      itemBuilder: (_, index) {
        if (isLoadingMore && index == messages.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final message = messages[index];
        final amount = message.metadata?.amount?.toString() ?? '';
        final isMine = message.senderType == 'USER';

        return Padding(
          key: ValueKey(
            message.id ?? message.createdAt?.millisecondsSinceEpoch,
          ),
          padding: EdgeInsets.only(bottom: 15.h),
          child:
              message.messageType == MessageReceivedType.invoice.value
                  ? ChatInvoiceCardWidget(
                    message: message,
                    chat: chat,
                    metadata: message.metadata!,
                    messageCreatedAt: AppTextUtil.formatChatTime(
                      message.createdAt!,
                    ),
                    onTapPay: () async {
                      await GeneralDialogs.showCustomDialog<void>(
                        context,
                        body: PaymentOptionDialog(
                          onPaymentSelected: (option) async {
                            await GeneralDialogs.showCustomDialog<void>(
                              context,
                              body: ClientPaymentConfirmDialog(
                                amount: int.parse(amount),
                                title: chat.serviceName ?? '',
                                invoiceNumber: message.metadata!.invoiceId!,
                                message: message,
                                chatId: chat.id!,
                                paymentMethod: option.name,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    status: chat.paymentStatus ?? 'PENDING',
                  )
                  : ChatBubble(
                    type: isMine ? MessageType.sent : MessageType.received,
                    message: message.content ?? '',
                    time: AppTextUtil.formatChatTime(message.createdAt!),
                  ),
        );
      },
    );
  }
}
