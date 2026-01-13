import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/general-chat-bloc/chat_details_bloc/bloc/chat_details_bloc.dart';
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

          if (state is ChatDetailReady) {
            final chat = state.chat;
            title = chat.title ?? 'Chat';
            phone = chat.provider?.phoneNumber ?? '';
            isActive = chat.isActive ?? false;
          }
          return Scaffold(
            backgroundColor: appColors.whiteColor,
            appBar: _buildAppBar(title, isActive, phone),
            body: SafeArea(
              child: Column(
                children: [
                  const ListDivider(),
                  Expanded(
                    child: _buildChatContent(state),
                  ),
                  30.verticalSpace,
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
                          if (text.trim().isNotEmpty &&
                              userId != null &&
                              state is ChatDetailReady) {
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
      return _MessageList(
        controller: _scrollController,
        messages: state.messages,
        currentUserId: _currentUserId,
        chat: state.chat,
      );
    }

    return const SizedBox.shrink();
  }

  PreferredSizeWidget _buildAppBar(
    String title,
    bool isActive,
    String phoneNumber,
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
          const PictureWidget(),
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
                isActive ? 'Online' : 'Offline',
                size: 13,
                color:
                    isActive
                        ? appColors.success.shade600
                        : appColors.error.shade600,
              ),
            ],
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: 35.w,
          child: IconButton(
            onPressed: () async {
              await DialerUtil.open(phoneNumber);
            },
            icon: AppAssets.ASSETS_ICONS_PHONE_ICON_SVG.svg,
          ),
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
  }

  Future<void> _handlePaymentState(
    BuildContext context,
    CustomerPaymentState state,
  ) async {
    // Loading states
    if (state is ServicePaymentLoadingState ||
        state is ServiceRequestPaymentVerifying) {
      await showLoadingDialog(context);
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
        // Verify payment after webview completes
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

    // Payment completed (wallet or verified card payment)
    if (state is ServiceRequestPaymentCompletedState) {
      Navigator.pop(context); // Close any open dialog

      // Refresh messages to show updated payment status
      context.read<ChatDetailBloc>().add(OpenChatDetail(widget.chatId));
      context.read<ChatDetailBloc>().add(RefreshMessages());

      // Show success dialog
      await GeneralDialogs.showCustomDialog<void>(
        context,
        body: const PaymentCompleted(),
      );
      return;
    }

    // Error occurred
    if (state is ServicePaymentFailureState) {
      Navigator.pop(context); // Close loading dialog
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
        final amount = message.metadata?.amount?.toString() ?? '';
        final isMine = message.senderType == 'USER';

        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child:
              message.messageType == MessageReceivedType.invoice.value
                  ? ChatInvoiceCardWidget(
                    message: message,
                    chat: chat,
                    metadata: message.metadata!,
                    messageCreatedAt: _formatTime(message.createdAt!),
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
                    time: _formatTime(message.createdAt!),
                  ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
}
