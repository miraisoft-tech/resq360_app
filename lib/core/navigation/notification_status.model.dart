class NotificationStatus {

  NotificationStatus({
    required this.value,
    required this.label,
  });

  factory NotificationStatus.fromJson(Map<String, dynamic> json) {
    return NotificationStatus(
      value: json['value'] as String,
      label: json['label'] as String,
    );
  }
  final String value;
  final String label;
}
