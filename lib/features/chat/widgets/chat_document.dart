import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:resq360/__lib.dart';

class ChatDocumentBubble extends StatefulWidget {
  const ChatDocumentBubble({
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.time,
    required this.isMine,
    this.mimeType,
    super.key,
  });

  final String fileName;
  final String fileUrl;
  final num? fileSize;
  final String time;
  final bool isMine;
  final String? mimeType;

  @override
  State<ChatDocumentBubble> createState() => _ChatDocumentBubbleState();
}

class _ChatDocumentBubbleState extends State<ChatDocumentBubble> {
  bool _isDownloading = false;
  double _downloadProgress = 0;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Align(
      alignment: widget.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color:
              widget.isMine
                  ? appColors.primary.shade50
                  : appColors.neutral.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: appColors.neutral.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: appColors.primary.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    _getFileIcon(),
                    size: 28.sp,
                    color: appColors.primary.shade600,
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GenText(
                        widget.fileName,
                        weight: FontWeight.w500,
                        color: appColors.black,
                        maxLines: 2,
                      ),
                      4.verticalSpace,
                      if (widget.fileSize != null)
                        GenText(
                          _formatFileSize(widget.fileSize?.toDouble()),
                          size: 12,
                          color: appColors.neutral.shade500,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isDownloading) ...[
              12.verticalSpace,
              LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: appColors.neutral.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  appColors.primary.shade500,
                ),
              ),
              4.verticalSpace,
              GenText(
                '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                size: 12,
                color: appColors.neutral.shade500,
              ),
            ],
            12.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _isDownloading ? null : _downloadAndOpenFile,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: appColors.primary.shade500,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.download,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                        4.horizontalSpace,
                        const GenText(
                          'Open',
                          size: 12,
                          color: Colors.white,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ),
                GenText(
                  widget.time,
                  size: 11,
                  color: appColors.neutral.shade500,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    final extension = widget.fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(double? sizeInMB) {
    if (sizeInMB == null) return 'Unknown size';
    if (sizeInMB < 1) {
      return '${(sizeInMB * 1024).toStringAsFixed(0)} KB';
    }
    return '${sizeInMB.toStringAsFixed(2)} MB';
  }

  Future<void> _downloadAndOpenFile() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${widget.fileName}';
      final file = File(filePath);

      if (file.existsSync()) {
        await OpenFilex.open(filePath);
        if (mounted) setState(() => _isDownloading = false);
        return;
      }

      final request = http.Request('GET', Uri.parse(widget.fileUrl));
      final response = await request.send();

      if (response.statusCode == 200) {
        final contentLength = response.contentLength ?? 0;
        var downloadedBytes = 0;

        final bytes = <int>[];
        await for (final chunk in response.stream) {
          bytes.addAll(chunk);
          downloadedBytes += chunk.length;

          if (contentLength > 0) {
            setState(() {
              _downloadProgress = downloadedBytes / contentLength;
            });
          }
        }

        await file.writeAsBytes(bytes);
        await OpenFilex.open(filePath);
      } else {
        if (mounted) {
          await showErrorSnackbar(context, 'Failed to download file');
        }
      }
    } on Exception catch (e) {
      log('Download error: $e');
      if (mounted) {
        await showErrorSnackbar(context, 'Failed to download file: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }
}
