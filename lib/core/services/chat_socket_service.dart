import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_models.dart';

// it's how it was done in the documentaton
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketService {
  ChatSocketService._internal();
  static final ChatSocketService instance = ChatSocketService._internal();

  IO.Socket? _socket;
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
  Stream<MessageResponse> get messageStream => _messageController.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    final token = await AuthLocalRepo.instance.getAccessToken();
    const url = 'https://resq360-kspk.onrender.com';

    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
    _connectedAt = DateTime.now();
      _retryCount = 0;
      log('Socket connected to $url at $_connectedAt');
    }
    );
   
    _socket!.onDisconnect((_) {
      if (_connectedAt != null) {
        final uptime = DateTime.now().difference(_connectedAt!);
        log('Socket disconnected — uptime: ${uptime.inSeconds}s');
      } else {
        log('Socket disconnected before handshake completed');
      }
      _connectedAt = null;
    });

   
    _socket!.onConnectError((error) {
      _retryCount++;
      log('Socket connection error: $error | Retry #$_retryCount');
    });

    
    _socket!.onReconnect((attempt) {
      log('Attempting reconnection #$attempt ...');
    });

  
    _socket!.onReconnect((_) {
      _connectedAt = DateTime.now();
      log(' Reconnected successfully after $_retryCount retries at $_connectedAt');
      _retryCount = 0;
    });

  
    _socket!.onReconnectError((error) {
      log(' Failed to reconnect: $error');
    });

    
    _socket!.onAny((event, data) {
      log('Event: $event | Data: $data');
    });
    _socket?.on('chat-notification', (data) {
      log('Chat notification received: $data');
      _handleChatNotification(data);
    });

    _socket!.connect();
  }

  void _handleChatNotification(dynamic data) {
    final notification = data as Map<String, dynamic>;
    final type = notification['type'];

    switch (type) {
      case 'NEW_MESSAGE':
        final message = MessageResponse.fromJson(
          data['data'] as Map<String, dynamic>,
        );
        _messageController.add(message);

      case 'USER_TYPING':
        _typingController.add(notification['data'] as Map<String, dynamic>);

      case 'USER_JOINED':
        _userJoinedController.add(notification['data'] as Map<String, dynamic>);

      case 'USER_LEFT':
        _userLeftController.add(notification['data'] as Map<String, dynamic>);

      case 'MESSAGE_READ':
        _messageReadController.add(
          notification['data'] as Map<String, dynamic>,
        );

      default:
        log('Unknown notification type: $type');
    }
  }

  Future<void> disconnect() async {
    _socket?.disconnect();
    await Future.wait([
      _messageController.close(),
      _typingController.close(),
      _userJoinedController.close(),
      _userLeftController.close(),
      _messageReadController.close(),
    ]);
  }
}
