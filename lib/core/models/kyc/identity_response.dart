class IdentityResponse {
  IdentityResponse({required this.message, required this.success});

  factory IdentityResponse.fromJson(Map<String, dynamic> json) {
    return IdentityResponse(
      message: json['message']?.toString() ?? '',
      success: json['success'] == false,
    );
  }

  final String message;
  final bool success;
}
