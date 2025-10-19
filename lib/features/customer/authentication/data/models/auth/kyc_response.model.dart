class KycResponse {

  KycResponse({
    required this.status,
    required this.message,
  });

  factory KycResponse.fromJson(Map<String, dynamic> json) {
    return KycResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
  final String status;
  final String message;
}
