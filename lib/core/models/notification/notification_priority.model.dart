class NotificationPriority {

  NotificationPriority({
    required this.value,
    required this.label,
  });

  factory NotificationPriority.fromJson(Map<String, dynamic> json) {
    return NotificationPriority(
      value: json['value'] as String,
      label: json['label'] as String,
    );
  }
  final String value;
  final String label;
}
