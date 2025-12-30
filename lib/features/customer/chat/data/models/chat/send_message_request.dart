
class SendMessageRequest {

  SendMessageRequest({
    required this.chatId,
    required this.messageType,
    required this.content,
    this.fileName,
    this.fileUrl,
    this.fileSize,
    this.mimeType,
    this.metadata,
  });
  final int chatId;
  final String messageType;
  final String content;
  final String? fileName;
  final String? fileUrl;
  final int? fileSize;
  final String? mimeType;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'messageType': messageType,
        'content': content,
        if (fileName != null) 'fileName': fileName,
        if (fileUrl != null) 'fileUrl': fileUrl,
        if (fileSize != null) 'fileSize': fileSize,
        if (mimeType != null) 'mimeType': mimeType,
        if (metadata != null) 'metadata': metadata,
      };
}
