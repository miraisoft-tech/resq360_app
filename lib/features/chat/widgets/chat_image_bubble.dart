import 'package:resq360/__lib.dart';
import 'package:resq360/features/chat/widgets/chat_image_loader.dart';
import 'package:resq360/features/chat/widgets/full_image_viewer.dart';

class ChatImageBubble extends StatelessWidget {
  const ChatImageBubble({
    required this.imageUrl,
    required this.time,
    required this.isMine,
    this.caption,
    super.key,
  });

  final String imageUrl;
  final String time;
  final bool isMine;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _showFullImage(context),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: appColors.neutral.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Stack(
                    children: [
                      ChatImageLoader(
                        source: imageUrl,
                        width: double.infinity,
                        height: 200.h,
                      ),

                      Positioned(
                        bottom: 8.h,
                        right: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: GenText(
                            time,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            
            if (caption != null && caption!.isNotEmpty) ...[
              4.verticalSpace,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isMine
                      ? appColors.primary.shade50
                      : appColors.neutral.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: GenText(
                  caption!,
                  color: appColors.black,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showFullImage(BuildContext context) async {
    await pushScreen(
      context,
      FullImageViewer(imageUrl: imageUrl),
    );
  }
}
