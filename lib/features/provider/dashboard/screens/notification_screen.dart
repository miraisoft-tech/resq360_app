import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/models/notification_model.dart';
import 'package:resq360/features/customer/dashboard/widgets/notification_tile.dart';
import 'package:resq360/features/widgets/empty_screen_widget.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final notifications = [
      NotificationModel(
        title: 'Booking Confirmed',
        message:
            'Your house cleaning service is confirmed for tomorrow at 2:00 pm',
        time: '30 minutes ago',
        isUnread: true,
        group: 'Today',
        icon: AppAssets.ASSETS_ICONS_NOTIFICATION_B_SVG.svg,
      ),
      NotificationModel(
        title: 'Service Reminder',
        message: 'Your electrician will is on the way.',
        time: '2 hours ago',
        isUnread: true,
        group: 'Today',
        icon: AppAssets.ASSETS_ICONS_NOTIFICATION_R_SVG.svg,
      ),
      NotificationModel(
        title: 'Special Offer',
        message: 'Get 20% off your cleaning service today!!',
        time: '1 day ago',
        group: 'Today',
        icon: AppAssets.ASSETS_ICONS_NOTIFICATION_S_SVG.svg,
      ),
      NotificationModel(
        title: 'Booking Confirmed',
        message:
            'Your house cleaning service is confirmed for tomorrow at 2:00 pm',
        time: '26 hours ago',
        group: 'Yesterday',
        icon: AppAssets.ASSETS_ICONS_NOTIFICATION_B_SVG.svg,
      ),
    ];

    final grouped = _groupNotifications(notifications);

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        elevation: 0,
        title: UrbText(
          'Notifications',
          color: appColors.black,
          size: 22,
          height: 28.5,
          weight: FontWeight.w700,
        ),
        centerTitle: true,
        backgroundColor: appColors.whiteColor,
        foregroundColor: appColors.black,
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: pad(horizontal: 20, vertical: 10),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GenText(
                  '2 new notifications',
                  color: appColors.black,
                  weight: FontWeight.w600,
                ),
                GenText(
                  'Mark all as read',
                  size: 13,
                  color: appColors.primary.shade500,
                  weight: FontWeight.w500,
                ),
              ],
            ),
            20.verticalSpace,
            if (grouped.isEmpty)
              const Center(
                child: EmptyScreenWidget(
                  imagePath: AppAssets.ASSETS_IMAGES_NOTIFICATIONS_EMPTY_PNG,
                  message: 'No Notifications Yet',
                  subMessage:
                      'You’ll see updates about your bookings and payments here. ',
                ),
              )
            else
              ...grouped.entries.map(
                (group) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (group.key != null) ...[
                      GenText(
                        group.key!,
                        color: appColors.black,
                        weight: FontWeight.w400,
                      ),
                      10.verticalSpace,
                    ],
                    ...group.value.map(
                      (n) => NotificationTile(notification: n),
                    ),
                    20.verticalSpace,
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Map<String?, List<NotificationModel>> _groupNotifications(
    List<NotificationModel> notifications,
  ) {
    final grouped = <String?, List<NotificationModel>>{};
    for (final n in notifications) {
      grouped.putIfAbsent(n.group, () => []).add(n);
    }
    return grouped;
  }
}
