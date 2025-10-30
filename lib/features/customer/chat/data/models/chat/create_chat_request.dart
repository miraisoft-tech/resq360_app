import 'chat_participant.dart';

/// Request model for creating a new chat
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
