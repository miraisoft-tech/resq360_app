import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/utils/app_constant.dart';
import 'package:resq360/core/utils/app_file_picker.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/core/utils/dialer_util.dart';
import 'package:resq360/features/chat/bloc/chat_details_bloc/chat_details_bloc.dart';
import 'package:resq360/features/chat/bloc/chat_list_bloc/chat_list_bloc.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';
import 'package:resq360/features/chat/data/services/chat_repo.dart';
import 'package:resq360/features/chat/screens/chat_service_detail_screen.dart';
import 'package:resq360/features/chat/screens/generate_invoice.dialog.dart';
import 'package:resq360/features/chat/screens/payment_completed.dialog.dart';
import 'package:resq360/features/chat/widgets/appeal_closed_card.dart';
import 'package:resq360/features/chat/widgets/chat_document.dart';
import 'package:resq360/features/chat/widgets/chat_image_bubble.dart';
import 'package:resq360/features/chat/widgets/chat_invoice_card_widget.dart';
import 'package:resq360/features/chat/widgets/chat_location_bubble.dart';
import 'package:resq360/features/chat/widgets/dispute_service_details_card.dart';
import 'package:resq360/features/chat/widgets/multi_image_chat_bubble.dart';
import 'package:resq360/features/chat/widgets/provider_chat_invoice_card_widget.dart';
import 'package:resq360/features/chat/widgets/report_chat_dialog.dart';
import 'package:resq360/features/chat/widgets/report_message_dialog.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/payment_bloc/customer_payment_bloc.dart';
import 'package:resq360/features/customer/dashboard/screens/paystack_webview.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/widgets/chat_box_widget.dart';
import 'package:resq360/features/widgets/chat_bubble.dart';
import 'package:resq360/features/widgets/dialogs/complete_payment_option.dialog.dart';
import 'package:resq360/features/widgets/dialogs/payment_option.dialog.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({
    required this.chatId,
    required this.userType,
    this.providerServiceId,
    super.key,
  });

  final int chatId;
  final UserType userType;
  final int? providerServiceId;

  Future<int?> _loadCurrentUserId() async {
    if (userType == UserType.customer) {
      return AuthLocalRepo.instance.getCustomerId();
    } else {
      return AuthLocalRepo.instance.getProviderId();
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: _loadCurrentUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userId = snapshot.data!;

        return BlocProvider(
          create:
              (_) =>
                  ChatDetailBloc(chatId: chatId, currentUserId: userId)
                    ..add(OpenChatDetail(chatId)),
          child: _ChatDetailView(
            chatId: chatId,
            userType: userType,
            currentUserId: userId,
            providerServiceId: providerServiceId,
          ),
        );
      },
    );
  }
}

class _ChatDetailView extends StatefulWidget {
  const _ChatDetailView({
    required this.chatId,
    required this.userType,
    required this.currentUserId,
    this.providerServiceId,
  });

  final int chatId;
  final UserType userType;
  final int currentUserId;
  final int? providerServiceId;

  @override
  State<_ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<_ChatDetailView> {
  final ScrollController _scrollController = ScrollController();
  final ChatRepo _chatRepo = ChatRepo();

  bool _pendingServiceRequestFired = false;

  bool get isCustomer => widget.userType == UserType.customer;
  bool get isProvider => widget.userType == UserType.provider;

  String get _senderType => isCustomer ? 'USER' : 'PROVIDER';
  int get _currentUserId => widget.currentUserId;

  int _previousMessageCount = 0;
  bool _showJumpButton = false;
  bool _hasScrolledToBottomOnce = false;

  bool _isRequestingMore = false;
  double? _beforeLoadMaxScrollExtent;
  double? _beforeLoadOffset;
  bool _pendingOlderMessagesInsert = false;

  bool canShowServiceDetails = false;
  bool _isModeratingMessage = false;

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
        listener: (context, state) async {
          _onChatStateChanged(context, state);
          if (state is ChatDetailReportSuccess) {
            context.read<ChatListBloc>().add(LoadChatList());
            Navigator.pop(context, true);
          }

          if (state is ChatDetailActionFailure) {
            await showErrorSnackbar(context, state.error);
          }
        },
        builder: (context, state) {
          var title = '';
          var isActive = false;
          var phone = '';
          var imageurl = '';
          var paymentStatus = '';
          var serviceStatus = '';
          var chatType = '';
          var providerName = '';

          final canShowServiceDetails =
              state is ChatDetailReady &&
              state.messages.any(
                (m) =>
                    m.messageType == MessageReceivedType.invoice.value &&
                    m.metadata != null,
              );

          if (state is ChatDetailReady) {
            final chat = state.chat;
            title = chat.title ?? 'Chat';
            phone =
                isCustomer
                    ? (chat.provider?.phoneNumber ?? '')
                    : (chat.user?.phoneNumber ?? '');
            isActive = chat.isActive ?? false;
            imageurl = chat.image ?? '';
            paymentStatus = chat.paymentStatus ?? '';
            serviceStatus = chat.serviceRequestStatus ?? '';
            chatType = chat.type ?? '';
            providerName = chat.provider?.fullName ?? '';
          }

          final isDisputeClosed =
              state is ChatDetailReady &&
              state.chat.type == 'DISPUTE' &&
              (state.chat.disputeStatus == 'CANCELLED' ||
                  state.chat.disputeStatus == 'COMPLETED');

          return Scaffold(
            backgroundColor: appColors.whiteColor,
            body: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(
                    title: title,
                    phoneNumber: phone,
                    imageurl: imageurl,
                    serviceStatus: serviceStatus,
                    paymentStatus: paymentStatus,
                    isActive: isActive,
                    isDispute: chatType == 'DISPUTE',
                    providerName: providerName,
                  ),
                  const ListDivider(),
                  Expanded(child: _buildChatContent(state)),
                  if (canShowServiceDetails)
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
                          ChatServiceDetailScreen(
                            chat: state.chat,
                            message: serviceMessage,
                            userType: widget.userType,
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
                  if (isDisputeClosed) ...[
                    5.verticalSpace,
                    GestureDetector(
                      onTap: () async {
                        await pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: GenText(
                          'Return to Dashboard',
                          weight: FontWeight.w500,
                          color: appColors.primary.shade500,
                          decoration: TextDecoration.underline,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                  if (!isDisputeClosed)
                    IgnorePointer(
                      ignoring: state is! ChatDetailReady,
                      child: Opacity(
                        opacity: state is ChatDetailReady ? 1.0 : 0.5,
                        child: ChatBoxWidget(
                          onAttachment: (ctx) {
                            if (state is ChatDetailReady) {
                              unawaited(_showAttachmentMenu(ctx, state.chat));
                            }
                          },
                          onSend: (text) {
                            final userId = _currentUserId;
                            final currentState =
                                context.read<ChatDetailBloc>().state;

                            if (text.trim().isNotEmpty &&
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
            CircularProgressIndicator(color: appColors.primary),
            16.verticalSpace,
            GenText('Loading messages...', color: appColors.neutral.shade400),
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
            onMessageLongPress:
                (message) => _onMessageLongPress(message, state.chat),
          ),
          if (state.chat.type == 'DISPUTE')
            Positioned(
              top: 0,
              left: 16.w,
              right: 16.w,
              child: DisputeServiceDetailCard(chat: state.chat),
            ),
          if (_showJumpButton)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: _scrollToBottom,
                backgroundColor: appColors.primary,
                child: Icon(Icons.arrow_downward, color: appColors.whiteColor),
              ),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAppBar({
    required String title,
    required bool isActive,
    required String phoneNumber,
    required String imageurl,
    required String serviceStatus,
    required String paymentStatus,
    required bool isDispute,
    required String providerName,
  }) {
    final appColors = context.appColors;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final menuMaxWidth = screenWidth * 0.7;

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.black),
          onPressed: () => pop(context),
        ),
        20.horizontalSpace,
        PictureWidget(image: imageurl),
        8.horizontalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: isDispute ? 160.w : 100,
              child: Tooltip(
                message:
                    isDispute ? 'You, Admin, $providerName' : title.capitalize,
                verticalOffset: 48,
                child: GenText(
                  isDispute ? 'You, Admin, $providerName' : title.capitalize,
                  weight: FontWeight.w500,
                  color: appColors.black,
                  maxLines: 1,
                ),
              ),
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
        const Spacer(),
        if (paymentStatus == 'COMPLETED' && serviceStatus == 'ASSIGNED')
          SizedBox(
            width: 35.w,
            child: IconButton(
              onPressed: () async {
                await DialerUtil.open(phoneNumber);
              },
              icon: AppAssets.ASSETS_ICONS_PHONE_ICON_SVG.svg,
            ),
          ),
        if (!isDispute)
          PopupMenuButton<String>(
            constraints: BoxConstraints(
              minWidth: 180.w,
              maxWidth: menuMaxWidth,
            ),
            icon: Icon(Icons.more_vert, color: appColors.neutral.shade700),
            color: appColors.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            onSelected: (value) => _handleMenuAction(value, title),
            itemBuilder:
                (context) => [
                  PopupMenuItem<String>(
                    value: 'block',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.report_outlined,
                          color: appColors.error.shade600,
                          size: 20.sp,
                        ),
                        12.horizontalSpace,
                        Flexible(
                          child: GenText(
                            'Block $title',
                            color: appColors.neutral.shade900,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        10.horizontalSpace,
      ],
    );
  }

  void _onChatStateChanged(BuildContext context, ChatDetailState state) {
    if (state is ChatDetailReady) {
      if (!_pendingServiceRequestFired) {
        _pendingServiceRequestFired = true;
        final userId = _currentUserId;
        if (widget.providerServiceId == null) return;
        context.read<ChatDetailBloc>().add(
          SendServiceRequest(
            providerServiceId: widget.providerServiceId!,
            description: 'Service Request',
            senderId: userId,
            userType: _senderType,
            chatId: widget.chatId,
          ),
        );
      }
      final messages = state.messages;
      final messageCount = messages.length;

      final lastMessage = messages.isNotEmpty ? messages.first : null;
      final isLastMessageFromMe =
          lastMessage?.senderId == _currentUserId ||
          lastMessage?.senderType == _senderType;

      final wasAtBottom = _isAtBottom();

      // if (isProvider) {
      //   final hasPaid =
      //       state.chat.paymentStatus == PaymentStatus.completed.value;
      //   final hasInvoice = messages.any(
      //     (m) =>
      //         m.messageType == MessageReceivedType.invoice.value &&
      //         m.metadata != null,
      //   );
      //   setState(() {
      //     log('has set canShowServiceDetails');
      //     canShowServiceDetails = hasPaid && hasInvoice;
      //   });
      // }

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
            if (isLastMessageFromMe || wasAtBottom) {
              await _scrollToBottom();
            } else {
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
    if (!isCustomer) return;

    if (state is ServicePaymentLoadingState ||
        state is ServiceRequestPaymentVerifying) {
      showLoadingDialog(context);
      return;
    }

    if (state is ServiceRequestPaymentInitiatedState) {
      Navigator.pop(context);

      final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (_) => PaystackWebViewPage(
                authorizationUrl: state.payment.authorizationUrl,
                reference: state.payment.reference,
                callbackUrl: AppConstants.paystackCallbackUrl,
              ),
        ),
      );

      if (completed ?? false) {
        context.read<CustomerPaymentBloc>().add(
          CustomerVerifyServiceRequestPaymentEvent(state.payment.reference),
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
        body: PaymentCompleted(
          onViewDetails: () async {
            final chatDetailState = context.read<ChatDetailBloc>().state;
            if (chatDetailState is ChatDetailReady &&
                chatDetailState.messages.isNotEmpty) {
              final serviceMessage = chatDetailState.messages.firstWhere(
                (m) =>
                    m.messageType == MessageReceivedType.invoice.value &&
                    m.metadata != null,
              );
              await pushScreen(
                context,
                ChatServiceDetailScreen(
                  chat: chatDetailState.chat,
                  message: serviceMessage,
                  userType: widget.userType,
                ),
              );
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
        ),
      );
      return;
    }

    if (state is ServicePaymentFailureState) {
      Navigator.pop(context);
      await showErrorSnackbar(context, state.error);
    }
  }

  Future<void> _showAttachmentMenu(
    BuildContext context,
    ChatResponse chat,
  ) async {
    final button = context.findRenderObject()! as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final buttonOffset = button.localToGlobal(Offset.zero, ancestor: overlay);
    final rect = Rect.fromLTWH(
      buttonOffset.dx,
      buttonOffset.dy,
      button.size.width,
      button.size.height,
    );
    final position = RelativeRect.fromRect(rect, Offset.zero & overlay.size);

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

    if (isProvider) {
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
    final files = await AppFilePicker.pickMultiImages();

    if (files == null || files.isEmpty || !context.mounted) return;

    final userId = _currentUserId;

    // final caption = await _showCaptionDialog(context);

    final filePaths = files.map((f) => f.path).toList();

    if (context.mounted) {
      context.read<ChatDetailBloc>().add(
        SendImageMessage(
          filePaths: filePaths,
          senderId: userId,
          userType: _senderType,
          caption: 'Samples',
        ),
      );
    }
  }

  Future<void> _onLocationTap(BuildContext context) async {
    final locationData = await AppFilePicker.getCurrentLocation(
      context: context,
    );

    if (locationData == null || !context.mounted) return;

    final userId = _currentUserId;

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
    final file = await AppFilePicker.pickDocument(context: context);

    if (file == null || !context.mounted) return;

    final userId = _currentUserId;

    context.read<ChatDetailBloc>().add(
      SendDocumentMessage(
        filePath: file.path,
        senderId: userId,
        userType: _senderType,
      ),
    );
  }

  Future<String?> showCaptionDialog(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        final appColors = context.appColors;
        return AlertDialog(
          backgroundColor: appColors.whiteColor,
          title: GenText('Add Caption (Optional)', color: appColors.black),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter caption...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              focusColor: appColors.primary,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: appColors.primary),
              ),
            ),
            maxLines: 3,
            maxLength: 200,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: GenText('Skip', color: appColors.neutral.shade600),
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
        child: GenerateInvoiceDialog(chat: chat),
      ),
    );
  }

  Future<void> _handleMenuAction(String action, String title) async {
    final currentState = context.read<ChatDetailBloc>().state;
    if (currentState is! ChatDetailReady) return;

    final chat = currentState.chat;

    final otherUserId = isCustomer ? chat.provider?.id : chat.user?.id;

    if (otherUserId == null) return;

    switch (action) {
      case 'block':
        await _showReportDialog(chat.id!, title);
    }
  }

  Future<void> _showReportDialog(int chatId, String title) async {
    final blocked = await GeneralDialogs.showCustomDialog<bool>(
      context,
      body: BlocProvider.value(
        value: context.read<ChatDetailBloc>(),
        child: ReportChatDialog(chatId: chatId, chatTitle: title),
      ),
    );

    if (blocked ?? false) {
      context.read<ChatListBloc>().add(RefreshChatList());

      await showSuccessSnackbar(context, 'Chat blocked successfully');

      unawaited(pop(context));
    }
  }

  Future<void> _onMessageLongPress(
    MessageResponse message,
    ChatResponse chat,
  ) async {
    if (message.id == null || _isModeratingMessage) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.appColors.whiteColor,
      builder: (sheetContext) {
        final appColors = sheetContext.appColors;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.report_outlined,
                  color: appColors.error.shade600,
                ),
                title: const GenText('Report message'),
                onTap: () => Navigator.pop(sheetContext, 'report'),
              ),
              ListTile(
                leading: Icon(
                  Icons.gpp_bad_outlined,
                  color: appColors.error.shade700,
                ),
                title: const GenText('Report and block user'),
                onTap: () => Navigator.pop(sheetContext, 'report_block'),
              ),
              12.verticalSpace,
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    final shouldBlock = action == 'report_block';
    final reason =
        shouldBlock
            ? await _showReportAndBlockDialog(chat)
            : await _showMessageReportReasonDialog();
    if (!mounted || reason == null || reason.isEmpty) return;

    await _reportMessage(
      chatId: chat.id,
      messageId: message.id!,
      reason: reason,
      shouldBlock: shouldBlock,
    );
  }

  Future<String?> _showMessageReportReasonDialog() async {
    return GeneralDialogs.showCustomDialog<String>(
      context,
      body: const ReportMessageDialog(),
    );
  }

  Future<String?> _showReportAndBlockDialog(ChatResponse chat) {
    final chatId = chat.id;
    if (chatId == null) return Future.value();

    return GeneralDialogs.showCustomDialog<String>(
      context,
      body: ReportChatDialog(
        chatId: chatId,
        chatTitle: chat.title ?? 'Chat',
        returnSelectedReason: true,
        dialogTitle: 'Report and Block',
        submitLabel: 'Continue',
      ),
    );
  }

  Future<void> _reportMessage({
    required int? chatId,
    required int messageId,
    required String reason,
    required bool shouldBlock,
  }) async {
    setState(() => _isModeratingMessage = true);

    try {
      final reportResult = await _chatRepo.reportMessage(
        messageId: messageId,
        reason: reason,
      );

      if (!mounted) return;

      if (!(reportResult.data ?? false)) {
        await showErrorSnackbar(
          context,
          reportResult.error ?? 'Failed to report message',
        );
        return;
      }

      var blockSucceeded = false;
      if (shouldBlock && chatId != null) {
        final blockResult = await _chatRepo.blockChat(
          chatId: chatId,
          reason: reason,
        );

        if (!mounted) return;
        blockSucceeded = blockResult.data ?? false;

        if (!blockSucceeded) {
          await showErrorSnackbar(
            context,
            blockResult.error ?? 'Message reported, but failed to block user',
          );
        }
      }

      context.read<ChatDetailBloc>().add(RefreshMessages());

      await showSuccessSnackbar(
        context,
        shouldBlock
            ? (blockSucceeded
                ? 'Message reported and user blocked successfully'
                : 'Message reported successfully')
            : 'Message reported successfully',
      );
    } finally {
      if (mounted) {
        setState(() => _isModeratingMessage = false);
      }
    }
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
    this.onMessageLongPress,
  });

  final ScrollController controller;
  final List<MessageResponse> messages;
  final int? currentUserId;
  final ChatResponse chat;
  final bool isLoadingMore;
  final bool hasMoreMessages;
  final UserType userType;
  final Future<void> Function(MessageResponse message)? onMessageLongPress;

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
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final message = messages[index];
        final isMine = message.senderType == _senderType;
        final time = AppTextUtil.formatChatTime(
          message.createdAt?.toLocal() ?? DateTime.now().toLocal(),
        );

        return Padding(
          key: ValueKey(
            message.id ?? message.createdAt?.millisecondsSinceEpoch,
          ),
          padding: EdgeInsets.only(bottom: 15.h),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress:
                (!isMine && message.id != null && onMessageLongPress != null)
                    ? () => unawaited(onMessageLongPress!(message))
                    : null,
            child: _buildMessageWidget(context, message, chat, isMine, time),
          ),
        );
      },
    );
  }

  Widget _buildMessageWidget(
    BuildContext context,
    MessageResponse message,
    ChatResponse chat,
    bool isMine,
    String time,
  ) {
    if (message.isReported ?? false) {
      return _buildReportedMessageNotice(context, isMine, time);
    }

    final type = message.messageType?.toUpperCase() ?? 'TEXT';
    final metaType = message.metadata?.type?.toUpperCase();

    if (type == 'INVOICE') {
      return _buildInvoiceCard(context, message);
    }

    if (chat.disputeStatus == 'COMPLETED') {
      return AppealClosedCard(message: message, chat: chat);
    }

    switch (metaType) {
      case 'IMAGE':
        final files =
            (message.metadata?.customData?['files'] as List?)?.cast<String>() ??
            [];

        if (files.length > 1) {
          return ChatMultiImageBubble(
            imageUrls: files,
            time: time,
            isMine: isMine,
            status: message.status,
          );
        }

        return ChatImageBubble(
          imageUrl: files.isNotEmpty ? files.first : (message.fileUrl ?? ''),
          time: time,
          isMine: isMine,
          caption: message.content != 'Image' ? message.content : null,
          status: message.status,
        );

      case 'DOCUMENT':
        return ChatDocumentBubble(
          fileName: message.fileName ?? 'Unknown file',
          fileUrl: message.fileUrl ?? '',
          fileSize: message.fileSize,
          time: time,
          isMine: isMine,
          mimeType: message.mimeType,
          status: message.status,
        );

      case 'LOCATION':
        final lat = message.metadata?.latitude;
        final long = message.metadata?.longitude;

        if (lat == null || long == null) {
          return ChatBubble(
            type: isMine ? MessageType.sent : MessageType.received,
            message: 'Invalid location data',
            time: time,
            status: message.status,
          );
        }

        return ChatLocationBubble(
          latitude: lat,
          longitude: long,
          address: message.metadata?.address ?? 'Unknown location',
          time: time,
          isMine: isMine,
          status: message.status,
        );

      case 'SERVICE_REQUEST':
        return _buildServiceRequestCard(context, message, isMine, time);

      default:
        return ChatBubble(
          type: isMine ? MessageType.sent : MessageType.received,
          message: message.content ?? '',
          time: time,
          status: message.status,
        );
    }
  }

  Widget _buildReportedMessageNotice(
    BuildContext context,
    bool isMine,
    String time,
  ) {
    final appColors = context.appColors;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            isMine ? EdgeInsets.only(left: 30.w) : EdgeInsets.only(right: 30.w),
        padding: pad(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:
              isMine ? appColors.primary.shade50 : appColors.neutral.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isMine
                    ? appColors.primary.shade200
                    : appColors.neutral.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 16.sp,
              color: appColors.primary.shade600,
            ),
            8.horizontalSpace,
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenText(
                    'Message under review',
                    weight: FontWeight.w600,
                    color: appColors.neutral.shade900,
                  ),
                  2.verticalSpace,
                  GenText(time, size: 12, color: appColors.neutral.shade500),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
        status: message.metadata?.paymentStatus ?? 'PENDING',
      );
    } else {
      return ProviderChatInvoiceCardWidget(
        metadata: message.metadata!,
        message: message,
        chat: chat,
        paymentStatus:
            message.metadata?.paymentStatus == PaymentStatus.completed.value
                ? PaymentStatus.completed
                : PaymentStatus.pending,
        onTapPay: () => _handleInvoicePayment(context, message),
      );
    }
  }

  Widget _buildServiceRequestCard(
    BuildContext context,
    MessageResponse message,
    bool isMine,
    String time,
  ) {
    final appColors = context.appColors;
    final meta = message.metadata;

    final serviceName =
        meta?.customData?['serviceName']?.toString() ??
        meta?.customData?['serviceCategoryName']?.toString() ??
        '—';
    final description = message.content ?? '—';

    return Container(
      width: double.infinity,
      padding: pad(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: appColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.textColor.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UrbText(
                    'Service Request',
                    color: appColors.black,
                    size: 18,
                    height: 20.5,
                    weight: FontWeight.w700,
                  ),
                  4.verticalSpace,
                  GenText(
                    serviceName,
                    weight: FontWeight.w400,
                    color: appColors.textColor.shade300,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UrbText(
                    'Date',
                    color: appColors.black,
                    size: 18,
                    height: 20.5,
                    weight: FontWeight.w700,
                  ),
                  2.verticalSpace,
                  GenText(
                    time,
                    weight: FontWeight.w400,
                    color: appColors.textColor.shade300,
                  ),
                ],
              ),
            ],
          ),

          16.verticalSpace,

          const GenText('Description', weight: FontWeight.w500),
          2.verticalSpace,
          GenText(description, size: 12, color: appColors.textColor.shade300),

          16.verticalSpace,
          Divider(color: appColors.textColor.shade100),
          12.verticalSpace,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GenText('Status', color: appColors.textColor.shade400),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: appColors.warning.shade50,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: GenText(
                  'Pending',
                  size: 12,
                  weight: FontWeight.w600,
                  color: appColors.warning.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
            body: CompletePaymentDialog(amount: amount),
          );
        },
      ),
    );
  }
}
