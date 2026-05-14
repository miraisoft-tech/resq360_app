import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/core/models/booking_enums.dart';
import 'package:resq360/features/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/chat/screens/payment_appeal.dialog.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/bookings/screens/cancel_client_service_screen.dart';
import 'package:resq360/features/provider/bookings/screens/client_service_completed_screen.dart';
import 'package:resq360/features/settings/data/bloc/ratings_bloc/ratings_bloc.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';
import 'package:resq360/features/widgets/service_details_shared.dart';

class ClientServiceDetailScreen extends StatefulWidget {
  const ClientServiceDetailScreen({required this.booking, super.key});

  final Bookings booking;

  @override
  State<ClientServiceDetailScreen> createState() =>
      _ClientServiceDetailScreenState();
}

class _ClientServiceDetailScreenState extends State<ClientServiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    _fetchRatings();
  }

  void _fetchRatings() {
    if (widget.booking.assignedProviderId != null) {
      context.read<RatingsBloc>().add(
        FetchProviderRatingsById(
          providerId: widget.booking.assignedProviderId!,
        ),
      );
    }

    if (widget.booking.userId != null) {
      context.read<RatingsBloc>().add(
        FetchCustomerRatingsById(userId: widget.booking.userId!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final clientName = widget.booking.user?.fullName ?? '';
    final serviceRequestId = widget.booking.id;
    final amount = widget.booking.amount ?? '';
    final invoiceNum = widget.booking.invoiceId ?? '';
    final clientImage = widget.booking.user?.profileImage;
    final chatId = widget.booking.chatId;
    final clientPhoneNumber = widget.booking.user?.phoneNumber ?? '';
    final status = widget.booking.status;

    final isAssigned =
        status?.toUpperCase() == BookingEnums.assigned.name.toUpperCase();
    final isProgress =
        status?.toUpperCase() == BookingEnums.progress.name.toUpperCase();
    final isCompleted =
        status?.toUpperCase() == BookingEnums.completed.name.toUpperCase();

    return MultiBlocListener(
      listeners: [
        BlocListener<BookingBloc, BookingState>(
          listener: (context, state) async {
            if (state is BookingLoading) {
              showLoadingDialog(context);
            }

            if (state is BookingStarted) {
              await pop(context);
              await showSuccessSnackbar(context, 'Service has started');
              await pop(context);
            }

            if (state is BookingCompleted) {
              await pop(context);
              await showSuccessSnackbar(
                context,
                'Service has been marked as completed',
              );
            }

            if (state is BookingError) {
              await pop(context);
              await showErrorSnackbar(context, state.error);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: appColors.whiteColor,
        appBar: AppBar(
          title: UrbText(
            'Service Details',
            color: appColors.black,
            weight: FontWeight.w700,
            size: 22,
            height: 32.5,
          ),
          forceMaterialTransparency: true,
          centerTitle: true,
          elevation: 0,
          backgroundColor: appColors.whiteColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: appColors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 50.h),
          child: Column(
            children: [
              12.verticalSpace,
              BlocBuilder<RatingsBloc, RatingsState>(
                builder: (context, state) {
                  final loaded =
                      state is RatingsLoaded ? state : const RatingsLoaded();
                  final customerRating =
                      loaded.customerRatings?.averageRatings?.toStringAsFixed(
                        1,
                      ) ??
                      '0.0';
                  final customerReviewCount =
                      '(${loaded.customerRatings?.totalReviews ?? 0} reviews)';

                  return ServicePersonCard(
                    name: clientName,
                    subtitle: '',
                    rating: customerRating,
                    reviewCount: customerReviewCount,
                    avatar: clientImage ?? '',
                    showActions: true,
                    chatId: chatId,
                    phoneNumber: clientPhoneNumber,
                  );
                },
              ),
              16.verticalSpace,
              ServiceDetailInvoiceCard(invoiceNum: invoiceNum, amount: amount),
              const Spacer(),
              Row(
                children: [
                  if (!isCompleted) ...[
                    Expanded(
                      child: WideButton(
                        label: 'Cancel',
                        backgroundColor: appColors.primary.shade50,
                        textColor: appColors.primary.shade500,
                        onPressed: () async {
                          if (serviceRequestId == null) return;
                          await pushScreen(
                            context,
                            CancelClientServiceScreen(
                              serviceRequestId: serviceRequestId,
                            ),
                          );
                        },
                      ),
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: WideButton(
                        label: isAssigned ? 'Start Service' : 'Complete',
                        backgroundColor: appColors.primary.shade500,
                        textColor: appColors.whiteColor,
                        onPressed: () async {
                          if (isAssigned) {
                            if (serviceRequestId != null) {
                              context.read<BookingBloc>().add(
                                StartBooking(
                                  serviceRequestId: serviceRequestId,
                                ),
                              );
                            }
                          } else if (isProgress) {
                            if (serviceRequestId != null) {
                              await pushScreen(
                                context,
                                ClientServiceCompletedScreen(
                                  serviceRequestId: serviceRequestId,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                  if (isCompleted) ...[
                    Expanded(
                      child: WideButton(
                        label: 'Appeal',
                        backgroundColor: appColors.primary.shade50,
                        textColor: appColors.primary.shade500,
                        onPressed: () async {
                          await _handleAppeal(context, serviceRequestId);
                        },
                      ),
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: WideButton(
                        label: 'Rate Client',
                        backgroundColor: appColors.primary.shade500,
                        textColor: appColors.whiteColor,
                        onPressed: () async {
                          // wire to provider's rate client screen
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAppeal(
    BuildContext context,
    int? serviceRequestId,
  ) async {
    if (serviceRequestId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const PaymentAppealDialog(isProvider: true),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    showLoadingDialog(context);

    final result = await SupportRepo.instance.fileDispute(
      requestId: serviceRequestId,
      reason: 'Service Appeal',
      details:
          'Provider filed an appeal for service request #$serviceRequestId',
    );

    if (!context.mounted) return;
    Navigator.pop(context);

    if (result.error != null) {
      await showErrorSnackbar(context, result.error!);
      return;
    }

    final chatId = result.data!;
    await pushScreen(
      context,
      ChatDetailScreen(chatId: chatId, userType: UserType.provider),
    );
  }
}
