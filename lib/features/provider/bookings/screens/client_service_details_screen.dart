import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/core/bloc/service_detail_bloc/service_detail_bloc.dart';
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

class ClientServiceDetailScreen extends StatelessWidget {
  const ClientServiceDetailScreen({required this.booking, super.key});

  final Bookings booking;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = ServiceDetailBloc();
        if (booking.id != null) {
          bloc.add(FetchServiceDetail(booking.id!));
        }
        return bloc;
      },
      child: const _ClientServiceDetailView(),
    );
  }
}

class _ClientServiceDetailView extends StatefulWidget {
  const _ClientServiceDetailView();

  @override
  State<_ClientServiceDetailView> createState() =>
      _ClientServiceDetailViewState();
}

class _ClientServiceDetailViewState extends State<_ClientServiceDetailView> {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: UrbText(
          'Service Details',
          color: appColors.black,
          weight: FontWeight.w700,
          size: 22,
          height: 32.5,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: appColors.whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<BookingBloc, BookingState>(
        listener: (context, state) async {
          if (state is BookingLoading) {
            showLoadingDialog(context);
          }

          if (state is BookingStarted) {
            await pop(context);
            await showSuccessSnackbar(context, 'Service has started');
            context.read<ServiceDetailBloc>().add(const RefreshServiceDetail());
          }

          if (state is BookingArrived) {
            await pop(context);
            await showSuccessSnackbar(context, 'Provider arrival confirmed');
            context.read<ServiceDetailBloc>().add(const RefreshServiceDetail());
          }

          if (state is BookingError) {
            await pop(context);
            await showErrorSnackbar(context, state.error);
          }
        },
        child: BlocBuilder<ServiceDetailBloc, ServiceDetailState>(
          builder: (context, state) {
            if (state is ServiceDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ServiceDetailError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GenText(state.error, color: Colors.red),
                    8.verticalSpace,
                    WideButton(
                      label: 'Retry',
                      onPressed: () {
                        context.read<ServiceDetailBloc>().add(
                          const RefreshServiceDetail(),
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            if (state is! ServiceDetailLoaded) {
              return const SizedBox.shrink();
            }

            final booking = state.booking;
            return _buildContent(context, booking);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Bookings booking) {
    final appColors = context.appColors;
    final clientName = booking.user?.fullName ?? '';
    final serviceRequestId = booking.id;
    final amount = booking.amount ?? '';
    final invoiceNum = booking.invoiceId ?? '';
    final clientImage = booking.user?.profileImage;
    final chatId = booking.chatId;
    final clientPhoneNumber = booking.user?.phoneNumber ?? '';
    final status = booking.status;

    final isAssigned =
        status?.toUpperCase() == BookingEnums.assigned.name.toUpperCase();
    final isArrived =
        status?.toUpperCase() == BookingEnums.arrived.name.toUpperCase();
    final isProgress =
        status?.toUpperCase() == BookingEnums.progress.name.toUpperCase();

    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 50.h),
      child: Column(
        children: [
          12.verticalSpace,
          BlocBuilder<RatingsBloc, RatingsState>(
            builder: (context, rState) {
              final loaded =
                  rState is RatingsLoaded ? rState : const RatingsLoaded();
              final customerRating =
                  loaded.customerRatings?.averageRatings?.toStringAsFixed(1) ??
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
              if (isAssigned || isArrived) ...[
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
                      if (context.mounted) {
                        context.read<ServiceDetailBloc>().add(
                          const RefreshServiceDetail(),
                        );
                      }
                    },
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: WideButton(
                    label: isAssigned ? 'Mark Arrived' : 'Start Service',
                    backgroundColor: appColors.primary.shade500,
                    textColor: appColors.whiteColor,
                    onPressed: () async {
                      if (isAssigned) {
                        if (serviceRequestId != null) {
                          context.read<BookingBloc>().add(
                            ArriveBooking(serviceRequestId: serviceRequestId),
                          );
                        }
                      } else if (isArrived) {
                        if (serviceRequestId != null) {
                          context.read<BookingBloc>().add(
                            StartBooking(serviceRequestId: serviceRequestId),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
              if (isProgress) ...[
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
                    label: 'Complete',
                    backgroundColor: appColors.primary.shade500,
                    textColor: appColors.whiteColor,
                    onPressed: () async {
                      if (serviceRequestId != null) {
                        await pushScreen(
                          context,
                          ClientServiceCompletedScreen(
                            serviceRequestId: serviceRequestId,
                          ),
                        );
                        if (context.mounted) {
                          context.read<ServiceDetailBloc>().add(
                            const RefreshServiceDetail(),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
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
