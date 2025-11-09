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

  final _messageController = StreamController<MessageResponse>.broadcast();
    final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _userJoinedController = StreamController<Map<String, dynamic>>.broadcast();
  final _userLeftController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageReadController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
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

    _socket!.onConnect((_) => log('✅ Socket connected to $url'));
    _socket!.onDisconnect((_) => log('❌ Socket disconnected'));
    _socket!.onConnectError((e) => log('⚠️ Socket connect error: $e'));

  // Listen for chat notifications
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
       final message =
              MessageResponse.fromJson(data['data'] as Map<String, dynamic>);
          _messageController.add(message);
        _messageController.add(message);

      case 'USER_TYPING':
        _typingController.add(notification['data'] as Map<String, dynamic>);

      case 'USER_JOINED':
        _userJoinedController.add(notification['data']as Map<String, dynamic>);

      case 'USER_LEFT':
        _userLeftController.add(notification['data']as Map<String, dynamic>);

      case 'MESSAGE_READ':
        _messageReadController.add(notification['data']as Map<String, dynamic>);

      default:
        log('Unknown notification type: $type');
    }
  }


  Future<void> disconnect()async {
    _socket?.disconnect();
    await _messageController.close();
  }
}
