import 'dart:async';
import 'dart:convert';

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

 Completer<void>? _connectionCompleter;

  Future<void> connect() async {
    final token = await AuthLocalRepo.instance.getAccessToken();
    const url = 'https://resq360-kspk.onrender.com/chat';

    _connectionCompleter = Completer<void>();

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
      
      // Complete the connection future
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        _connectionCompleter!.complete();
      }
    });
   
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
  
  // Complete with error - cast to Object or use Exception
  if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
    _connectionCompleter!.completeError(
      Exception('Socket connection error: ${error.toString()}')
    );
  }
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

   _socket!.onAny((event, data) {
  log('Event: $event | Data: $data');
});


_socket?.on('chat-notification', (data) {
  log('Chat notification received: $data');
  
  try {
    final notification = data as Map<String, dynamic>;
    final type = notification['type'] as String?;
    
    switch (type) {
      case 'NEW_MESSAGE':
        final messageData = notification['data'] as Map<String, dynamic>;
        final message = MessageResponse.fromJson(messageData);
        _messageController.add(message);
        log('Message added to stream: ${message.content}');
        
      case 'USER_TYPING':
        _typingController.add(notification['data'] as Map<String, dynamic>);
        
      case 'USER_JOINED':
        _userJoinedController.add(notification['data'] as Map<String, dynamic>);
        
      case 'USER_LEFT':
        _userLeftController.add(notification['data'] as Map<String, dynamic>);
        
      case 'MESSAGE_READ':
        _messageReadController.add(notification['data'] as Map<String, dynamic>);
        
      default:
        log('Unknown notification type: $type');
    }
  } on Exception catch (e) {
    log(' Failed to parse chat notification: $e');
  }
});

    _socket!.connect();
    
    // Wait for connection to be established
    return _connectionCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Socket connection timeout');
      },
    );
  }

  IO.Socket? get socket => _socket;
  
  

  Future<void> joinChat(int chatId) async {
    if (!isConnected) {
      debugPrint('Join aborted: socket not connected');
      return;
    }

    final completer = Completer<void>();

    _socket?.emitWithAck(
      'join-chat',
      {'chatId': chatId},
      ack: (dynamic resp) {
        log(' Joined chat $chatId | Ack: $resp');
        completer.complete();
      },
    );

    return completer.future;
  }

  void sendMessage (SendMessageRequest payload){
    if (!isConnected) {
    log(' Cannot send message — socket not connected');
    return;
  }
    _socket?.emitWithAck('send-message', payload.toJson(), ack: ( dynamic response) {
      log('Server acknowledged message: $response');
      if (response['success'] == true) {
      final message = MessageResponse.fromJson(response['message'] as Map<String, dynamic>);
      _messageController.add(message);
    }
    });
  }

  // void _handleChatNotification(dynamic data) {
  //   final notification = data as Map<String, dynamic>;
  //   final type = notification['type'];

  //   switch (type) {
  //     case 'NEW_MESSAGE':
  //       final message = MessageResponse.fromJson(
  //         data['data'] as Map<String, dynamic>,
  //       );
  //       _messageController.add(message);

  //     case 'USER_TYPING':
  //       _typingController.add(notification['data'] as Map<String, dynamic>);

  //     case 'USER_JOINED':
  //       _userJoinedController.add(notification['data'] as Map<String, dynamic>);

  //     case 'USER_LEFT':
  //       _userLeftController.add(notification['data'] as Map<String, dynamic>);

  //     case 'MESSAGE_READ':
  //       _messageReadController.add(
  //         notification['data'] as Map<String, dynamic>,
  //       );

  //     default:
  //       log('Unknown notification type: $type');
  //   }
  // }

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
