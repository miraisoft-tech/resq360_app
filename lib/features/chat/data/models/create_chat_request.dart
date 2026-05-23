import 'chat_participant.dart';

class CreateChatRequest {

  CreateChatRequest({
    required this.title,
    required this.type,
    required this.participants,
  });
  final String title;
  final String type;
  final List<ChatParticipant> participants;

  Map<String, dynamic> toJson() => {
        'title': title,
        'type': type,
        'participants': participants.map((p) => p.toJson()).toList(),
      };
}
