import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/helpers/media_helper.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/core/utils/dialer_util.dart';
import 'package:resq360/features/chat/bloc/chat_details_bloc/chat_details_bloc.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';
import 'package:resq360/features/chat/screens/generate_invoice.dialog.dart';
import 'package:resq360/features/chat/screens/payment_completed.dialog.dart';
import 'package:resq360/features/chat/screens/service_detail_screen.dart';
import 'package:resq360/features/chat/widgets/chat_document.dart';
import 'package:resq360/features/chat/widgets/chat_image_bubble.dart';
import 'package:resq360/features/chat/widgets/chat_invoice_card_widget.dart';
import 'package:resq360/features/chat/widgets/chat_location_bubble.dart';
import 'package:resq360/features/chat/widgets/multi_image_chat_bubble.dart';
import 'package:resq360/features/chat/widgets/provider_chat_invoice_card_widget.dart';
import 'package:resq360/features/customer/authentication/view_models/customer_auth_vm.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/payment_bloc/customer_payment_bloc.dart';
import 'package:resq360/features/customer/dashboard/screens/paystack_webview.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/authentication/view_models/provider_auth_vm.dart';
import 'package:resq360/features/widgets/chat_box_widget.dart';
import 'package:resq360/features/widgets/chat_bubble.dart';
import 'package:resq360/features/widgets/dialogs/complete_payment_option.dialog.dart';
import 'package:resq360/features/widgets/dialogs/payment_option.dialog.dart';

/// Unified chat detail screen for both customer and provider users.
class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({
    required this.chatId,
    required this.userType,
    super.key,
  });

  final int chatId;
  final UserType userType;

  int? get _currentUserId =>
      userType == UserType.customer
          ? CustomerAuthProvider.instance.authInfo?.id
          : ProviderAuthProvider.instance.authInfo?.id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => ChatDetailBloc(
            chatId: chatId,
            currentUserId: _currentUserId,
          )..add(OpenChatDetail(chatId)),
      child: _ChatDetailView(
        chatId: chatId,
        userType: userType,
      ),
    );
  }
}

class _ChatDetailView extends StatefulWidget {
  const _ChatDetailView({
    required this.chatId,
    required this.userType,
  });

  final int chatId;
  final UserType userType;

  @override
  State<_ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<_ChatDetailView> {
  final ScrollController _scrollController = ScrollController();

  bool get isCustomer => widget.userType == UserType.customer;
  bool get isProvider => widget.userType == UserType.provider;

  int? get _currentUserId =>
      isCustomer
          ? CustomerAuthProvider.instance.authInfo?.id
          : ProviderAuthProvider.instance.authInfo?.id;

  String get _senderType => isCustomer ? 'USER' : 'PROVIDER';

  // Scroll tracking state (from trip_chat pattern)
  int _previousMessageCount = 0;
  bool _showJumpButton = false;
  bool _hasScrolledToBottomOnce = false;

  // Load more state
  bool _isRequestingMore = false;
  double? _beforeLoadMaxScrollExtent;
  double? _beforeLoadOffset;
  bool _pendingOlderMessagesInsert = false;

  // Provider-specific state
  bool canShowServiceDetails = false;

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
      if (isCustomer) {
        await CustomerAuthProvider.instance.init();
      } else {
        await ProviderAuthProvider.instance.init();
      }
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

    Widget buildChatConsumer() {
      return BlocConsumer<ChatDetailBloc, ChatDetailState>(
        listener: _onChatStateChanged,
        builder: (context, state) {
          var title = '';
          var isActive = false;
          var phone = '';
          var imageurl = '';
          var status = '';

          if (state is ChatDetailReady) {
            final chat = state.chat;
            title = chat.title ?? 'Chat';
            phone =
                isCustomer
                    ? (chat.provider?.phoneNumber ?? '')
                    : (chat.user?.phoneNumber ?? '');
            isActive = chat.isActive ?? false;
            imageurl = chat.image ?? '';
            status = chat.paymentStatus ?? '';
          }

          return Scaffold(
            backgroundColor: appColors.whiteColor,
            appBar: _buildAppBar(title, isActive, phone, imageurl, status),
            body: SafeArea(
              child: Column(
                children: [
                  const ListDivider(),
                  Expanded(
                    child: _buildChatContent(state),
                  ),
                  // Provider-only: Show service details link when paid
                  if (isProvider &&
                      canShowServiceDetails &&
                      state is ChatDetailReady)
                    GestureDetector(
                      onTap: () async {
                        final serviceMessage = state.messages.firstWhere(
                          (m) =>
                              m.messageType ==
                                  MessageReceivedType.invoice.value &&
                              m.metadata != null,
                        );

                        await pushScreen(
                          context,
                          ServiceDetailScreen(
                            chat: state.chat,
                            message: serviceMessage,
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: GenText(
                          'View Service details',
                          weight: FontWeight.w500,
                          color: appColors.primary.shade500,
                          decoration: TextDecoration.underline,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  5.verticalSpace,
                  IgnorePointer(
                    ignoring: state is! ChatDetailReady,
                    child: Opacity(
                      opacity: state is ChatDetailReady ? 1.0 : 0.5,
                      child: ChatBoxWidget(
                        onAttachment: () {
                          if (state is ChatDetailReady) {
                            unawaited(_showAttachmentMenu(context, state.chat));
                          }
                        },
                        onSend: (text) {
                          final userId = _currentUserId;
                          final currentState =
                              context.read<ChatDetailBloc>().state;

                          if (text.trim().isNotEmpty &&
                              userId != null &&
                              currentState is ChatDetailReady) {
                            context.read<ChatDetailBloc>().add(
                              SendTextMessage(text, userId, _senderType),
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

    // Only wrap with BlocListener for customers (payment handling)
    if (isCustomer) {
      return BlocListener<CustomerPaymentBloc, CustomerPaymentState>(
        listener: _handlePaymentState,
        child: buildChatConsumer(),
      );
    }

    return buildChatConsumer();
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
            userType: widget.userType,
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
    String status,
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
        if (status == 'COMPLETED')
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
          lastMessage?.senderType == _senderType;

      // Capture scroll position BEFORE the frame callback (like trip_chat)
      final wasAtBottom = _isAtBottom();

      // Provider-specific: Check if should show service details
      if (isProvider) {
        final hasPaid =
            state.chat.paymentStatus == PaymentStatus.completed.value;
        final hasInvoice = messages.any(
          (m) =>
              m.messageType == MessageReceivedType.invoice.value &&
              m.metadata != null,
        );
        setState(() {
          canShowServiceDetails = hasPaid && hasInvoice;
        });
      }

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

  /// Handles customer payment state changes
  Future<void> _handlePaymentState(
    BuildContext context,
    CustomerPaymentState state,
  ) async {
    if (!isCustomer) return;

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

  // Replace the attachment menu handlers in _ChatDetailViewState

  Future<void> _showAttachmentMenu(
    BuildContext context,
    ChatResponse chat,
  ) async {
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

    final menuItems = <PopupMenuItem<String>>[
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
    ];

    final isPaymentCompleted = chat.paymentStatus?.toUpperCase() == 'COMPLETED';
    if (isProvider && !isPaymentCompleted) {
      menuItems.add(
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
      );
    }

    await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      items: menuItems,
    ).then((String? result) async {
      if (!context.mounted) return;

      if (result != null) {
        switch (result) {
          case 'media':
            await _onMediaTap(context);
          case 'location':
            await _onLocationTap(context);
          case 'document':
            await _onDocumentTap(context);
          case 'invoice':
            await _onInvoiceTap(context, chat);
        }
      }
    });
  }

Future<void> _onMediaTap(BuildContext context) async {
  final files = await MediaPickerHelper.pickMultipleImages(
    context: context,
  );

  if (files == null || files.isEmpty || !context.mounted) return;

  final userId = _currentUserId;
  if (userId == null) {
    await showErrorSnackbar(context, 'User not authenticated');
    return;
  }

  final caption = await _showCaptionDialog(context);

  final filePaths = files.map((f) => f.path).toList();

  if (context.mounted) {
    context.read<ChatDetailBloc>().add(
      SendImageMessage(
        filePaths: filePaths,   
        senderId: userId,
        userType: _senderType,
        caption: caption,
      ),
    );
  }
}

  Future<void> _onLocationTap(BuildContext context) async {
    final locationData = await MediaPickerHelper.getCurrentLocation(
      context: context,
    );

    if (locationData == null || !context.mounted) return;

    final userId = _currentUserId;
    if (userId == null) {
      await showErrorSnackbar(context, 'User not authenticated');
      return;
    }

    context.read<ChatDetailBloc>().add(
      SendLocationMessage(
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        address: locationData.address,
        senderId: userId,
        userType: _senderType,
      ),
    );
  }

  Future<void> _onDocumentTap(BuildContext context) async {
    final file = await MediaPickerHelper.pickDocument(context: context);

    if (file == null || !context.mounted) return;

    final userId = _currentUserId;
    if (userId == null) {
      await showErrorSnackbar(context, 'User not authenticated');
      return;
    }

    // context.read<ChatDetailBloc>().add(
    //   SendDocumentMessage(
    //     filePath: file.path,
    //     senderId: userId,
    //     userType: _senderType,
    //   ),
    // );
  }

  Future<String?> _showCaptionDialog(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        final appColors = context.appColors;
        return AlertDialog(
          title: const GenText('Add Caption (Optional)'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter caption...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            maxLines: 3,
            maxLength: 200,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: GenText(
                'Skip',
                color: appColors.neutral.shade600,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: GenText(
                'Add',
                color: appColors.primary.shade600,
                weight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onInvoiceTap(BuildContext context, ChatResponse chat) async {
    await GeneralDialogs.showCustomDialog<void>(
      context,
      body: BlocProvider.value(
        value: context.read<ChatDetailBloc>(),
        child: GenerateInvoiceDialog(
          chat: chat,
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.controller,
    required this.messages,
    required this.currentUserId,
    required this.chat,
    required this.isLoadingMore,
    required this.hasMoreMessages,
    required this.userType,
  });

  final ScrollController controller;
  final List<MessageResponse> messages;
  final int? currentUserId;
  final ChatResponse chat;
  final bool isLoadingMore;
  final bool hasMoreMessages;
  final UserType userType;

  bool get isCustomer => userType == UserType.customer;
  bool get isProvider => userType == UserType.provider;
  String get _senderType => isCustomer ? 'USER' : 'PROVIDER';

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
        final isMine = message.senderType == _senderType;
        final time = AppTextUtil.formatChatTime(
          message.createdAt ?? DateTime.now(),
        );

        return Padding(
          key: ValueKey(
            message.id ?? message.createdAt?.millisecondsSinceEpoch,
          ),
          padding: EdgeInsets.only(bottom: 15.h),
          child: _buildMessageWidget(context, message, isMine, time),
        );
      },
    );
  }

Widget _buildMessageWidget(
  BuildContext context,
  MessageResponse message,
  bool isMine,
  String time,
) {
  final type = message.messageType?.toUpperCase() ?? 'TEXT';
  final metaType = message.metadata?.type?.toUpperCase();

  if (type == 'INVOICE') {
    return _buildInvoiceCard(context, message);
  }

  switch (metaType) {
    case 'IMAGE':
  final files = (message.metadata?.customData?['files'] as List?)?.cast<String>() ?? [];

  if (files.length > 1) {

    return ChatMultiImageBubble(
      imageUrls: files,
      time: time,
      isMine: isMine,
    );
  }

  return ChatImageBubble(
    imageUrl: files.isNotEmpty ? files.first : (message.fileUrl ?? ''),
    time: time,
    isMine: isMine,
    caption: message.content != 'Image' ? message.content : null,
  );

    case 'DOCUMENT':
      return ChatDocumentBubble(
        fileName: message.fileName ?? 'Unknown file',
        fileUrl: message.fileUrl ?? '',
        fileSize: message.fileSize,
        time: time,
        isMine: isMine,
        mimeType: message.mimeType,
      );

    case 'LOCATION':
      final lat = message.metadata?.latitude;
      final long = message.metadata?.longitude;

      if (lat == null || long == null) {
        return ChatBubble(
          type: isMine ? MessageType.sent : MessageType.received,
          message: 'Invalid location data',
          time: time,
        );
      }

      return ChatLocationBubble(
        latitude: lat,
        longitude: long,
        address: message.metadata?.address ?? 'Unknown location',
        time: time,
        isMine: isMine,
      );

    default:
      return ChatBubble(
        type: isMine ? MessageType.sent : MessageType.received,
        message: message.content ?? '',
        time: time,
      );
  }
}

  Widget _buildInvoiceCard(BuildContext context, MessageResponse message) {
    final amount = message.metadata?.amount?.toString() ?? '';

    if (isCustomer) {
      return ChatInvoiceCardWidget(
        message: message,
        chat: chat,
        metadata: message.metadata!,
        messageCreatedAt: AppTextUtil.formatChatTime(message.createdAt!),
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
      );
    } else {
      return ProviderChatInvoiceCardWidget(
        metadata: message.metadata!,
        message: message,
        chat: chat,
        paymentStatus:
            chat.paymentStatus == PaymentStatus.completed.value
                ? PaymentStatus.completed
                : PaymentStatus.pending,
        onTapPay: () => _handleInvoicePayment(context, message),
      );
    }
  }

  Future<void> _handleInvoicePayment(
    BuildContext context,
    MessageResponse message,
  ) async {
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
}
