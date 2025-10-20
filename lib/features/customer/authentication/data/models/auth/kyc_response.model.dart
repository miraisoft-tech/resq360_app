class KycResponse {

  KycResponse({
    required this.success,
    required this.message,
  });

  factory KycResponse.fromJson(Map<String, dynamic> json) {
    return KycResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
    );
  }
  final bool success;
  final String message;
}
