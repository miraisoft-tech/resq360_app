import 'dart:convert';

class BookRequest {

    BookRequest({
        this.id,
        this.title,
        this.type,
        this.isActive,
        this.lastMessage,
        this.lastMessageAt,
        this.serviceRequestId,
        this.disputeServiceRequestId,
        this.isDeleted,
        this.isBlocked,
        this.blockReason,
        this.blockedByParticipantId,
        this.createdAt,
        this.updatedAt,
    });

    factory BookRequest.fromRawJson(String str) => BookRequest.fromJson(json.decode(str) as Map<String, dynamic>);

    factory BookRequest.fromJson(Map<String, dynamic> json) => BookRequest(
        id: json['id'] as int?,
        title: json['title'] as String?,
        type: json['type'] as String?,
        isActive: json['isActive'] as bool?,
        lastMessage: json['lastMessage'] as String?,
        lastMessageAt: json['lastMessageAt'] as String?,
        serviceRequestId: json['serviceRequestId'] as int?,
        disputeServiceRequestId: json['disputeServiceRequestId'] as int?,
        isDeleted: json['isDeleted'] as bool?,
        isBlocked: json['isBlocked'] as bool?,
        blockReason: json['blockReason'] as String,
        blockedByParticipantId: json['blockedByParticipantId'],
        createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
    );
    final int? id;
    final String? title;
    final String? type;
    final bool? isActive;
    final String? lastMessage;
    final String? lastMessageAt;
    final int? serviceRequestId;
    final int? disputeServiceRequestId;
    final bool? isDeleted;
    final bool? isBlocked;
    final String? blockReason;
    final dynamic blockedByParticipantId;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    String toRawJson() => json.encode(toJson());

    Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'isActive': isActive,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt,
        'serviceRequestId': serviceRequestId,
        'disputeServiceRequestId': disputeServiceRequestId,
        'isDeleted': isDeleted,
        'isBlocked': isBlocked,
        'blockReason': blockReason,
        'blockedByParticipantId': blockedByParticipantId,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
    };
}
