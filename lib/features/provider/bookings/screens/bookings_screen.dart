
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/provider/bookings/data/bloc/provider_service_bloc.dart';
import 'package:resq360/features/provider/bookings/screens/client_service_details_screen.dart';
import 'package:resq360/features/provider/bookings/widgets/booking_receipt_modal.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookingsForTab(0);
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _fetchBookingsForTab(_tabController.index);
    });
  }

  void _fetchBookingsForTab(int index) {
    final bloc = context.read<ProviderServiceBloc>();
    String status;

    switch (index) {
      case 0:
        status = 'PENDING'; 
      case 1:
        status = 'COMPLETED';
      case 2:
        status = 'CANCELLED';
      default:
        status = 'PENDING';
    }

    bloc.add(ProviderFetchBookings(status: status));
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        backgroundColor: appColors.whiteColor,
        elevation: 0,
        title: UrbText(
          'My Bookings',
          size: 18,
          weight: FontWeight.w700,
          color: appColors.black,
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: appColors.black),
                onPressed: () => pop(context),
              )
            : null,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: appColors.primary,
          labelColor: appColors.primary,
          unselectedLabelColor: appColors.textColor.shade500,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BookingList(type: 'upcoming'),
          _BookingList(type: 'completed'),
          _BookingList(type: 'cancelled'),
        ],
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({required this.type});
  final String type;

  String _mapTypeToStatus() {
    switch (type) {
      case 'upcoming':
        return 'PENDING';
      case 'completed':
        return 'COMPLETED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return 'PENDING';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderServiceBloc, ProviderServiceState>(
      builder: (context, state) {
        if (state is ProviderServicesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProviderServicesError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.error,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: WideButton(
                    label: 'Retry',
                    onPressed: () {
                      context.read<ProviderServiceBloc>().add(
                            ProviderFetchBookings(
                              status: _mapTypeToStatus(),
                            ),
                          );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ProviderBookingsLoaded) {
          final bookings = state.bookings;
          if (bookings.isEmpty) {
            return const Center(child: GenText('No bookings found.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProviderServiceBloc>().add(
                    ProviderFetchBookings(
                      status: _mapTypeToStatus(),
                    ),
                  );
            },
            child: ListView.separated(
              padding: pad(vertical: 16, horizontal: 16),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => 16.verticalSpace,
              itemBuilder: (_, index) {
                final booking = bookings[index];
                return BookingCard(
                  data: booking,
                  onTap: () async {
                    await pushScreen(
                      context,
                      const ProviderServiceDetailScreen(
                        // booking: booking,
                      ),
                    );
                  },
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class BookingCard extends StatefulWidget {
  const BookingCard({required this.data, required this.onTap, super.key});
  final Bookings data;
  final VoidCallback onTap;

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool expanded = false;

  void expandCard() {
    setState(() {
      expanded = !expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final data = widget.data;

    final clientName = data.user?.fullName ?? 'Unknown Client';
    final serviceCategory = data.serviceCategory?.name ?? 'Uncategorized';
    final amount = '${data.currency ?? '₦'}${data.amount ?? '0'}';
    final date = data.createdAt?.formatDate ?? 'N/A';
    final start = data.responseTime?.providerStartedAt?.formatTime ?? '--';
    final end = data.responseTime?.completedAt?.formatTime ?? '--';
    final status = data.status?.capitalize ?? 'Unknown';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: pad(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: colors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.lightGreyColor2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Header Row
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: 
                  // data.client?.profileImage != null
                  //     ? NetworkImage(data.client!.profileImage!)
                  //     : 
                      AssetImage(AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG)
                          as ImageProvider,
                ),
                12.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GenText(
                        clientName,
                        height: 24.5,
                        weight: FontWeight.w500,
                        color: colors.black,
                      ),
                      GenText(
                        serviceCategory,
                        size: 12,
                        height: 20.5,
                        weight: FontWeight.w500,
                        color: colors.neutral.shade400,
                      ),
                      Row(
                        children: [
                          AppAssets.ASSETS_ICONS_TOW_ICON_SVG.svg,
                          4.horizontalSpace,
                          GenText(
                            amount,
                            size: 12,
                            height: 20.5,
                            weight: FontWeight.w400,
                            color: colors.black,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SVGButton(
                  path: AppAssets.ASSETS_ICONS_CHAT_ICON_SVG,
                  onTap: () {},
                ),
                15.horizontalSpace,
                SVGButton(
                  path: AppAssets.ASSETS_ICONS_CALL_ICON_SVG,
                  color: colors.primary.shade500,
                  onTap: () {},
                ),
              ],
            ),
            const ListDivider(verticalSpacing: 10),

            /// --- Expanded Details
            if (expanded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: AppAssets.ASSETS_ICONS_CALENDER_SVG.svgColor(
                      color: colors.textColor.shade600,
                    ),
                    label: 'Date',
                    value: date,
                  ),
                  _InfoRow(
                    icon: AppAssets.ASSETS_ICONS_CLOCK_SVG.svgColor(
                      color: colors.textColor.shade600,
                    ),
                    label: 'Time Started',
                    value: start,
                  ),
                  _InfoRow(
                    icon: AppAssets.ASSETS_ICONS_CLOCK_SVG.svgColor(
                      color: colors.textColor.shade600,
                    ),
                    label: 'Time Completed',
                    value: end,
                  ),
                  8.verticalSpace,
                  GestureDetector(
                    onTap: () async {
                      await GeneralDialogs.showCustomBottomSheet(
                        context,
                        body: BookingReceiptModal(
                          service: serviceCategory,
                          provider: clientName,
                          status: status,
                          invoice: data.payment?.paymentReference ?? 'N/A',
                          dateTime: '$date - $end',
                          method: 'Card',
                          onDownload: () {},
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        AppAssets.ASSETS_ICONS_RECEIPT_SVG.svg,
                        5.horizontalSpace,
                        GenText(
                          'View Receipt',
                          size: 12,
                          weight: FontWeight.w400,
                          color: colors.primary.shade500,
                          decoration: TextDecoration.underline,
                        ),
                      ],
                    ),
                  ),
                  const ListDivider(verticalSpacing: 15),
                ],
              ),
            GestureDetector(
              onTap: expandCard,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GenText(
                    expanded ? 'View Less' : 'View More',
                    weight: FontWeight.w500,
                    color: colors.primary.shade500,
                  ),
                  4.horizontalSpace,
                  Transform.rotate(
                    angle: expanded ? 3.14 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: colors.primary.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// --- Booking Info Row
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final Widget icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          icon,
          8.horizontalSpace,
          GenText(
            '$label: $value',
            size: 13,
            color: colors.textColor.shade600,
          ),
        ],
      ),
    );
  }
}
