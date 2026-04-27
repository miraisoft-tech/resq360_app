import 'package:dio/dio.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/core/services/base_api.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';

class ChatRepo extends BaseAPI {
  factory ChatRepo() => _instance;
  ChatRepo._internal();
  static final ChatRepo _instance = ChatRepo._internal();

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

      if (response.statusCode == 201 && response.data != null) {
        final json = response.data!;
        if (json['data'] != null) {
          final chatData = ChatResponse.fromJson(
            json['data'] as Map<String, dynamic>,
          );
          return ApiResult(data: chatData);
        } else {
          return ApiResult(error: 'Invalid response format');
        }
      }
      return ApiResult(error: 'Faild to create chat');
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      log('creating chat failed $e');
      return ApiResult(error: e.toString());
    }
  }

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
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      log('failed to fetch chat $e');
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<ChatResponse>> getChatById(int chatId) async {
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
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<ChatResponse>> getChatByserviceRequestId(
    int serviceRequestId,
  ) async {
    final url = '/chat/service-request/$serviceRequestId';
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
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<ChatMessagesResponse>> getChatMessages(
    int chatId, {
    int page = 1,
    int limit = 20,
  }) async {
    final url = '/chat/$chatId/messages?page=$page&limit=$limit';

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
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

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
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<MessageResponse>> sendServiceRequestMessage({
    required int chatId,
    required int providerServiceId,
    required String description,
  }) async {
    const url = '/chat/messages/service-request';

    final payload = {
      'chatId': chatId,
      'providerServiceId': providerServiceId,
      'description': description,
    };

    try {
      final response = await dio().post<Map<String, dynamic>>(
        url,
        data: payload,
      );

      if (response.statusCode == 201 && response.data != null) {
        final responseData = response.data!;
        debugPrint('service-request API response: $responseData');

        final messageData = responseData['data'] as Map<String, dynamic>?;
        if (messageData == null) {
          return ApiResult(error: 'Invalid response: missing data field');
        }

        final message = MessageResponse.fromJson(messageData);
        return ApiResult(data: message);
      } else {
        return ApiResult(
          error:
              response.data?['message'].toString() ?? 'Failed to send message',
        );
      }
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<MessageResponse>> sendInvoice({
    required SendInvoice invoiceRequest,
  }) async {
    const url = '/chat/messages/invoice';
    try {
      final response = await dio().post<Map<String, dynamic>>(
        url,
        data: invoiceRequest.toJson(),
      );

      if (response.statusCode == 201 && response.data != null) {
        final responseData = response.data!;
        debugPrint('Invoice API response: $responseData');

        final messageData = responseData['data'] as Map<String, dynamic>?;
        if (messageData == null) {
          return ApiResult(error: 'Invalid response: missing data field');
        }

        final message = MessageResponse.fromJson(messageData);
        return ApiResult(data: message);
      } else {
        return ApiResult(
          error:
              response.data?['message'].toString() ?? 'Failed to send message',
        );
      }
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<bool>> markMessageAsRead(int messageId) async {
    final url = '/chat/messages/$messageId/read';
    try {
      final response = await dio().post<Map<String, dynamic>>(url);
      if (response.statusCode == 200) {
        return ApiResult(data: true);
      } else {
        return ApiResult(error: 'Failed to mark as read');
      }
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<bool>> leaveChat(int chatId) async {
    final url = '/chat/$chatId/leave';
    try {
      final response = await dio().post<Map<String, dynamic>>(url);
      if (response.statusCode == 200) {
        return ApiResult(data: true);
      } else {
        return ApiResult(error: 'Failed to leave chat');
      }
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<bool>> blockChat({
    required int chatId,
    required String reason,
  }) async {
    final url = '/chat/$chatId/report';
    try {
      final response = await dio().post<Map<String, dynamic>>(
        url,
        data: {'reason': reason},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        log('Chat $chatId blocked successfully');
        return ApiResult(data: true);
      } else {
        return ApiResult(
          error:
              response.data?['message'].toString() ?? 'Failed to blocked chat',
        );
      }
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      log('Block chat failed: $e');
      return ApiResult(error: e.toString());
    }
  }

  Future<ApiResult<bool>> reportMessage({
    required int messageId,
    required String reason,
  }) async {
    final url = '/chat/message/$messageId/report';
    try {
      final response = await dio().post<Map<String, dynamic>>(
        url,
        data: {'reason': reason},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResult(data: true);
      }

      return ApiResult(
        error:
            response.data?['message'].toString() ?? 'Failed to report message',
      );
    } on DioException catch (e) {
      return handleDioError(e);
    } on Exception catch (e) {
      return ApiResult(error: e.toString());
    }
  }
}
