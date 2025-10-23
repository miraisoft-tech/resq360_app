/// Model representing a chat participant (user, admin, etc.)
class ChatParticipant {
  final String participantType; // e.g. USER, ADMIN, BOT
  final int participantId;

  ChatParticipant({
    required this.participantType,
    required this.participantId,
  });

  Map<String, dynamic> toJson() => {
        'participantType': participantType,
        'participantId': participantId,
      };
}
