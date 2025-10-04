import 'package:resq360/__lib.dart';
import 'package:resq360/features/dashboard/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({required this.notification, super.key});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: pad(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: appColors.textColor.shade100),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          notification.icon,
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GenText(
                  notification.title,
                  weight: FontWeight.w500,
                  color: appColors.black,
                ),
                4.verticalSpace,
                GenText(
                  notification.message,
                  size: 12,
                  weight: FontWeight.w400,
                  color: appColors.textColor.shade400,
                ),
                6.verticalSpace,
                GenText(
                  notification.time,
                  size: 10,
                  weight: FontWeight.w400,
                  color: appColors.textColor.shade300,
                ),
              ],
            ),
          ),
          if (notification.isUnread)
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: appColors.primary.shade500,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
