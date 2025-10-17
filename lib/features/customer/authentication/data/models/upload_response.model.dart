class UploadResponse {

  UploadResponse({
    required this.id,
    required this.url,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      id: json['assetId']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
  final String id;
  final String url;
}
