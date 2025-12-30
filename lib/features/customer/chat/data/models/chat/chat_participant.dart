class ChatParticipant {

  ChatParticipant({
    required this.participantType,
    required this.participantId,
  });
  final String participantType;
  final int participantId;

  Map<String, dynamic> toJson() => {
        'participantType': participantType,
        'participantId': participantId,
      };
}
