import 'chat_response.dart';

/// Represents paginated list of chats
class ChatListResponse {

  ChatListResponse({
    required this.chats,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

factory ChatListResponse.fromJson(Map<String, dynamic> json) =>
    ChatListResponse(
      chats: (json['chats'] as List<dynamic>)
          .map((e) => ChatResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as int?) ?? 0,
      page: (json['page'] as int?) ?? 0,
      limit: (json['limit'] as int?) ?? 0,
      totalPages: (json['totalPages'] as int?) ?? 0,
    );
  final List<ChatResponse> chats;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Map<String, dynamic> toJson() => {
        'chats': chats.map((e) => e.toJson()).toList(),
        'total': total,
        'page': page,
        'limit': limit,
        'totalPages': totalPages,
      };
}
