
import 'package:resq360/features/settings/data/models/ticket_message.model.dart';


class Ticket {
  Ticket({
    required this.id,
    required this.ticketId,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this.contactEmail,
    this.contactPhone,
    this.closedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    final messagesJson = json['messages'] as List<dynamic>? ?? [];
    return Ticket(
      id: json['id'] as int,
      ticketId: json['ticketId'] as String,
      subject: json['subject']as String? ?? '',
      description: json['description']as String? ?? '',
      status: json['status']as String? ?? 'OPEN',
      priority: json['priority']as String? ?? 'LOW',
      category: json['category']as String? ?? '',
      contactEmail: json['contactEmail']as String,
      contactPhone: json['contactPhone']as String,
      createdAt: DateTime.parse(json['createdAt']as String),
      updatedAt: DateTime.parse(json['updatedAt']as String),
      closedAt:
          json['closedAt'] != null ? DateTime.parse(json['closedAt']as String) : null,
      messages:  messagesJson
          .map((e) => TicketMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  final int id;
  final String ticketId; 
  final String subject;
  final String description;
  final String status;  
  final String priority; 
  final String category;

  final String? contactEmail;
  final String? contactPhone;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;

  final List<TicketMessage> messages;

  bool get isClosed =>
      status == 'CLOSED' || status == 'RESOLVED';
}
