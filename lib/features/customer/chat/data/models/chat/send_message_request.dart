/// Request model for sending a new chat message
class SendMessageRequest {
  final int chatId;
  final String messageType; // e.g. TEXT, IMAGE, FILE
  final String content;
  final String? fileName;
  final String? fileUrl;
  final int? fileSize;
  final String? mimeType;
  final Map<String, dynamic>? metadata;

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
