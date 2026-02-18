import 'metadata.dart';

///a single message in a chat
class MessageResponse {
  MessageResponse({
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
    this.isReported,
    this.metadata,
    this.readReceipts,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      MessageResponse(
        id: json['id'] as int?,
        chatId: json['chatId'] as int?,
        senderType: json['senderType'] as String?,
        senderId: json['senderId'] as int?,
        messageType: json['messageType'] as String?,
        content: json['content'] as String?,
        fileName: json['fileName'] as String?,
        fileUrl: json['fileUrl'] as String?,
        fileSize: json['fileSize'] as int?,
        mimeType: json['mimeType'] as String?,
        isEdited: json['isEdited'] as bool?,
        editedAt:
            json['editedAt'] == null
                ? null
                : DateTime.parse(json['editedAt'] as String),
        isDeleted: json['isDeleted'] as bool?,
        deletedAt:
            json['deletedAt'] == null
                ? null
                : DateTime.parse(json['deletedAt'] as String),
        deliveredAt:
            json['deliveredAt'] == null
                ? null
                : DateTime.parse(json['deliveredAt'] as String),
        createdAt:
            json['createdAt'] == null
                ? null
                : DateTime.parse(json['createdAt'] as String),
        updatedAt:
            json['updatedAt'] == null
                ? null
                : DateTime.parse(json['updatedAt'] as String),
        isReported: json['isReported'] as bool?,
        metadata:
            json['metadata'] == null
                ? null
                : Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
        readReceipts: json['readReceipts'] as List<dynamic>?,
      );
  final int? id;
  final int? chatId;
  final String? senderType;
  final int? senderId;
  final String? messageType;
  final String? content;
  final String? fileName;
  final String? fileUrl;
  final num? fileSize;
  final String? mimeType;
  final bool? isEdited;
  final DateTime? editedAt;
  final bool? isDeleted;
  final DateTime? deletedAt;
  final DateTime? deliveredAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isReported;
  final Metadata? metadata;
  final List<dynamic>? readReceipts;

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
    'isFlagged': isReported,
    'metadata': metadata?.toJson(),
    'readReceipts': readReceipts,
  };
}
