import 'dart:async';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/notification_bloc/notification_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({required this.notification, super.key});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NotificationBloc>();
    final appColors = context.appColors;

    return Slidable(
      key: ValueKey(notification.id),

      enabled: context.watch<NotificationBloc>().state is! NotificationLoading,
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              bloc.add(ArchiveNotification(notification.id));
              unawaited(showSuccessSnackbar(context, 'Notification archived'));
            },
            backgroundColor: appColors.warning.shade500,
            foregroundColor: Colors.white,
            icon: Icons.archive_outlined,
            label: 'Archive',
          ),
        ],
      ),

      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) async {
              final response = await _confirmDelete(
                context,
                bloc,
                notification.id,
              );

              if (response) {
                unawaited(showSuccessSnackbar(context, 'Notification deleted'));
              }
            },
            backgroundColor: appColors.error.shade500,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
          ),
        ],
      ),

      child: Container(
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
      ),
    );
  }
}

Future<bool> _confirmDelete(
  BuildContext context,
  NotificationBloc bloc,
  int id,
) async {
  final response = await showDialog<bool>(
    context: context,
    builder:
        (_) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Delete notification?'),
          content: const Text(
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                bloc.add(DeleteNotification(id));
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
  );

  return response ?? false;
}
