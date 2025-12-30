import 'package:resq360/features/customer/chat/data/models/chat/message_response.dart';

class ChatMessagesResponse {

  ChatMessagesResponse({
    required this.messages,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory ChatMessagesResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessagesResponse(
      messages: (json['messages'] as List<dynamic>)
          .map((e) => MessageResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
  final List<MessageResponse> messages;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
}
