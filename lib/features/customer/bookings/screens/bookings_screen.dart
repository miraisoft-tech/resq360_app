import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_pdf_util.dart';
import 'package:resq360/core/utils/dialer_util.dart';
import 'package:resq360/features/customer/bookings/data/bloc/customer_booking_bloc.dart';
import 'package:resq360/features/customer/bookings/widgets/booking_receipt_modal.dart';
import 'package:resq360/features/customer/chat/data/services/chat_repo.dart';
import 'package:resq360/features/customer/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookingsForTab(0);
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _fetchBookingsForTab(_tabController.index);
    });
  }

  void _fetchBookingsForTab(int index) {
    final bloc = context.read<CustomerBookingBloc>();
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

    bloc.add(
      FetchCustomerBookings(status: status),
    );
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
    final appColors = context.appColors;

    return BlocBuilder<CustomerBookingBloc, CustomerBookingState>(
      builder: (context, state) {
        if (state is CustomerBookingLoading) {
          return  Center(child: CircularProgressIndicator(
            color: appColors.primary,

          ));
        }

        if (state is CustomerBookingError) {
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
                      context.read<CustomerBookingBloc>().add(
                        FetchCustomerBookings(status: _mapTypeToStatus()),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        if (state is CustomerBookingLoaded) {
          final bookings = state.bookings;
          if (bookings.isEmpty) {
            return const Center(child: GenText('No bookings found.'));
          }

          return RefreshIndicator(
            color: appColors.primary,
            onRefresh: () async {
              context.read<CustomerBookingBloc>().add(
                FetchCustomerBookings(status: _mapTypeToStatus()),
              );
            },
            child: ListView.separated(
              padding: pad(vertical: 16, horizontal: 16),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => 16.verticalSpace,
              itemBuilder: (_, index) {
                final booking = bookings[index];
                return BookingCard(data: booking);
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
  const BookingCard({required this.data, super.key});
  final Bookings data;

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

    Future<void> _navigateToChatByServiceRequest(
  BuildContext context,
  int serviceRequestId,
) async {
  try {
     unawaited(showLoadingDialog(context));
    
    final response = await ChatRepo().getChatByserviceRequestId(serviceRequestId);
    
    Navigator.pop(context);
    
    if (response.data != null) {
      final chatId = response.data?.id; 
      if(chatId != null){
      await pushScreen(context, ChatDetailScreen(chatId: chatId));
      }
    } else {
      await showErrorSnackbar(context, 'Unable to open chat');
    }
  } on Exception catch (e) {
    Navigator.pop(context);
    await showErrorSnackbar(context, 'Failed to load chat: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final data = widget.data;

    final providerName = data.assignedProvider?.fullName ?? 'Unknown Provider';

    final serviceCategory = data.serviceCategory?.name ?? 'Uncategorized';
        final amount = data.amount ?? '';

    final date = data.createdAt?.formatDate ?? 'N/A';
    final start = data.providerStartedAt?.formatTime ?? '--';
    final end = data.completedAt?.formatTime ?? '--';

    final status = data.status?.capitalize ?? 'Unknown';
    final canDownload = data.status == 'COMPLETED';
    final canShow = data.status == 'COMPLETED' || data.status == 'CANCELLED';

    final phonenumber = data.assignedProvider?.phoneNumber ?? '';
    final serviceRequest = data.id;
    

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
          /// --- Header Row
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage:
                    data.assignedProvider?.profileImage != null
                        ? NetworkImage(data.assignedProvider!.profileImage!)
                        : const NetworkImage(
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
                          providerName,
                          height: 24.5,
                          weight: FontWeight.w500,
                          color: colors.black,
                        ),
                      ],
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
                          if(canShow)...{
                        AppAssets.ASSETS_ICONS_TOW_ICON_SVG.svg,
                        4.horizontalSpace,
                        GenText(
                          amount,
                          size: 12,
                          height: 20.5,
                          weight: FontWeight.w400,
                          color: colors.black,
                        ),
                          }
                      ],
                    ),
                  ],
                ),
              ),
              SVGButton(
                path: AppAssets.ASSETS_ICONS_CHAT_ICON_SVG,
                onTap: () async {
                  if (serviceRequest != null) {
                  await _navigateToChatByServiceRequest(context, serviceRequest);
                  }
                },
              ),
              15.horizontalSpace,
              SVGButton(
                path: AppAssets.ASSETS_ICONS_CALL_ICON_SVG,
                color: colors.primary.shade500,
                onTap: () async {
                  await DialerUtil.open(phonenumber);
                },
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
                        provider: providerName,
                        serviceId: data.requestId ?? 'N/A',
                        status: status,
                        invoice: data.requestId ?? 'N/A',
                        dateTime: '$date - $end',
                        method: 'Card',
                        onDownload:
                            canDownload
                                ? 
                                () async {
                                  await BookingReceiptPdfUtil.generateBookingReceiptPdf(
                                    bookingId: data.requestId ?? 'N/A',
                                    service: serviceCategory,
                                    providerName: providerName,
                                    status: status,
                                    dateTime: '$date - $end',
                                    paymentMethod: 'Card',
                                    amount: 'To be billed',
                                  );
                                }
                                : null,
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
