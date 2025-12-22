import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/notification/notification_response.model.dart'
    as notif;
import 'package:resq360/features/customer/dashboard/data/bloc/notification_bloc/notification_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/models/notification_model.dart';
import 'package:resq360/features/customer/dashboard/widgets/notification_tile.dart';
import 'package:resq360/features/widgets/empty_screen_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(
      const FetchRecentNotifications(
        toDate: '',
        fromDate: '',
        tags: 'urgent,payment,service',
        priority: '',
        status: '',
        category: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    // final notifications = [
    //   NotificationModel(
    //     title: 'Booking Confirmed',
    //     message:
    //         'Your house cleaning service is confirmed for tomorrow at 2:00 pm',
    //     time: '30 minutes ago',
    //     isUnread: true,
    //     group: 'Today',
    //     icon: AppAssets.ASSETS_ICONS_NOTIFICATION_B_SVG.svg,
    //   ),
    //   NotificationModel(
    //     title: 'Service Reminder',
    //     message: 'Your electrician will is on the way.',
    //     time: '2 hours ago',
    //     isUnread: true,
    //     group: 'Today',
    //     icon: AppAssets.ASSETS_ICONS_NOTIFICATION_R_SVG.svg,
    //   ),
    //   NotificationModel(
    //     title: 'Special Offer',
    //     message: 'Get 20% off your cleaning service today!!',
    //     time: '1 day ago',
    //     group: 'Today',
    //     icon: AppAssets.ASSETS_ICONS_NOTIFICATION_S_SVG.svg,
    //   ),
    //   NotificationModel(
    //     title: 'Booking Confirmed',
    //     message:
    //         'Your house cleaning service is confirmed for tomorrow at 2:00 pm',
    //     time: '26 hours ago',
    //     group: 'Yesterday',
    //     icon: AppAssets.ASSETS_ICONS_NOTIFICATION_B_SVG.svg,
    //   ),
    // ];

    // final grouped = _groupNotifications(notifications);

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
      body: BlocConsumer<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationLoaded) {
            final notifications = state.response.notifications;

            if (notifications.isEmpty) {
              return const EmptyScreenWidget(
                imagePath: AppAssets.ASSETS_IMAGES_NOTIFICATIONS_EMPTY_PNG,
                message: 'No Notifications Yet',
                subMessage:
                    "You'll see updates about your bookings and payments here.",
              );
            }

            final uiList = notifications.map(mapToUi).toList();
            final grouped = _groupNotifications(uiList);
            return Padding(
              padding: pad(horizontal: 20, vertical: 10),
              child: ListView(
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     GenText(
                  //       '2 new notifications',
                  //       color: appColors.black,
                  //       weight: FontWeight.w600,
                  //     ),
                  //     GenText(
                  //       'Mark all as read',
                  //       size: 13,
                  //       color: appColors.primary.shade500,
                  //       weight: FontWeight.w500,
                  //     ),
                  //   ],
                  // ),
                  _HeaderRow(),
                  20.verticalSpace,
                  if (grouped.isEmpty)
                    const Center(
                      child: EmptyScreenWidget(
                        imagePath:
                            AppAssets.ASSETS_IMAGES_NOTIFICATIONS_EMPTY_PNG,
                        message: 'No Notifications Yet',
                        subMessage:
                            "You'll see updates about your bookings and payments here. ",
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
            );
          }
          if (state is NotificationError) {
            return ErrorMessageAndButton(
              error: state.message,
              onPressed: () {
                context.read<NotificationBloc>().add(
                  const FetchRecentNotifications(
                    tags: 'urgent,payment,service',
                    // priority: '',
                    // status: '',
                    // category: '',
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
        listener: (BuildContext context, NotificationState state) {
          if (state is NotificationActionSuccess) {
            unawaited(showSuccessSnackbar(context, state.message));
            context.read<NotificationBloc>().add(
              const FetchRecentNotifications(
                tags: 'urgent,payment,service',
                // priority: '',
                // status: '',
                // category: '',
              ),
            );
          }
          if (state is NotificationError) {
            unawaited(showErrorSnackbar(context, state.message));
            const FetchRecentNotifications(
              tags: 'urgent,payment,service',
              // priority: '',
              // status: '',
              // category: '',
            );
          }
        },
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

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NotificationBloc>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('New notifications'),
        GestureDetector(
          onTap: () {
            bloc.add(MarkAllAsRead());
          },
          child: Text(
            'Mark all as read',
            style: TextStyle(
              color: context.appColors.primary.shade500,
            ),
          ),
        ),
      ],
    );
  }
}

NotificationModel mapToUi(notif.Notification n) {
  return NotificationModel(
    title: n.user?.fullName ?? 'N/A',
    message: n.details ?? '',
    time: timeAgo(n.createdAt),
    isUnread: n.status == 'UNREAD',
    group: groupByDate(n.createdAt),
    icon: _iconForCategory(n.category),
  );
}

String timeAgo(DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
  if (diff.inHours < 24) return '${diff.inHours} hrs ago';
  return '${diff.inDays} days ago';
}

String groupByDate(DateTime? date) {
  if (date == null) return '';
  final now = DateTime.now();
  if (date.day == now.day) return 'Today';
  if (date.day == now.subtract(const Duration(days: 1)).day) {
    return 'Yesterday';
  }
  return '';
}

SvgPicture _iconForCategory(String? category) {
  switch (category) {
    case 'BOOKING':
      return AppAssets.ASSETS_ICONS_NOTIFICATION_B_SVG.svg;
    case 'REMINDER':
      return AppAssets.ASSETS_ICONS_NOTIFICATION_R_SVG.svg;
    default:
      return AppAssets.ASSETS_ICONS_NOTIFICATION_S_SVG.svg;
  }
}
