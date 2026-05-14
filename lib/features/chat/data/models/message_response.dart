import 'package:resq360/features/settings/data/models/ticket_message.model.dart';

import 'metadata.dart';

/// A single message in a chat
class MessageResponse {
  MessageResponse({
    this.id,
    this.chatId,
    this.serviceRequestId,
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
    this.isDelivered,
    this.deliveredAt,
    this.isReported,
    this.reportReason,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.readReceipts,
    this.status = MessageStatus.sent,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    final isDelivered = json['isDelivered'] as bool? ?? false;
    final readReceipts = json['readReceipts'] as List<dynamic>?;
    final hasBeenRead = readReceipts != null && readReceipts.isNotEmpty;

    MessageStatus parsedStatus;
    final rawStatus = json['status'] as String?;
    switch (rawStatus?.toUpperCase()) {
      case 'READ':
        parsedStatus = MessageStatus.read;
      case 'DELIVERED':
        parsedStatus = MessageStatus.delivered;
      default:
        // Derive from flags if server didn't send explicit status
        if (hasBeenRead) {
          parsedStatus = MessageStatus.read;
        } else if (isDelivered) {
          parsedStatus = MessageStatus.delivered;
        } else {
          parsedStatus = MessageStatus.sent;
        }
    }

    return MessageResponse(
      id: json['id'] as int?,
      chatId: json['chatId'] as int?,
      serviceRequestId: json['serviceRequestId'] as int?,
      senderType: json['senderType'] as String?,
      senderId: json['senderId'] as int?,
      messageType: json['messageType'] as String?,
      content: json['content'] as String?,
      fileName: json['fileName'] as String?,
      fileUrl: json['fileUrl'] as String?,
      fileSize: json['fileSize'] as num?,
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
      isDelivered: isDelivered,
      deliveredAt:
          json['deliveredAt'] == null
              ? null
              : DateTime.parse(json['deliveredAt'] as String),
      isReported: json['isReported'] as bool?,
      reportReason: json['reportReason'] as String?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
      metadata:
          json['metadata'] == null
              ? null
              : Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
      readReceipts: readReceipts,
      status: parsedStatus,
    );
  }

  final int? id;
  final int? chatId;
  final int? serviceRequestId;
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
  final bool? isDelivered;
  final DateTime? deliveredAt;
  final bool? isReported;
  final String? reportReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Metadata? metadata;
  final List<dynamic>? readReceipts;
  final MessageStatus status;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'serviceRequestId': serviceRequestId,
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
      'isDelivered': isDelivered,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'isReported': isReported,
      'reportReason': reportReason,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata?.toJson(),
      'readReceipts': readReceipts,
    };
  }

  MessageResponse copyWith({
    bool? isDelivered,
    DateTime? deliveredAt,
    List<dynamic>? readReceipts,
    MessageStatus? status,
  }) {
    return MessageResponse(
      id: id,
      chatId: chatId,
      serviceRequestId: serviceRequestId,
      senderType: senderType,
      senderId: senderId,
      messageType: messageType,
      content: content,
      fileName: fileName,
      fileUrl: fileUrl,
      fileSize: fileSize,
      mimeType: mimeType,
      isEdited: isEdited,
      editedAt: editedAt,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      isDelivered: isDelivered ?? this.isDelivered,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      isReported: isReported,
      reportReason: reportReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
      metadata: metadata,
      readReceipts: readReceipts ?? this.readReceipts,
      status: status ?? this.status,
    );
  }
}
