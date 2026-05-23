import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/__services.dart';
import 'package:resq360/core/services/chat_cache_service.dart';
import 'package:resq360/core/services/chat_socket_service.dart';
import 'package:resq360/core/services/upload_service.dart';
import 'package:resq360/core/utils/validators.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';
import 'package:resq360/features/chat/data/services/chat_repo.dart';
import 'package:resq360/features/settings/data/models/ticket_message.model.dart';

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
    on<_MessageDelivered>(_onMessageDelivered);
    on<_AllMessagesDelivered>(_onAllMessagesDelivered);
    on<_MessageRead>(_onMessageRead);
    on<_AllMessagesRead>(_onAllMessagesRead);
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
  final List<StreamSubscription<dynamic>> _socketSubs = [];

  Future<void> _onOpenChatDetail(
    OpenChatDetail event,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      final cachedData = _cache.getCachedData(event.chatId);
      if (cachedData != null) {
        emit(
          ChatDetailReady(
            chat: cachedData.chat,
            messages: cachedData.messages,
            currentPage: cachedData.currentPage,
            totalPages: cachedData.totalPages,
            hasMoreMessages: cachedData.hasMoreMessages,
          ),
        );

        await _connectSocket();

        await _refreshInBackground(event.chatId, emit);
        return;
      }

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

      _cache.cacheData(
        chatId: chatId,
        chat: chat,
        messages: messagesData.messages,
        currentPage: messagesData.page,
        totalPages: messagesData.totalPages,
        hasMoreMessages: messagesData.page < messagesData.totalPages,
      );

      if (state is ChatDetailReady) {
        final current = state as ChatDetailReady;

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
    } on Exception catch (e) {
      log('Background refresh failed: $e');
    }
  }

  Future<void> _connectSocket() async {
    try {
      await _socket.connect();

      unawaited(_socket.joinChat(chatId));

      // Mark all messages as read when opening the chat
      _socket.markAllRead(chatId);

      for (final sub in _socketSubs) {
        await sub.cancel();
      }
      _socketSubs
        ..clear()
        ..add(
          _socket.messageStream.listen((msg) {
            final isForThisChat = msg.chatId == chatId;
            final isFromCurrentUser =
                currentUserId != null && (msg.senderId == currentUserId);

            if (isForThisChat) {
              add(_IncomingMessage(msg));

              // Auto-mark incoming messages as read since the chat is open
              if (!isFromCurrentUser && msg.id != null) {
                _socket.markAsRead(messageId: msg.id!, chatId: chatId);
              }
            }
          }),
        )
        ..add(
          _socket.messageDeliveredStream.listen((data) {
            final messageId = data['messageId'] as int?;
            if (messageId != null) {
              add(_MessageDelivered(messageId));
            }
          }),
        )
        ..add(
          _socket.allDeliveredStream.listen((data) {
            final deliveredChatId = data['chatId'] as int?;
            if (deliveredChatId == chatId) {
              add(_AllMessagesDelivered(chatId));
            }
          }),
        )
        ..add(
          _socket.messageReadStream.listen((data) {
            final messageId = data['messageId'] as int?;
            if (messageId != null) {
              add(_MessageRead(messageId));
            }
          }),
        )
        ..add(
          _socket.allReadStream.listen((data) {
            final readChatId = data['chatId'] as int?;
            if (readChatId == chatId) {
              add(_AllMessagesRead(chatId));
            }
          }),
        )
        ..add(
          _socket.paymentEventStream.listen((eventChatId) {
            if (eventChatId == chatId) {
              add(RefreshMessages());
            }
          }),
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

    _cache.updateMessages(chatId: chatId, messages: newMessages);

    emit(current.copyWith(messages: newMessages));

    final result = await _repo.sendInvoice(invoiceRequest: event.invoice);

    final latestState = state;
    if (latestState is! ChatDetailReady) return;

    if (result.data == null) {
      final messagesWithoutLocal =
          latestState.messages.where((m) => m.id != localMessageId).toList();
      emit(latestState.copyWith(messages: messagesWithoutLocal));
      return;
    }

    final confirmedId = result.data!.id;
    final confirmedMessages =
        latestState.messages
            .where((m) => m.id != localMessageId && m.id != confirmedId)
            .toList();

    final finalMessages = [result.data!, ...confirmedMessages]..sort((a, b) {
      final aTime = a.createdAt ?? DateTime.now();
      final bTime = b.createdAt ?? DateTime.now();
      return bTime.compareTo(aTime);
    });

    _cache.updateMessages(chatId: chatId, messages: finalMessages);

    emit(latestState.copyWith(messages: finalMessages));
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
      senderId: currentUserId,
      messageType: 'INVOICE',
      content: event.invoice.description ?? 'Invoice',
      createdAt: DateTime.now(),
      metadata: Metadata(
        type: 'INVOICE',
        amount: event.invoice.amount,
        currency: event.invoice.currency,
        invoiceId: event.invoice.invoiceId,
        description: event.invoice.description,
        date: event.invoice.date?.toIso8601String(),
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

    _cache.updateMessages(chatId: chatId, messages: newMessages);

    emit(current.copyWith(messages: newMessages));

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

    final messageExists = current.messages.any((m) => m.id == event.message.id);
    if (messageExists) return;

    // Replace optimistic local message with server-confirmed one for sender.
    final isFromCurrentUser =
        currentUserId != null && event.message.senderId == currentUserId;
    if (isFromCurrentUser) {
      final pendingLocalIndex = current.messages.indexWhere(
        (m) =>
            (m.id ?? 0) < 0 &&
            m.senderId == event.message.senderId &&
            m.messageType == event.message.messageType &&
            (m.messageType == 'INVOICE' ||
                (m.content ?? '') == (event.message.content ?? '')),
      );

      if (pendingLocalIndex != -1) {
        final reconciledMessages =
            [...current.messages]
              ..removeAt(pendingLocalIndex)
              ..insert(0, event.message)
              ..sort((a, b) {
                final aTime = a.createdAt ?? DateTime.now();
                final bTime = b.createdAt ?? DateTime.now();
                return bTime.compareTo(aTime);
              });

        _cache.updateMessages(chatId: chatId, messages: reconciledMessages);
        emit(current.copyWith(messages: reconciledMessages));
        return;
      }
    }

    final newMessages = [event.message, ...current.messages]..sort((a, b) {
      final aTime = a.createdAt ?? DateTime.now();
      final bTime = b.createdAt ?? DateTime.now();
      return bTime.compareTo(aTime);
    });
    _cache.updateMessages(chatId: chatId, messages: newMessages);

    emit(current.copyWith(messages: newMessages));
  }

  void _onMessageDelivered(
    _MessageDelivered event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailReady) return;
    final current = state as ChatDetailReady;

    final updated =
        current.messages.map((m) {
          if (m.id == event.messageId && m.status == MessageStatus.sent) {
            return m.copyWith(
              status: MessageStatus.delivered,
              isDelivered: true,
            );
          }
          return m;
        }).toList();

    _cache.updateMessages(chatId: chatId, messages: updated);
    emit(current.copyWith(messages: updated));
  }

  void _onAllMessagesDelivered(
    _AllMessagesDelivered event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailReady) return;
    final current = state as ChatDetailReady;

    final updated =
        current.messages.map((m) {
          if (m.status == MessageStatus.sent) {
            return m.copyWith(
              status: MessageStatus.delivered,
              isDelivered: true,
            );
          }
          return m;
        }).toList();

    _cache.updateMessages(chatId: chatId, messages: updated);
    emit(current.copyWith(messages: updated));
  }

  void _onMessageRead(_MessageRead event, Emitter<ChatDetailState> emit) {
    if (state is! ChatDetailReady) return;
    final current = state as ChatDetailReady;

    final updated =
        current.messages.map((m) {
          if (m.id == event.messageId && m.status != MessageStatus.read) {
            return m.copyWith(status: MessageStatus.read);
          }
          return m;
        }).toList();

    _cache.updateMessages(chatId: chatId, messages: updated);
    emit(current.copyWith(messages: updated));
  }

  void _onAllMessagesRead(
    _AllMessagesRead event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailReady) return;
    final current = state as ChatDetailReady;

    final updated =
        current.messages.map((m) {
          if (m.status != MessageStatus.read) {
            return m.copyWith(status: MessageStatus.read);
          }
          return m;
        }).toList();

    _cache.updateMessages(chatId: chatId, messages: updated);
    emit(current.copyWith(messages: updated));
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

    final allMessages = [...current.messages, ...messagesData.messages];

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
    for (final sub in _socketSubs) {
      await sub.cancel();
    }
    _socketSubs.clear();
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
        data: {'files': event.filePaths},
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
        metadata: {'type': 'IMAGE', 'files': uploadedUrls},
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
                data: {'files': uploadedUrls},
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
      metadata: MetadataFactories.custom(type: 'DOCUMENT', data: {}),
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
        metadata: {'type': 'DOCUMENT'},
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
