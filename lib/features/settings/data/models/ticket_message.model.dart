class TicketMessage {

  TicketMessage({
    required this.id,
    required this.message,
    required this.isFromUser,
    required this.senderType,
    required this.senderName,
    required this.ticketId,
    required this.createdAt,
    required this.success,
    this.senderId,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] as int,
      message: json['message']as String?  ?? '',
      isFromUser: json['isFromUser'] as bool? ?? false,
      senderId: json['senderId'] as int,
      senderType: json['senderType'] as String?  ?? 'USER',
      senderName: json['senderName']as String?  ?? '',
      ticketId: json['ticketId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      success: json['success'] as bool,

    );
  }
  final int id;
  final String message;
  final bool isFromUser;
  final int? senderId;
  final String senderType; 
  final String senderName;
  final int ticketId;
  final DateTime createdAt;
  final bool success;
}
