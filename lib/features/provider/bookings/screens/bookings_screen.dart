import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/core/utils/booking_reciept_pdf_util.dart';
import 'package:resq360/core/utils/dialer_util.dart';
import 'package:resq360/features/chat/data/services/chat_repo.dart';
import 'package:resq360/features/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/bookings/data/bloc/provider_service_bloc.dart';
import 'package:resq360/features/provider/bookings/screens/client_service_details_screen.dart';
import 'package:resq360/features/provider/bookings/widgets/booking_receipt_modal.dart';
import 'package:resq360/features/widgets/empty_screen_widget.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
        status = 'upcoming';
      case 1:
        status = 'ongoing';
      case 2:
        status = 'completed';
      case 3:
        status = 'cancelled';
      default:
        status = 'upcoming';
    }

    bloc.add(ProviderFetchBookings(status: status));
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.h),
        child: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: appColors.whiteColor,
          elevation: 0,
          centerTitle: false,
          title: Padding(
            padding: pad(horizontal: 10),
            child: UrbText(
              'My Bookings',
              size: 20,
              height: 22,
              weight: FontWeight.w700,
              color: appColors.black,
            ),
          ),
          leading:
              Navigator.canPop(context)
                  ? IconButton(
                    icon: Icon(Icons.arrow_back, color: appColors.black),
                    onPressed: () => pop(context),
                  )
                  : null,
          bottom: TabBar(
            onTap: (value) {
              setState(() {});
            },
            controller: _tabController,
            indicatorColor: appColors.primary,
            labelColor: appColors.primary,
            unselectedLabelColor: appColors.textColor.shade500,
            indicatorSize: TabBarIndicatorSize.tab,
            padding: EdgeInsets.only(bottom: 10.h),
            tabs: [
              SizedBox(
                width: double.infinity,
                child: GenText(
                  'Upcoming',
                  textAlign: TextAlign.center,
                  weight: FontWeight.w500,
                  size: 11,
                  height: 30,
                  color:
                      _tabController.index == 0
                          ? appColors.primary
                          : appColors.neutral.shade500,
                  maxLines: 1,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: GenText(
                  'Ongoing',
                  textAlign: TextAlign.center,
                  weight: FontWeight.w500,
                  size: 11,
                  height: 30,
                  color:
                      _tabController.index == 1
                          ? appColors.primary
                          : appColors.neutral.shade500,
                  maxLines: 1,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: GenText(
                  'Completed',
                  textAlign: TextAlign.center,
                  weight: FontWeight.w500,
                  size: 11,
                  height: 30,
                  color:
                      _tabController.index == 2
                          ? appColors.primary
                          : appColors.neutral.shade500,
                  maxLines: 1,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: GenText(
                  'Cancelled',
                  textAlign: TextAlign.center,
                  weight: FontWeight.w500,
                  size: 11,
                  height: 30,
                  color:
                      _tabController.index == 3
                          ? appColors.primary
                          : appColors.neutral.shade500,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BookingList(type: 'upcoming'),
          _BookingList(type: 'ongoing'),
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
        return 'upcoming';
      case 'ongoing':
        return 'ongoing';
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      default:
        return 'upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return BlocBuilder<ProviderServiceBloc, ProviderServiceState>(
      builder: (context, state) {
        if (state is ProviderServicesLoading) {
          return Center(
            child: CircularProgressIndicator(color: appColors.primary),
          );
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
                        ProviderFetchBookings(status: _mapTypeToStatus()),
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
            return EmptyScreenWidget(
              image: AppAssets.ASSETS_ICONS_EMPTY_STATE_SVG.svg,
              message: 'No booking found',
              subMessage: '',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProviderServiceBloc>().add(
                ProviderFetchBookings(status: _mapTypeToStatus()),
              );
            },
            color: appColors.primary,
            child: ListView.separated(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: 100.h,
              ),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => 16.verticalSpace,
              itemBuilder: (_, index) {
                final booking = bookings[index];
                return BookingCard(
                  data: booking,
                  onTap: () async {
                    await pushScreen(
                      context,
                      ClientServiceDetailScreen(booking: booking),
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

  Future<void> navigateToChatByServiceRequest(
    BuildContext context,
    int serviceRequestId,
  ) async {
    try {
      showLoadingDialog(context);

      final response = await ChatRepo().getChatByserviceRequestId(
        serviceRequestId,
      );

      Navigator.pop(context);

      if (response.data != null) {
        final chatId = response.data?.id;
        if (chatId != null) {
          await pushScreen(
            context,
            ChatDetailScreen(chatId: chatId, userType: UserType.provider),
          );
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

    final clientName = data.user?.fullName ?? 'Unknown Client';
    final serviceCategory = data.serviceCategory?.name ?? 'Uncategorized';
    final amount = data.amount ?? '';
    final date = data.expectedStartDate?.formatDate ?? 'N/A';
    final start = data.providerStartedAt?.formatTime ?? '--';
    final end = data.completedAt?.formatTime ?? '--';

    final status = data.status?.capitalize ?? 'Unknown';

    final method = data.paymentMethod ?? 'Unknown';

    final phonenumber = data.user?.phoneNumber ?? '';
    final serviceRequest = data.id;

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
            Row(
              children: [
                PictureWidget(image: data.user!.profileImage),
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
                            'NGN${AppTextUtil.formatAmount(amount)}',
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
                  onTap: () async {
                    log(serviceRequest);
                    if (serviceRequest != null) {
                      await navigateToChatByServiceRequest(
                        context,
                        serviceRequest,
                      );
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
              ],
            ),
            const ListDivider(verticalSpacing: 10),

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
                          invoice: data.requestId ?? 'N/A',
                          amount: amount,
                          dateTime: '$date - $end',
                          method: method,
                          onDownload: () async {
                            await BookingReceiptPdfUtil.generateBookingReceiptPdf(
                              bookingId: data.requestId ?? 'N/A',
                              service: serviceCategory,
                              clientName: clientName,
                              status: status,
                              dateTime: '$date - $end',
                              paymentMethod: method,
                              amount: amount,
                            );
                          },
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
          GenText('$label: $value', size: 13, color: colors.textColor.shade600),
        ],
      ),
    );
  }
}
