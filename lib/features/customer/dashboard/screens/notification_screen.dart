import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/notification/notification_response.model.dart'
    as notif;
import 'package:resq360/core/theme/app_color_theme.dart';
import 'package:resq360/core/utils/app_text.util.dart';
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
  final _scrollController = ScrollController();

  int _offset = 0;
  final int _limit = 20;
  bool _isLoadingMore = false;
  int unreadCount = 0;

  List<NotificationModel> _cached = [];
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _fetchInitial();
    _scrollController.addListener(_onScroll);
  }

  void _fetchInitial() {
    _offset = 0;
    context.read<NotificationBloc>().add(FetchUnreadCount());
    context.read<NotificationBloc>().add(
      FetchRecentNotifications(
        offset: _offset,
        limit: _limit,
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  void _loadMore() {
    _isLoadingMore = true;
    _offset += _limit;

    context.read<NotificationBloc>().add(
      FetchRecentNotifications(
        offset: _offset,
        limit: _limit,
        loadMore: true,
      ),
    );
  }

  Future<void> _onRefresh() async {
    _offset = 0;
    _isLoadingMore = false;

    context.read<NotificationBloc>().add(
      FetchRecentNotifications(
        offset: _offset,
        limit: _limit,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

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
        listener: (context, state) {
          if (state is UnreadCountLoaded) {
            setState(() {
              unreadCount = state.count;
            });
          }

          if (state is NotificationActionSuccess) {
            context.read<NotificationBloc>().add(
                  const FetchRecentNotifications(),
                );
            unawaited(showSuccessSnackbar(context, state.message));
          }

          if (state is NotificationError) {
            unawaited(showErrorSnackbar(context, state.message));
          }
        },
        builder: (context, state) {
          if (state is NotificationInitial || state is NotificationLoading) {
            if (_cached.isNotEmpty) {
              return _buildList(appColors);
            }
            return Center(
              child: CircularProgressIndicator(color: appColors.primary),
            );
          }

          if (state is NotificationLoaded) {
            _isLoadingMore = false;
            _hasLoadedOnce = true;

            final uiList = state.notifications.map(mapToUi).toList();

            if (uiList.isNotEmpty || _offset == 0) {
              _cached = uiList;
            }

            if (_cached.isEmpty && _hasLoadedOnce) {
              return EmptyScreenWidget(
                image:
                    AppAssets.ASSETS_IMAGES_NOTIFICATIONS_EMPTY_PNG.imageAsset(),
                message: 'No Notifications Yet',
                subMessage:
                    "You'll see updates about your bookings and payments here.",
              );
            }

            return _buildList(appColors);
          }

          if (state is NotificationError && _cached.isEmpty) {
            return ErrorMessageAndButton(
              error: state.message,
              onPressed: () {
                context.read<NotificationBloc>().add(
                      const FetchRecentNotifications(),
                    );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildList(AppColorPalette appColors) {
    final grouped = _groupNotifications(_cached);

    return RefreshIndicator(
      color: appColors.primary,
      onRefresh: _onRefresh,
      child: Padding(
        padding: pad(horizontal: 20, vertical: 10),
        child: ListView(
          controller: _scrollController,
          children: [
            if (unreadCount > 0)
              _HeaderRow(count: unreadCount, color: appColors),
            20.verticalSpace,

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

            if (_isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
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

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.count, required this.color});

  final int count;
  final AppColorPalette color;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NotificationBloc>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GenText(
          '$count new notification${count == 1 ? '' : 's'}',
          color: color.black,
          weight: FontWeight.w600,
        ),
        GestureDetector(
          onTap: () {
            bloc.add(MarkAllAsRead());
          },
          child: GenText(
            'Mark all as read',
            size: 13,
            color: color.primary.shade500,
            weight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

NotificationModel mapToUi(notif.Notification n) {
  return NotificationModel(
    id: n.id!,
    title: n.provider?.fullName ?? n.user?.fullName ?? '',
    message: n.details ?? '',
    time: AppTextUtil.timeAgo(n.createdAt),
    isUnread: n.status == 'UNREAD',
    group: AppTextUtil.groupByDate(n.createdAt),
    icon: _iconForCategory(n.category),
    category: n.category,
    serviceRequestId: int.tryParse(n.serviceRequestId ?? ''),
    providerId: n.providerId,
    providerName: n.provider?.fullName,
  );
}

SvgPicture _iconForCategory(String? category) {
  switch (category) {
    case 'BOOKING':
      return AppAssets.ASSETS_ICONS_NOTIFICATION_B_SVG.svg;
    case 'SERVICE_COMPLETION':
      return AppAssets.ASSETS_ICONS_NOTIFICATION_S_SVG.svg;
    case 'NORMAL':
      return AppAssets.ASSETS_ICONS_NOTIFICATION_R_SVG.svg;
    default:
      return AppAssets.ASSETS_ICONS_NOTIFICATION_S_SVG.svg;
  }
}
