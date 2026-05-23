class NotificationCategory {

  NotificationCategory({
    required this.value,
    required this.label,
  });

  factory NotificationCategory.fromJson(Map<String, dynamic> json) {
    return NotificationCategory(
      value: json['value'] as String ,
      label: json['label'] as String ,
    );
  }
  final String value;
  final String label;
}
