import 'package:resq360/__lib.dart';
import 'package:resq360/core/theme/app_color_theme.dart';
import 'package:resq360/features/chat/widgets/chat_image_loader.dart';
import 'package:resq360/features/chat/widgets/full_gallery_viewer.dart';
import 'package:resq360/features/settings/data/models/ticket_message.model.dart';

class ChatMultiImageBubble extends StatelessWidget {
  const ChatMultiImageBubble({
    required this.imageUrls,
    required this.time,
    required this.isMine,
    this.status = MessageStatus.sent,
    super.key,
  });

  final List<String> imageUrls;
  final String time;
  final bool isMine;
  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isMine ? appColors.primary : appColors.neutral.shade100,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _openGallery(context),
              child: Row(
                children: [
                  _singleImage(imageUrls[0], radius: 12.r),
                  6.horizontalSpace,
                  if (imageUrls.length > 1)
                    Stack(
                      children: [
                        _singleImage(imageUrls[1], radius: 12.r, darken: true),
                        Positioned.fill(
                          child: Center(
                            child: GenText(
                              '+${imageUrls.length - 1}',
                              size: 22,
                              color: Colors.white,
                              weight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            6.verticalSpace,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GenText(
                  time,
                  size: 12,
                  color: isMine ? appColors.whiteColor : null,
                ),
                if (isMine) ...[
                  SizedBox(width: 4.w),
                  _buildStatusIcon(appColors),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _singleImage(
    String url, {
    required double radius,
    bool darken = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          ChatImageLoader(source: url, width: 120, height: 120),
          if (darken)
            Container(
              width: 120,
              height: 120,
              color: Colors.black.withValues(alpha: 0.45),
            ),
        ],
      ),
    );
  }

  Future<void> _openGallery(BuildContext context) async {
    await pushScreen(context, FullGalleryViewer(images: imageUrls));
  }

  Widget _buildStatusIcon(AppColorPalette appColors) {
    switch (status) {
      case MessageStatus.sending:
        return Icon(
          Icons.access_time,
          size: 12,
          color: appColors.whiteColor.withValues(alpha: 0.7),
        );
      case MessageStatus.sent:
        return Icon(Icons.check, size: 12, color: appColors.whiteColor);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 12, color: appColors.whiteColor);
      case MessageStatus.read:
        return const Icon(
          Icons.done_all,
          size: 12,
          color: Colors.lightBlueAccent,
        );
      case MessageStatus.failed:
        return const Icon(
          Icons.error_outline,
          size: 12,
          color: Colors.redAccent,
        );
    }
  }
}
