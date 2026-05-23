enum MessageStatus { sending, sent, delivered, read, failed }

class TicketMessage {
  TicketMessage({
    required this.id,
    required this.message,
    required this.isFromUser,
    required this.senderType,
    required this.senderName,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.localId,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] as int,
      message: json['message'] as String? ?? '',
      isFromUser: json['isFromUser'] as bool? ?? false,
      senderType: json['senderType'] as String? ?? 'USER',
      senderName: json['senderName'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory TicketMessage.local({
    required String message,
    required String senderName,
    String? localId,
  }) {
    return TicketMessage(
      id: -1,
      message: message,
      isFromUser: true,
      senderType: 'USER',
      senderName: senderName,
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
      localId: localId ?? DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  final int id;
  final String message;
  final bool isFromUser;
  final String senderType;
  final String senderName;
  final DateTime createdAt;
  final MessageStatus status;
  final String? localId;

  bool get isLocal => id == -1;

  TicketMessage copyWith({
    int? id,
    String? message,
    bool? isFromUser,
    String? senderType,
    String? senderName,
    DateTime? createdAt,
    MessageStatus? status,
    String? localId,
  }) {
    return TicketMessage(
      id: id ?? this.id,
      message: message ?? this.message,
      isFromUser: isFromUser ?? this.isFromUser,
      senderType: senderType ?? this.senderType,
      senderName: senderName ?? this.senderName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      localId: localId ?? this.localId,
    );
  }
}
