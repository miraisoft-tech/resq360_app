class NotificationSettingsModel {
  NotificationSettingsModel({
    this.id,
    this.userId,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.pushNotifications = true,
    this.newMessageAlerts = true,
    this.serviceRequestUpdates = true,
    this.systemAlerts = true,
    this.weeklyReports = false,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      smsNotifications: json['smsNotifications'] as bool? ?? false,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      newMessageAlerts: json['newMessageAlerts'] as bool? ?? true,
      serviceRequestUpdates: json['serviceRequestUpdates'] as bool? ?? true,
      systemAlerts: json['systemAlerts'] as bool? ?? true,
      weeklyReports: json['weeklyReports'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final int? id;
  final int? userId;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final bool newMessageAlerts;
  final bool serviceRequestUpdates;
  final bool systemAlerts;
  final bool weeklyReports;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'emailNotifications': emailNotifications,
        'smsNotifications': smsNotifications,
        'pushNotifications': pushNotifications,
        'newMessageAlerts': newMessageAlerts,
        'serviceRequestUpdates': serviceRequestUpdates,
        'systemAlerts': systemAlerts,
        'weeklyReports': weeklyReports,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  NotificationSettingsModel copyWith({
    int? id,
    int? userId,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
    bool? newMessageAlerts,
    bool? serviceRequestUpdates,
    bool? systemAlerts,
    bool? weeklyReports,
    String? createdAt,
    String? updatedAt,
  }) {
    return NotificationSettingsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      newMessageAlerts: newMessageAlerts ?? this.newMessageAlerts,
      serviceRequestUpdates: serviceRequestUpdates ?? this.serviceRequestUpdates,
      systemAlerts: systemAlerts ?? this.systemAlerts,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NotificationSettingsResponse {
  NotificationSettingsResponse({
    this.success = false,
    this.message,
    this.data,
  });

  factory NotificationSettingsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null
          ? NotificationSettingsModel.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final bool success;
  final String? message;
  final NotificationSettingsModel? data;

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
      };
}
