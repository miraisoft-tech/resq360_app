class Participant {

  Participant({
    this.id,
    this.chatId,
    this.participantType,
    this.participantId,
    this.role,
    this.isActive,
    this.joinedAt,
    this.leftAt,
    this.lastReadAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json['id'] as int?,
        chatId: json['chatId'] as int?,
        participantType: json['participantType'] as String?,
        participantId: json['participantId'] as int?,
        role: json['role'] as String?,
        isActive: json['isActive'] as bool?,
        joinedAt:
            json['joinedAt'] == null ? null : DateTime.parse(json['joinedAt']as String),
        leftAt: json['leftAt'] == null ? null : DateTime.parse(json['leftAt']as String),
        lastReadAt: json['lastReadAt'] == null
            ? null
            : DateTime.parse(json['lastReadAt']as String),
      );
  final int? id;
  final int? chatId;
  final String? participantType;
  final int? participantId;
  final String? role;
  final bool? isActive;
  final DateTime? joinedAt;
  final DateTime? leftAt;
  final DateTime? lastReadAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'participantType': participantType,
        'participantId': participantId,
        'role': role,
        'isActive': isActive,
        'joinedAt': joinedAt?.toIso8601String(),
        'leftAt': leftAt?.toIso8601String(),
        'lastReadAt': lastReadAt?.toIso8601String(),
      };
}
