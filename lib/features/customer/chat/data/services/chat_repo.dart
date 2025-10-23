import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/customer/chat/data/models/chat_model.dart';

import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/customer/chat/data/models/chat_model.dart';

class ChatRepo extends BaseAPI {
  factory ChatRepo() => _instance;
  ChatRepo._internal();
  static final ChatRepo _instance = ChatRepo._internal();

  /// Create a new chat
  Future<ApiResult<ChatResponse>> createChat({
    required CreateChatRequest chatRequest,
  }) async {
    const url = '/chat';
    try {
      final response = await dio().post<Map<String, dynamic>>(
        url,
        data: chatRequest.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final json = response.data!;
        final chatData =
            ChatResponse.fromJson(json['data'] as Map<String, dynamic>);
        return ApiResult(data: chatData);
      } else {
        return ApiResult(error: 'Failed to create chat');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  /// Get all chats for the current user
  Future<ApiResult<List<ChatResponse>>> getChats({
    int? pageNumber,
    int? limit,
  }) async {
    const url = '/chat';
    try {
      final response = await dio().get<Map<String, dynamic>>(url);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data!['data'] as List<dynamic>;
        final chats = list
            .map((e) => ChatResponse.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResult(data: chats);
      } else {
        return ApiResult(error: 'Failed to load chats');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  /// Get a single chat by ID
  Future<ApiResult<ChatResponse>> getChatById(String chatId) async {
    final url = '/chat/$chatId';
    try {
      final response = await dio().get<Map<String, dynamic>>(url);
      if (response.statusCode == 200 && response.data != null) {
        final chat =
            ChatResponse.fromJson(response.data!['data'] as Map<String, dynamic>);
        return ApiResult(data: chat);
      } else {
        return ApiResult(error: 'Failed to fetch chat');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

 
/// Get all messages for a specific chat
Future<ApiResult<ChatMessagesResponse>> getChatMessages(String chatId,{  int page = 1,
  int limit = 20,} ) async {
  final url = '/chat/$chatId/messages';

  try {
    final response = await dio().get<Map<String, dynamic>>(url);

    if (response.statusCode == 200 && response.data != null) {
      final messages = ChatMessagesResponse.fromJson(response.data!);
      return ApiResult(data: messages);
    } else {
      return ApiResult(error: 'Failed to fetch chat messages');
    }
  } on Exception catch (e) {
    return ApiResult(error: e.toString());
  }
}


   /// Send a message
 Future<ApiResult<MessageResponse>> sendMessage({
  required SendMessageRequest messageRequest,
}) async {
  const url = '/chat/messages';
  try {
    final response = await dio().post<Map<String, dynamic>>(
      url,
      data: messageRequest.toJson(),
    );

    if (response.statusCode == 201 && response.data != null) {
      final messageData = response.data!['data'] as Map<String, dynamic>;
      final message = MessageResponse.fromJson(messageData);
      return ApiResult(data: message);
    } else {
      return ApiResult(error: response.data?['message'].toString() ?? 'Failed to send message');
    }
  } on Exception catch (e) {
    return ApiResult(error: e.toString());
  }
}


  /// Mark a message as read
  Future<ApiResult<bool>> markMessageAsRead(String messageId) async {
    final url = '/chat/messages/$messageId/read';
    try {
      final response = await dio().post<Map<String, dynamic>>(url);
      if (response.statusCode == 200) {
        return ApiResult(data: true);
      } else {
        return ApiResult(error: 'Failed to mark as read');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  /// Leave a chat
  Future<ApiResult<bool>> leaveChat(String chatId) async {
    final url = '/chat/$chatId/leave';
    try {
      final response = await dio().post<Map<String, dynamic>>(url);
      if (response.statusCode == 200) {
        return ApiResult(data: true);
      } else {
        return ApiResult(error: 'Failed to leave chat');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }
}
