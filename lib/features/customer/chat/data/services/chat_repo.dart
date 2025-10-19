import 'package:resq360/core/models/api_response.dart';
import 'package:resq360/features/customer/chat/data/models/chat_model.dart';
import 'package:resq360/core/services/base_api.dart';

class ChatRepo extends BaseAPI {
  factory ChatRepo() {
    return _instance;
  }
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
}
