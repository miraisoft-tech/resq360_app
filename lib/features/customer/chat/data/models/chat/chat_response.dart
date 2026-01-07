import 'message_response.dart';
import 'participant.dart';

class ChatResponse {
  ChatResponse({
    this.id,
    this.title,
    this.type,
    this.isActive,
    this.lastMessage,
    this.lastMessageAt,
    this.serviceRequestId,
    this.createdAt,
    this.updatedAt,
    this.participants,
    this.messages,
    this.serviceRequestStatus,
    this.serviceName,
    this.provider,
    this.user,
    this.serviceCategoryId,
    this.paymentStatus,
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
        serviceRequestId: json['serviceRequestId'] as int?,
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt'] as String),
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
        serviceRequestStatus: json['serviceRequestStatus'] as String?,
        serviceName: json['serviceName'] as String?,
        provider: json['provider'] == null
            ? null
            : ProviderInfo.fromJson(json['provider'] as Map<String, dynamic>),
        user: json['user'] == null
            ? null
            : UserInfo.fromJson(json['user'] as Map<String, dynamic>),
        serviceCategoryId: json['serviceCategoryId'] as int?,
        paymentStatus: json['paymentStatus'] as String?,
      );

  final int? id;
  final String? title;
  final String? type;
  final bool? isActive;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int? serviceRequestId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Participant>? participants;
  final List<MessageResponse>? messages;
  final String? serviceRequestStatus;
  final String? serviceName;
  final ProviderInfo? provider;
  final UserInfo? user;
  final int? serviceCategoryId;
  final String? paymentStatus;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'isActive': isActive,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt?.toIso8601String(),
        'serviceRequestId': serviceRequestId,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'participants': participants?.map((x) => x.toJson()).toList() ?? [],
        'messages': messages?.map((x) => x.toJson()).toList() ?? [],
        'serviceRequestStatus': serviceRequestStatus,
        'serviceName': serviceName,
        'provider': provider?.toJson(),
        'user': user?.toJson(),
        'serviceCategoryId': serviceCategoryId,
        'paymentStatus': paymentStatus,
      };
}

class ProviderInfo {
  ProviderInfo({
    this.id,
    this.fullName,
    this.profileImage,
  });

  factory ProviderInfo.fromJson(Map<String, dynamic> json) => ProviderInfo(
        id: json['id'] as int?,
        fullName: json['fullName'] as String?,
        profileImage: json['profileImage'] as String?,
      );

  final int? id;
  final String? fullName;
  final String? profileImage;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'profileImage': profileImage,
      };
}

class UserInfo {
  UserInfo({
    this.fullName,
    this.profileImage,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        fullName: json['fullName'] as String?,
        profileImage: json['profileImage'] as String?,
      );

  final String? fullName;
  final String? profileImage;

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'profileImage': profileImage,
      };
}
