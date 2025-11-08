import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_models.dart';

// it's how it was done in the documentaton
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketService {
  static final ChatSocketService instance = ChatSocketService._internal();
  ChatSocketService._internal();

  IO.Socket? _socket;

  final _messageController = StreamController<MessageResponse>.broadcast();
  Stream<MessageResponse> get messageStream => _messageController.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    final token = await AuthLocalRepo.instance.getAccessToken();
    const url = 'https://resq360-kspk.onrender.com'; // ✅ confirmed socket base

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

    // Listen for new messages
    _socket!.on('chat-notification', (data) {
      try {
        if (data is Map && data['type'] == 'NEW_MESSAGE') {
          final message =
              MessageResponse.fromJson(data['data'] as Map<String, dynamic>);
          _messageController.add(message);
        }
      } on Exception catch (e) {
        log('⚠️ Failed to parse incoming message: $e');
      }
    });

    _socket!.connect();
  }


  Future<void> disconnect()async {
    _socket?.disconnect();
    await _messageController.close();
  }
}
