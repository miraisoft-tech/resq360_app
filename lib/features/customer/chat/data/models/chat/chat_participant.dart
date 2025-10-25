/// Model representing a chat participant (user, admin, etc.)
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
