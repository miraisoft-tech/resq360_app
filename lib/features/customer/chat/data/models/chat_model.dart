import 'dart:convert';

import 'package:resq360/core/models/api_response.dart';

class Chat extends EmptyResponse {
  Chat({
    required this.name,
    required this.message,
    required this.time,
    required this.avatar,
    this.unread = 0,
    this.typing = false,
    this.status = 'all',
  });

  final String name;
  final String message;
  final String time;
  final String avatar;
  final int unread;
  final bool typing;
  final String status;
}

class CreateChatRequest {

  CreateChatRequest({
    required this.title,
    required this.type,
    required this.participants,
  });
  final String title;
  final String type; // e.g. PRIVATE or GROUP
  final List<ChatParticipant> participants;

  Map<String, dynamic> toJson() => {
        'title': title,
        'type': type,
        'participants': participants.map((p) => p.toJson()).toList(),
      };
}

class ChatParticipant {

  ChatParticipant({
    required this.participantType,
    required this.participantId,
  });
  final String participantType; // e.g. USER, ADMIN, BOT
  final int participantId;

  Map<String, dynamic> toJson() => {
        'participantType': participantType,
        'participantId': participantId,
      };
}



ChatResponse chatResponseFromJson(String str) => ChatResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String chatResponseToJson(ChatResponse data) => json.encode(data.toJson());

class ChatResponse {

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
        id: json['id'] as int  ,
        title: json['title'] as String,
        type: json['type'] as String,
        isActive: json['isActive'] as bool,
        lastMessage: json['lastMessage'] as  String,
        lastMessageAt: json['lastMessageAt'] == null ? null : DateTime.parse(json['lastMessageAt'] as String),
        createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
     participants: json['participants'] == null
    ? []
    : List<Participant>.from(
        (json['participants'] as List<dynamic>)
            .map((x) => Participant.fromJson(x as Map<String, dynamic>)),
      ),
messages: json['messages'] == null
    ? []
    : List<Message>.from(
        (json['messages'] as List<dynamic>)
            .map((x) => Message.fromJson(x as Map<String, dynamic>)),
      ),
    );
    final int? id;
    final String? title;
    final String? type;
    final bool? isActive;
    final String? lastMessage;
    final DateTime? lastMessageAt;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final List<Participant>? participants;
    final List<Message>? messages;

    Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'isActive': isActive,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'participants': participants == null ? <dynamic>[] : List<dynamic>.from(participants!.map((x) => x.toJson())),
        'messages': messages == null ? <dynamic>[] : List<dynamic>.from(messages!.map((x) => x.toJson())),
    };
}

class Message {

    Message({
        this.id,
        this.chatId,
        this.senderType,
        this.senderId,
        this.messageType,
        this.content,
        this.fileName,
        this.fileUrl,
        this.fileSize,
        this.mimeType,
        this.isEdited,
        this.editedAt,
        this.isDeleted,
        this.deletedAt,
        this.deliveredAt,
        this.createdAt,
        this.updatedAt,
        this.metadata,
    });

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] as int,
        chatId: json['chatId'] as int,
        senderType: json['senderType'] as String,
        senderId: json['senderId'] as int,
        messageType: json['messageType']  as String,
        content: json['content'] as String,
        fileName: json['fileName'] as String,
        fileUrl: json['fileUrl'] as String,
        fileSize: json['fileSize']  as int,
        mimeType: json['mimeType'] as String,
        isEdited: json['isEdited'] as bool,
        editedAt: json['editedAt'] == null ? null : DateTime.parse(json['editedAt'] as String),
        isDeleted: json['isDeleted'] as bool,
        deletedAt: json['deletedAt'] == null ? null : DateTime.parse(json['deletedAt'] as String),
        deliveredAt: json['deliveredAt'] == null ? null : DateTime.parse(json['deliveredAt'] as String),
        createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
        metadata: json['metadata'] == null ? null : Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
    final int? id;
    final int? chatId;
    final String? senderType;
    final int? senderId;
    final String? messageType;
    final String? content;
    final String? fileName;
    final String? fileUrl;
    final int? fileSize;
    final String? mimeType;
    final bool? isEdited;
    final DateTime? editedAt;
    final bool? isDeleted;
    final DateTime? deletedAt;
    final DateTime? deliveredAt;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final Metadata? metadata;

    Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'senderType': senderType,
        'senderId': senderId,
        'messageType': messageType,
        'content': content,
        'fileName': fileName,
        'fileUrl': fileUrl,
        'fileSize': fileSize,
        'mimeType': mimeType,
        'isEdited': isEdited,
        'editedAt': editedAt?.toIso8601String(),
        'isDeleted': isDeleted,
        'deletedAt': deletedAt?.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'metadata': metadata?.toJson(),
    };
}

class Metadata {
    Metadata();

    factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    );

    Map<String, dynamic> toJson() => {
    };
}

class Participant {

    Participant({
        this.id,
        this.chatId,
        this.participantType,
        this.participantId,
        this.role,
        this.isActive,
        this.joinedAt,
        this.leftAt,
        this.lastReadAt,
    });

    factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json['id'] as int,
        chatId: json['chatId'] as int,
        participantType: json['participantType'] as String,
        participantId: json['participantId'] as int,
        role: json['role'] as String,
        isActive: json['isActive']  as bool,
        joinedAt: json['joinedAt'] == null ? null : DateTime.parse(json['joinedAt'] as String),
        leftAt: json['leftAt'] == null ? null : DateTime.parse(json['leftAt'] as String),
        lastReadAt: json['lastReadAt'] == null ? null : DateTime.parse(json['lastReadAt'] as String),
    );
    final int? id;
    final int? chatId;
    final String? participantType;
    final int? participantId;
    final String? role;
    final bool? isActive;
    final DateTime? joinedAt;
    final DateTime? leftAt;
    final DateTime? lastReadAt;

    Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'participantType': participantType,
        'participantId': participantId,
        'role': role,
        'isActive': isActive,
        'joinedAt': joinedAt?.toIso8601String(),
        'leftAt': leftAt?.toIso8601String(),
        'lastReadAt': lastReadAt?.toIso8601String(),
    };
}
