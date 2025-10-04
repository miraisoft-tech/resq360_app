import 'package:resq360/__lib.dart';
import 'package:resq360/features/bookings/data/models/booking_model.dart';
import 'package:resq360/features/bookings/widgets/booking_receipt_modal.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        leading:
            Navigator.canPop(context)
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

  @override
  Widget build(BuildContext context) {
    final bookings = [
      Booking(
        service: 'QuickTow Emergency',
        category: 'Towing Service',
        amount: '₦15,000',
        date: 'August 02, 2025',
        start: '12:00 pm',
        end: '2:00 pm',
      ),
      Booking(
        service: 'QuickTow Emergency',
        category: 'Towing Service',
        amount: '₦15,000',
        date: 'August 03, 2025',
        start: '9:00 am',
        end: '10:00 am',
      ),
    ];

    return ListView.separated(
      padding: pad(vertical: 16, horizontal: 16),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => 16.verticalSpace,
      itemBuilder: (_, index) {
        return BookingCard(
          data: bookings[index],
        );
      },
    );
  }
}

class BookingCard extends StatefulWidget {
  const BookingCard({required this.data, super.key});
  final Booking data;

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

    return Container(
      padding: pad(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lightGreyColor2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  'https://randomuser.me/api/portraits/men/30.jpg',
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GenText(
                          'QuickTow Emergency',
                          height: 24.5,
                          weight: FontWeight.w500,
                          color: colors.black,
                        ),
                      ],
                    ),
                    GenText(
                      'Towing Service',
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
                          '₦15,000',
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
                onTap: () {},
              ),
              10.horizontalSpace,
            ],
          ),
          const ListDivider(
            verticalSpacing: 10,
          ),

          if (expanded)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: AppAssets.ASSETS_ICONS_CALENDER_SVG.svgColor(
                    color: colors.textColor.shade600,
                  ),
                  label: 'Date',
                  value: data.date ?? 'N/A',
                ),
                _InfoRow(
                  icon: AppAssets.ASSETS_ICONS_CLOCK_SVG.svgColor(
                    color: colors.textColor.shade600,
                  ),
                  label: 'Time Started',
                  value: data.start ?? 'N/A',
                ),
                _InfoRow(
                  icon: AppAssets.ASSETS_ICONS_CLOCK_SVG.svgColor(
                    color: colors.textColor.shade600,
                  ),
                  label: 'Time Completed',
                  value: data.end ?? 'N/A',
                ),
                8.verticalSpace,
                GestureDetector(
                  onTap: () async {
                    await GeneralDialogs.showCustomBottomSheet(
                      context,
                      body: BookingReceiptModal(
                        service: 'Towing Service',
                        provider: 'QuickTow Emergency',
                        serviceId: 'TXN-20250815-PLUMB123',
                        status: 'Completed',
                        invoice: '#INV-238777',
                        dateTime:
                            '${data.date ?? 'N/A'} - ${data.end ?? 'N/A'}',
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

                const ListDivider(
                  verticalSpacing: 15,
                ),
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
    );
  }
}

/// Row for Booking Info
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
