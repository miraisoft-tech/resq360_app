import 'participant.dart';
import 'message_response.dart';

/// Represents a single chat conversation with participants and messages
class ChatResponse {
  final int? id;
  final String? title;
  final String? type;
  final bool? isActive;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Participant>? participants;
  final List<MessageResponse>? messages;

  ChatResponse({
    this.id,
    this.title,
    this.type,
    this.isActive,
    this.lastMessage,
    this.lastMessageAt,
    this.createdAt,
    this.updatedAt,
    this.participants,
    this.messages,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) => ChatResponse(
        id: json['id'] as int?,
        title: json['title'] as String?,
        type: json['type'] as String?,
        isActive: json['isActive'] as bool?,
        lastMessage: json['lastMessage'] as String?,
        lastMessageAt: json['lastMessageAt'] == null
            ? null
            : DateTime.parse(json['lastMessageAt'] as String),
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt']as String),
        participants: json['participants'] == null
            ? []
            : (json['participants'] as List)
                .map((x) => Participant.fromJson(x as Map<String, dynamic>))
                .toList(),
        messages: json['messages'] == null
            ? []
            : (json['messages'] as List)
                .map((x) => MessageResponse.fromJson(x as Map<String, dynamic>))
                .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'isActive': isActive,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'participants': participants?.map((x) => x.toJson()).toList() ?? [],
        'messages': messages?.map((x) => x.toJson()).toList() ?? [],
      };
}
