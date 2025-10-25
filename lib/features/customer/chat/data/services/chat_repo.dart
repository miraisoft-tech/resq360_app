import 'dart:developer';

import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_models.dart';
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
      log('Creating chat with payload: ${chatRequest.toJson()}');
      log('Response: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final json = response.data!;
        final chatData = ChatResponse.fromJson(json);
        return ApiResult(data: chatData);
      } else {
        return ApiResult(error: 'Failed to create chat');
      }
    } on Exception catch (e) {
      log('creating chat failed $e');
      return ApiResult(error: e.toString());
    }
  }

  /// Get all chats for the current user
  Future<ApiResult<ChatListResponse>> getChats({
    int? pageNumber,
    int? limit,
  }) async {
    log('Fetching chats');
    const url = '/chat';
    try {
      final response = await dio().get<Map<String, dynamic>>(url);

      if (response.statusCode == 200 && response.data != null) {
        log(response.statusCode.toString());
        final data = ChatListResponse.fromJson(
          response.data!['data'] as Map<String, dynamic>,
        );
        return ApiResult(data: data);
      } else {
        return ApiResult(error: 'Failed to load chats');
      }
    } on Exception catch (e) {
      log('failed to fetch chat $e');
      return ApiResult(error: e.toString());
    }
  }

  /// Get a single chat by ID
  Future<ApiResult<ChatResponse>> getChatById(String chatId) async {
    final url = '/chat/$chatId';
    try {
      final response = await dio().get<Map<String, dynamic>>(url);
      if (response.statusCode == 200 && response.data != null) {
        final chat = ChatResponse.fromJson(
          response.data!['data'] as Map<String, dynamic>,
        );
        return ApiResult(data: chat);
      } else {
        return ApiResult(error: 'Failed to fetch chat');
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  /// Get all messages for a specific chat
  Future<ApiResult<ChatMessagesResponse>> getChatMessages(
    int chatId, {
    int page = 1,
    int limit = 20,
  }) async {
    final url = '/chat/$chatId/messages';

    try {
      final response = await dio().get<Map<String, dynamic>>(url);

      if (response.statusCode == 200 && response.data != null) {
        final messages = ChatMessagesResponse.fromJson(
          response.data!['data'] as Map<String, dynamic>,
        );
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
        final messageData = response.data!;
        final message = MessageResponse.fromJson(messageData);
        return ApiResult(data: message);
      } else {
        return ApiResult(
          error:
              response.data?['message'].toString() ?? 'Failed to send message',
        );
      }
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  /// Mark a message as read
  Future<ApiResult<bool>> markMessageAsRead(int messageId) async {
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
  Future<ApiResult<bool>> leaveChat(int chatId) async {
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
