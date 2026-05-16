import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';

import 'package:socket_io_client/socket_io_client.dart' as io_client;

class ChatSocketService {
  ChatSocketService._internal();
  static final ChatSocketService instance = ChatSocketService._internal();

  io_client.Socket? _socket;
  DateTime? _connectedAt;
  int _retryCount = 0;

  final _messageController = StreamController<MessageResponse>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _userJoinedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _userLeftController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageReadController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageDeliveredController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _allDeliveredController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _allReadController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<MessageResponse> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get messageReadStream =>
      _messageReadController.stream;
  Stream<Map<String, dynamic>> get messageDeliveredStream =>
      _messageDeliveredController.stream;
  Stream<Map<String, dynamic>> get allDeliveredStream =>
      _allDeliveredController.stream;
  Stream<Map<String, dynamic>> get allReadStream => _allReadController.stream;

  bool get isConnected => _socket?.connected ?? false;

  final Set<String> _emittedMessageKeys = {};

  Completer<void>? _connectionCompleter;
  String? _currentToken;

  Future<void> connect({bool forceReconnect = false}) async {
    final token = await AuthLocalRepo.instance.getAccessToken();

    if (isConnected && !forceReconnect && _currentToken == token) {
      return;
    }

    if (_socket != null && (_currentToken != token || forceReconnect)) {
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
    }

    _currentToken = token;

    const url = 'https://api.resq360.ng/chat';

    _connectionCompleter = Completer<void>();

    _socket = io_client.io(
      url,
      io_client.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      _connectedAt = DateTime.now();
      _retryCount = 0;

      log('Socket connected at $_connectedAt');

      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.complete();
      }
    });

    _socket!.onDisconnect((_) {
      if (_connectedAt != null) {
        final uptime = DateTime.now().difference(_connectedAt!);
        log('Socket disconnected — uptime: ${uptime.inSeconds}s');
      }
      _connectedAt = null;
    });

    _socket!.onConnectError((error) {
      _retryCount++;
      log('Socket error: $error | Retry #$_retryCount');

      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.completeError(
          Exception('Socket connection error: $error'),
        );
      }
    });

    _socket!.onReconnect((_) {
      _connectedAt = DateTime.now();
      _retryCount = 0;
      log('Reconnected successfully');
    });

    _socket!.onAny((event, data) {
      log('Event: $event | Data: $data');
    });

    _socket?.on('chat-notification', (data) {
      log('Chat notification: $data');

      try {
        _handleChatNotification(data);
      } on Exception catch (e) {
        log('Parse error: $e');
      }
    });

    _socket!.connect();

    return _connectionCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Socket connection timeout');
      },
    );
  }

  io_client.Socket? get socket => _socket;

  Future<void> joinChat(int chatId) async {
    if (!isConnected) return;

    final completer = Completer<void>();

    _socket?.emitWithAck(
      'join-chat',
      {'chatId': chatId},
      ack: (dynamic resp) {
        log('Joined chat $chatId | Ack: $resp');
        completer.complete();
      },
    );

    return completer.future;
  }

  void sendMessage(SendMessageRequest payload) {
    if (!isConnected) {
      log('Socket not connected');
      return;
    }

    _socket?.emit('send-message', payload.toJson());
  }

  /// Mark a single message as delivered.
  void markDelivered({required int messageId, required int chatId}) {
    if (!isConnected) return;
    _socket?.emit('message-delivered', {
      'messageId': messageId,
      'chatId': chatId,
    });
  }

  /// Mark all undelivered messages in a chat as delivered.
  void markAllDelivered(int chatId) {
    if (!isConnected) return;
    _socket?.emit('mark-all-delivered', {'chatId': chatId});
  }

  /// Mark a single message as read.
  void markAsRead({required int messageId, required int chatId}) {
    if (!isConnected) return;
    _socket?.emit('mark-as-read', {'messageId': messageId, 'chatId': chatId});
  }

  /// Mark all messages in a chat as read (call when user opens the chat).
  void markAllRead(int chatId) {
    if (!isConnected) return;
    _socket?.emit('mark-all-read', {'chatId': chatId});
  }

  void _handleChatNotification(dynamic data) {
    final notification = data as Map<String, dynamic>;
    final type = notification['type'] as String?;

    switch (type) {
      case 'NEW_MESSAGE':
        final messageData = data['data'] as Map<String, dynamic>;
        final message = MessageResponse.fromJson(messageData);

        final key = _messageKey(message);

        if (_emittedMessageKeys.add(key)) {
          _messageController.add(message);
        }

      case 'USER_TYPING':
        _typingController.add(notification['data'] as Map<String, dynamic>);

      case 'USER_JOINED':
        _userJoinedController.add(notification['data'] as Map<String, dynamic>);

      case 'USER_LEFT':
        _userLeftController.add(notification['data'] as Map<String, dynamic>);

      case 'MESSAGE_DELIVERED':
        _messageDeliveredController.add(
          notification['data'] as Map<String, dynamic>,
        );

      case 'MESSAGES_ALL_DELIVERED':
        final payload = <String, dynamic>{
          'chatId': notification['chatId'],
          ...notification['data'] as Map<String, dynamic>,
        };
        _allDeliveredController.add(payload);

      case 'MESSAGE_READ':
        _messageReadController.add(
          notification['data'] as Map<String, dynamic>,
        );

      case 'MESSAGES_ALL_READ':
        final payload = <String, dynamic>{
          'chatId': notification['chatId'],
          ...notification['data'] as Map<String, dynamic>,
        };
        _allReadController.add(payload);

      default:
        log('Unknown type: $type');
    }
  }

  String _messageKey(MessageResponse m) {
    return '${m.id}_${m.chatId}_${m.createdAt?.millisecondsSinceEpoch}';
  }

  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentToken = null;
    _connectedAt = null;
  }

  Future<void> reset() async {
    await disconnect();
    _retryCount = 0;
  }

  Future<void> dispose() async {
    await disconnect();

    await _messageController.close();
    await _typingController.close();
    await _userJoinedController.close();
    await _userLeftController.close();
    await _messageReadController.close();
    await _messageDeliveredController.close();
    await _allDeliveredController.close();
    await _allReadController.close();
  }
}
