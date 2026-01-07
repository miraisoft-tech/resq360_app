import 'package:resq360/__lib.dart';
import 'package:resq360/core/theme/app_color_theme.dart';
import 'package:resq360/core/theme/static_colors.dart';
import 'package:resq360/features/settings/data/models/ticket_message.model.dart';

enum MessageType { sent, received }

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.message,
    required this.time,
    required this.type,
    this.status = MessageStatus.sent,
    this.onRetry,
    this.onDelete,
    super.key,
  });

  final String message;
  final String time;
  final MessageType type;
  final MessageStatus status;
  final VoidCallback? onRetry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final isReceived = type == MessageType.received;

    return Align(
      alignment: isReceived ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        crossAxisAlignment:
            isReceived ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GenText(
                      time,
                      size: 12,
                      color:
                          isReceived
                              ? appColors.textColor.shade400
                              : appColors.whiteColor.withValues(alpha: 0.8),
                    ),
                    if (!isReceived) ...[
                      6.horizontalSpace,
                      _buildStatusIcon(appColors),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Show retry/delete options for failed messages
          if (status == MessageStatus.failed && !isReceived) ...[
            4.verticalSpace,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: onRetry,
                  icon: Icon(
                    Icons.refresh,
                    size: 16,
                    color: appColors.error,
                  ),
                  label: GenText(
                    'Retry',
                    size: 12,
                    color: appColors.error,
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                8.horizontalSpace,
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: appColors.textColor.shade400,
                  ),
                  label: GenText(
                    'Delete',
                    size: 12,
                    color: appColors.textColor.shade400,
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(AppColorPalette appColors) {
    switch (status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFFE9E9E9),
            ),
          ),
        );
      case MessageStatus.sent:
        return const Icon(
          Icons.check,
          size: 12,
          color: Color(0xFFE9E9E9),
        );
      case MessageStatus.failed:
        return Icon(
          Icons.error_outline,
          size: 12,
          color: appColors.error
        );
    }
  }
}
