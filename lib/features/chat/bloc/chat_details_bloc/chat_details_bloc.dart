import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/__services.dart';
import 'package:resq360/core/services/chat_cache_service.dart';
import 'package:resq360/core/services/chat_socket_service.dart';
import 'package:resq360/core/services/upload_service.dart';
import 'package:resq360/core/utils/validators.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';
import 'package:resq360/features/chat/data/models/create_request_and_send_invoice.dart';
import 'package:resq360/features/chat/data/services/chat_repo.dart';

part 'chat_details_event.dart';
part 'chat_details_state.dart';

final UploadService _uploadService = UploadService.instance;

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  ChatDetailBloc({
    required this.chatId,
    required this.currentUserId,
    ChatRepo? chatRepo,
    ChatSocketService? socket,
    ChatCacheService? cache,
  }) : _repo = chatRepo ?? ChatRepo(),
       _socket = socket ?? ChatSocketService.instance,
       _cache = cache ?? ChatCacheService.instance,
       super(ChatDetailInitial()) {
    on<OpenChatDetail>(_onOpenChatDetail);
    on<SendTextMessage>(_onSendMessage);
    on<SendServiceRequest>(_onSendServiceRequest);
    on<SendInvoiceMessage>(_onSendInvoiceMessage);
    on<SendServiceRequestInvoice>(_onSendServiceRequestInvoice);
    on<RefreshMessages>(_onRefreshMessages);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<_IncomingMessage>(_onIncomingMessage);
    on<SendImageMessage>(_onSendImageMessage);
    on<SendDocumentMessage>(_onSendDocumentMessage);
    on<SendLocationMessage>(_onSendLocationMessage);
    on<ReportChat>(_onBlockChat);
    // on<BlockUser>(_onBlockUser);
  }

  final int chatId;
  final int? currentUserId;
  final ChatRepo _repo;
  final ChatSocketService _socket;
  final ChatCacheService _cache;
  StreamSubscription<dynamic>? _socketSub;

  Future<void> _onOpenChatDetail(
    OpenChatDetail event,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      // Check cache first - show cached data immediately if available
      final cachedData = _cache.getCachedData(event.chatId);
      if (cachedData != null) {
        // Emit cached data immediately (no loading state)
        emit(
          ChatDetailReady(
            chat: cachedData.chat,
            messages: cachedData.messages,
            currentPage: cachedData.currentPage,
            totalPages: cachedData.totalPages,
            hasMoreMessages: cachedData.hasMoreMessages,
          ),
        );

        // Connect socket
        await _connectSocket();

        await _refreshInBackground(event.chatId, emit);
        return;
      }

      // No cache - show loading and fetch fresh data
      emit(ChatDetailLoading());

      final chatResult = await _repo.getChatById(event.chatId);

      if (chatResult.data == null) {
        emit(ChatDetailFailure(chatResult.error ?? 'Failed to load chat'));
        return;
      }

      final messagesResult = await _repo.getChatMessages(event.chatId);

      if (messagesResult.data == null) {
        emit(
          ChatDetailFailure(messagesResult.error ?? 'Failed to load messages'),
        );
        return;
      }

      await _connectSocket();

      final chat = chatResult.data!;
      final messagesData = messagesResult.data!;

      // Cache the data
      _cache.cacheData(
        chatId: event.chatId,
        chat: chat,
        messages: messagesData.messages,
        currentPage: messagesData.page,
        totalPages: messagesData.totalPages,
        hasMoreMessages: messagesData.page < messagesData.totalPages,
      );

      emit(
        ChatDetailReady(
          chat: chat,
          messages: messagesData.messages,
          currentPage: messagesData.page,
          totalPages: messagesData.totalPages,
          hasMoreMessages: messagesData.page < messagesData.totalPages,
        ),
      );
    } on Exception catch (e) {
      emit(ChatDetailFailure(e.toString()));
    }
  }

  /// Refresh data in background without showing loading state
  Future<void> _refreshInBackground(
    int chatId,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      final chatResult = await _repo.getChatById(chatId);
      final messagesResult = await _repo.getChatMessages(chatId);

      if (chatResult.data == null || messagesResult.data == null) return;

      final chat = chatResult.data!;
      final messagesData = messagesResult.data!;

      // Update cache
      _cache.cacheData(
        chatId: chatId,
        chat: chat,
        messages: messagesData.messages,
        currentPage: messagesData.page,
        totalPages: messagesData.totalPages,
        hasMoreMessages: messagesData.page < messagesData.totalPages,
      );

      // Only update if still in ready state
      if (state is ChatDetailReady) {
        final current = state as ChatDetailReady;

        // Check if messages changed
        final hasNewerMessages =
            messagesData.messages.isNotEmpty &&
            current.messages.isNotEmpty &&
            messagesData.messages.first.id != current.messages.first.id;

        // Check if chat data changed (e.g., paymentStatus)
        final chatDataChanged =
            current.chat.paymentStatus != chat.paymentStatus;

        if (hasNewerMessages || chatDataChanged) {
          emit(
            current.copyWith(
              chat: chat,
              messages: messagesData.messages,
              currentPage: messagesData.page,
              totalPages: messagesData.totalPages,
              hasMoreMessages: messagesData.page < messagesData.totalPages,
            ),
          );
        }
      }
    } on Exception catch (e) {
      log('Background refresh failed: $e');
    }
  }

  Future<void> _connectSocket() async {
    try {
      await _socket.connect();

      unawaited(_socket.joinChat(chatId));

      await _socketSub?.cancel();
      _socketSub = _socket.messageStream.listen(
        (msg) {
          final isForThisChat = msg.chatId == chatId;
          final isFromCurrentUser =
              currentUserId != null && (msg.senderId == currentUserId);

          if (isForThisChat && !isFromCurrentUser) {
            add(_IncomingMessage(msg));
          }
        },
      );
    } on Exception catch (e) {
      log('Socket connection error: $e');
    }
  }

  Future<void> _onSendInvoiceMessage(
    SendInvoiceMessage event,
    Emitter<ChatDetailState> emit,
  ) async {
    final current = state;
    if (current is! ChatDetailReady) return;

    final localMessageId = DateTime.now().millisecondsSinceEpoch * -1;
    final localMessage = MessageResponse(
      id: localMessageId,
      chatId: current.chat.id,
      senderType: 'PROVIDER',
      messageType: 'INVOICE',
      content: event.invoice.description ?? 'Invoice',
      createdAt: DateTime.now(),
      metadata: Metadata(
        type: 'INVOICE',
        amount: event.invoice.amount,
        currency: event.invoice.currency,
        invoiceId: event.invoice.invoiceId,
        description: event.invoice.description,
      ),
    );

    final newMessages = [localMessage, ...current.messages];

    // Update cache
    _cache.updateMessages(chatId: chatId, messages: newMessages);

    emit(
      current.copyWith(
        messages: newMessages,
      ),
    );

    final result = await _repo.sendInvoice(
      invoiceRequest: event.invoice,
    );

    // Get the CURRENT state after API call (not the old captured state)
    final latestState = state;
    if (latestState is! ChatDetailReady) return;

    if (result.data == null) {
      // Remove the local message on failure
      final messagesWithoutLocal =
          latestState.messages.where((m) => m.id != localMessageId).toList();
      emit(
        latestState.copyWith(
          messages: messagesWithoutLocal,
        ),
      );
      return;
    }

    // Replace local message with confirmed message from server
    // Also remove any duplicate that might have come from socket
    final confirmedId = result.data!.id;
    final confirmedMessages =
        latestState.messages
            .where((m) => m.id != localMessageId && m.id != confirmedId)
            .toList();

    final finalMessages = [result.data!, ...confirmedMessages]..sort((a, b) {
      final aTime = a.createdAt ?? DateTime.now();
      final bTime = b.createdAt ?? DateTime.now();
      return bTime.compareTo(aTime); // Descending: newest first
    });

    // Update cache with confirmed message
    _cache.updateMessages(chatId: chatId, messages: finalMessages);

    emit(
      latestState.copyWith(
        messages: finalMessages,
      ),
    );
  }

  Future<void> _onSendServiceRequestInvoice(
  SendServiceRequestInvoice event,
  Emitter<ChatDetailState> emit,
) async {
  final current = state;
  if (current is! ChatDetailReady) return;

  final localMessageId = DateTime.now().millisecondsSinceEpoch * -1;
  final localMessage = MessageResponse(
    id: localMessageId,
    chatId: current.chat.id,
    senderType: 'PROVIDER',
    messageType: 'INVOICE',
    content: event.invoice.description ?? 'Invoice',
    createdAt: DateTime.now(),
    metadata: Metadata(
      type: 'INVOICE',
      amount: event.invoice.amount,
      currency: event.invoice.currency,
      invoiceId: event.invoice.invoiceId,
      description: event.invoice.description,
    ),
  );

  final newMessages = [localMessage, ...current.messages];
  _cache.updateMessages(chatId: chatId, messages: newMessages);
  emit(current.copyWith(messages: newMessages));

  final result = await _repo.createRequestAndSendInvoice(
    request: event.invoice,
  );

  log('[INVOICE] createRequestAndSendInvoice result: ${result.data}');

  final latestState = state;
  if (latestState is! ChatDetailReady) return;

  if (result.data == null) {
    final cleaned =
        latestState.messages.where((m) => m.id != localMessageId).toList();
    emit(latestState.copyWith(messages: cleaned));
    return;
  }

  // Keep optimistic message — socket will eventually confirm or refresh will sync
  // Log the full response shape for future model mapping
  log('[INVOICE] raw response: ${result.data}');
}

  Future<void> _onSendMessage(
    SendTextMessage event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailReady) return;

    final current = state as ChatDetailReady;

    final maskedForUi = Validators.maskPhoneNumbersInText(event.content);
    final localMessage = MessageResponse(
      id: DateTime.now().millisecondsSinceEpoch * -1,
      chatId: chatId,
      senderType: event.userType,
      senderId: event.senderid,
      messageType: 'TEXT',
      content: maskedForUi,
      createdAt: DateTime.now(),
    );

    final newMessages = [localMessage, ...current.messages];

    // Update cache
    _cache.updateMessages(chatId: chatId, messages: newMessages);

    emit(
      current.copyWith(
        messages: newMessages,
      ),
    );

    _socket.sendMessage(
      SendMessageRequest(
        chatId: chatId,
        messageType: 'TEXT',
        content: event.content,
      ),
    );
  }

  Future<void> _onSendServiceRequest(
  SendServiceRequest event,
  Emitter<ChatDetailState> emit,
) async {
  if (state is! ChatDetailReady) return;

  final current = state as ChatDetailReady;

  final localMessageId = DateTime.now().millisecondsSinceEpoch * -1;

  final localMessage = MessageResponse(
    id: localMessageId,
    chatId: chatId,
    senderType: event.userType,
    senderId: event.senderId,
    messageType: 'SYSTEM',
    content: event.description,
    createdAt: DateTime.now(),
    metadata: MetadataFactories.custom(
      type: 'SERVICE_REQUEST',
      data: {
        'providerServiceId': event.providerServiceId,
        'description': event.description,
      },
    ),
  );

  final newMessages = [localMessage, ...current.messages];

  _cache.updateMessages(chatId: chatId, messages: newMessages);

  emit(current.copyWith(messages: newMessages));

  final result = await _repo.sendServiceRequestMessage(
    chatId: chatId,
    providerServiceId: event.providerServiceId,
    description: event.description,
  );

  final latestState = state;
  if (latestState is! ChatDetailReady) return;

  if (result.data == null) {
    final messagesWithoutLocal =
        latestState.messages.where((m) => m.id != localMessageId).toList();

    emit(latestState.copyWith(messages: messagesWithoutLocal));
    return;
  }

  final confirmedMessage = result.data!;
  final confirmedId = confirmedMessage.id;

  final updatedMessages =
      latestState.messages
          .where((m) => m.id != localMessageId && m.id != confirmedId)
          .toList();

  final finalMessages = [confirmedMessage, ...updatedMessages]..sort((a, b) {
    final aTime = a.createdAt ?? DateTime.now();
    final bTime = b.createdAt ?? DateTime.now();
    return bTime.compareTo(aTime);
  });

  _cache.updateMessages(chatId: chatId, messages: finalMessages);

  emit(latestState.copyWith(messages: finalMessages));
}



  void _onIncomingMessage(
    _IncomingMessage event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailReady) return;

    final current = state as ChatDetailReady;

    // Check if message already exists (avoid duplicates)
    final messageExists = current.messages.any(
      (m) => m.id == event.message.id,
    );
    if (messageExists) return;

    // Add new message and sort by createdAt descending (newest first)
    final newMessages = [event.message, ...current.messages]..sort((a, b) {
      final aTime = a.createdAt ?? DateTime.now();
      final bTime = b.createdAt ?? DateTime.now();
      return bTime.compareTo(aTime); // Descending: newest first
    });

    // Update cache with new messages
    _cache.updateMessages(chatId: chatId, messages: newMessages);

    emit(
      current.copyWith(
        messages: newMessages,
      ),
    );
  }

  Future<void> _onRefreshMessages(
    RefreshMessages event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailReady) return;

    final current = state as ChatDetailReady;

    final result = await _repo.getChatMessages(chatId);
    if (result.data == null) return;

    final messagesData = result.data!;

    // Update cache
    _cache.updateMessages(
      chatId: chatId,
      messages: messagesData.messages,
      currentPage: messagesData.page,
      totalPages: messagesData.totalPages,
      hasMoreMessages: messagesData.page < messagesData.totalPages,
    );

    emit(
      current.copyWith(
        messages: messagesData.messages,
        currentPage: messagesData.page,
        totalPages: messagesData.totalPages,
        hasMoreMessages: messagesData.page < messagesData.totalPages,
      ),
    );
  }

  Future<void> _onLoadMoreMessages(
    LoadMoreMessages event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailReady) return;

    final current = state as ChatDetailReady;

    if (current.isLoadingMore || !current.hasMoreMessages) return;

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await _repo.getChatMessages(chatId, page: nextPage);

    if (result.data == null) {
      emit(current.copyWith(isLoadingMore: false));
      return;
    }

    final messagesData = result.data!;

    // Append older messages to the end of the list
    final allMessages = [...current.messages, ...messagesData.messages];

    // Update cache
    _cache.updateMessages(
      chatId: chatId,
      messages: allMessages,
      currentPage: messagesData.page,
      totalPages: messagesData.totalPages,
      hasMoreMessages: messagesData.page < messagesData.totalPages,
    );

    emit(
      current.copyWith(
        messages: allMessages,
        currentPage: messagesData.page,
        totalPages: messagesData.totalPages,
        hasMoreMessages: messagesData.page < messagesData.totalPages,
        isLoadingMore: false,
      ),
    );
  }

  Future<void> _onBlockChat(
    ReportChat event,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      final result = await _repo.blockChat(
        chatId: event.chatId,
        reason: event.reason,
      );

      if (result.data ?? false) {
        emit(const ChatDetailReportSuccess());
      } else {
        emit(
          ChatDetailActionFailure(
            error: result.error ?? 'Failed to block chat',
          ),
        );
      }
    } on Exception catch (e) {
      emit(ChatDetailActionFailure(error: e.toString()));
    }
  }

  /// Save current state to cache before closing
  void _saveToCache() {
    if (state is ChatDetailReady) {
      final current = state as ChatDetailReady;
      _cache.cacheData(
        chatId: chatId,
        chat: current.chat,
        messages: current.messages,
        currentPage: current.currentPage,
        totalPages: current.totalPages,
        hasMoreMessages: current.hasMoreMessages,
      );
    }
  }

  @override
  Future<void> close() async {
    _saveToCache();
    await _socketSub?.cancel();
    return super.close();
  }

  Future<void> _onSendImageMessage(
    SendImageMessage event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailReady) return;

    final current = state as ChatDetailReady;
    final localMessageId = DateTime.now().millisecondsSinceEpoch * -1;

    final localMessage = MessageResponse(
      id: localMessageId,
      chatId: chatId,
      senderType: event.userType,
      senderId: event.senderId,
      messageType: 'TEXT',
      content: event.caption ?? 'Image',
      createdAt: DateTime.now(),
      fileUrl: event.filePaths.first,
      metadata: MetadataFactories.custom(
        type: 'IMAGE',
        data: {
          'files': event.filePaths,
        },
      ),
    );

    final newMessages = [localMessage, ...current.messages];
    _cache.updateMessages(chatId: chatId, messages: newMessages);
    emit(current.copyWith(messages: newMessages));

    final uploadResult = await _uploadService.uploadMultiple(
      files: event.filePaths.map(File.new).toList(),
    );

    if (uploadResult.data == null) {
      final latestState = state;
      if (latestState is! ChatDetailReady) return;

      final messagesWithoutLocal =
          latestState.messages.where((m) => m.id != localMessageId).toList();
      emit(latestState.copyWith(messages: messagesWithoutLocal));
      return;
    }

    final uploaded = uploadResult.data!;
    final uploadedUrls = uploaded.map((e) => e.url).toList();

    final firstFile = File(event.filePaths.first);
    final stat = await firstFile.length();
    final fileSizeMB = stat / (1024 * 1024);

    _socket.sendMessage(
      SendMessageRequest(
        chatId: chatId,
        messageType: 'TEXT',
        content: event.caption ?? 'Image',
        fileUrl: uploadedUrls.first,
        fileName: firstFile.path.split('/').last,
        fileSize: double.parse(fileSizeMB.toStringAsFixed(2)),
        mimeType: _getMimeType(firstFile.path),
        metadata: {
          'type': 'IMAGE',
          'files': uploadedUrls,
        },
      ),
    );

    final latestState = state;
    if (latestState is! ChatDetailReady) return;

    final updatedMessages =
        latestState.messages.map((m) {
          if (m.id == localMessageId) {
            return MessageResponse(
              id: m.id,
              chatId: m.chatId,
              senderType: m.senderType,
              senderId: m.senderId,
              messageType: m.messageType,
              content: m.content,
              createdAt: m.createdAt,
              fileUrl: uploadedUrls.first,
              metadata: MetadataFactories.custom(
                type: 'IMAGE',
                data: {
                  'files': uploadedUrls,
                },
              ),
            );
          }
          return m;
        }).toList();

    _cache.updateMessages(chatId: chatId, messages: updatedMessages);
    emit(latestState.copyWith(messages: updatedMessages));
  }

  Future<void> _onSendDocumentMessage(
    SendDocumentMessage event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailReady) return;

    final current = state as ChatDetailReady;

    final file = File(event.filePath);
    final fileName = file.path.split('/').last;

    final localMessageId = DateTime.now().millisecondsSinceEpoch * -1;
    final localMessage = MessageResponse(
      id: localMessageId,
      chatId: chatId,
      senderType: event.userType,
      senderId: event.senderId,
      messageType: 'TEXT',
      content: fileName,
      createdAt: DateTime.now(),
      fileName: fileName,
      fileUrl: event.filePath,
      metadata: MetadataFactories.custom(
        type: 'DOCUMENT',
        data: {},
      ),
    );

    final newMessages = [localMessage, ...current.messages];
    _cache.updateMessages(chatId: chatId, messages: newMessages);

    emit(current.copyWith(messages: newMessages));

    final uploadResult = await _uploadService.uploadSingle(
      filePath: event.filePath,
    );

    final latestState = state;
    if (latestState is! ChatDetailReady) return;

    if (uploadResult.data == null) {
      final messagesWithoutLocal =
          latestState.messages.where((m) => m.id != localMessageId).toList();
      emit(latestState.copyWith(messages: messagesWithoutLocal));
      return;
    }

    final upload = uploadResult.data!;

    final fileSize = await file.length();
    final fileSizeInMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
    final mimeType = _getMimeType(file.path);

    _socket.sendMessage(
      SendMessageRequest(
        chatId: chatId,
        messageType: 'TEXT',
        content: fileName,
        fileName: fileName,
        fileUrl: upload.url,
        fileSize: double.parse(fileSizeInMB),
        mimeType: mimeType,
        metadata: {
          'type': 'DOCUMENT',
        },
      ),
    );

    final updatedMessages =
        latestState.messages.map((m) {
          if (m.id == localMessageId) {
            return MessageResponse(
              id: m.id,
              chatId: m.chatId,
              senderType: m.senderType,
              senderId: m.senderId,
              messageType: m.messageType,
              content: m.content,
              createdAt: m.createdAt,
              fileName: m.fileName,
              fileUrl: upload.url,
              fileSize: m.fileSize,
              mimeType: mimeType,
              metadata: m.metadata,
            );
          }
          return m;
        }).toList();

    _cache.updateMessages(chatId: chatId, messages: updatedMessages);
    emit(latestState.copyWith(messages: updatedMessages));
  }

  Future<void> _onSendLocationMessage(
    SendLocationMessage event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailReady) return;

    final current = state as ChatDetailReady;

    final localMessageId = DateTime.now().millisecondsSinceEpoch * -1;
    final localMessage = MessageResponse(
      id: localMessageId,
      chatId: chatId,
      senderType: event.userType,
      senderId: event.senderId,
      messageType: 'TEXT',
      content: event.address,
      createdAt: DateTime.now(),
      metadata: MetadataFactories.location(
        latitude: event.latitude,
        longitude: event.longitude,
        address: event.address,
      ),
    );

    final newMessages = [localMessage, ...current.messages];
    _cache.updateMessages(chatId: chatId, messages: newMessages);

    emit(current.copyWith(messages: newMessages));

    _socket.sendMessage(
      SendMessageRequest(
        chatId: chatId,
        messageType: 'TEXT',
        content: event.address,
        metadata: {
          'type': 'LOCATION',
          'latitude': event.latitude,
          'longitude': event.longitude,
          'address': event.address,
        },
      ),
    );
  }

  String _getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
