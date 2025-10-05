import 'package:resq360/__lib.dart';
import 'package:resq360/core/theme/static_colors.dart';

enum MessageType { sent, received }

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.message,
    required this.time,
    required this.type,
    super.key,
  });

  final String message;
  final String time;
  final MessageType type;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final isReceived = type == MessageType.received;

    return Align(
      alignment: isReceived ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin:
            isReceived
                ? EdgeInsets.only(right: 30.w)
                : EdgeInsets.only(left: 30.w),
        padding: pad(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isReceived ? AppColors.grey : appColors.primary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GenText(
              message,
              color:
                  isReceived
                      ? appColors.textColor.shade600
                      : appColors.whiteColor,
              height: 22,
            ),
            6.verticalSpace,
            GenText(
              time,
              size: 12,
              color:
                  isReceived
                      ? appColors.textColor.shade400
                      : appColors.whiteColor.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}
