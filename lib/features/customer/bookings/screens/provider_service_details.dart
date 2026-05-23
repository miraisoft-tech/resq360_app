import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/service_detail_bloc/service_detail_bloc.dart';
import 'package:resq360/core/models/booking_enums.dart';
import 'package:resq360/features/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/chat/screens/payment_appeal.dialog.dart';
import 'package:resq360/features/chat/screens/service_completed_screen.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/bookings/screens/cancel_client_service_screen.dart';
import 'package:resq360/features/settings/data/bloc/ratings_bloc/ratings_bloc.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';
import 'package:resq360/features/widgets/service_details_shared.dart';

class ProviderServiceDetailScreen extends StatelessWidget {
  const ProviderServiceDetailScreen({required this.booking, super.key});

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
      child: const _ProviderServiceDetailView(),
    );
  }
}

class _ProviderServiceDetailView extends StatefulWidget {
  const _ProviderServiceDetailView();

  @override
  State<_ProviderServiceDetailView> createState() =>
      _ProviderServiceDetailViewState();
}

class _ProviderServiceDetailViewState
    extends State<_ProviderServiceDetailView> {
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
      body: BlocBuilder<ServiceDetailBloc, ServiceDetailState>(
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
    );
  }

  Widget _buildContent(BuildContext context, Bookings booking) {
    final appColors = context.appColors;
    final providerName = booking.assignedProvider?.fullName ?? '';
    final serviceRequestId = booking.id;
    final amount = booking.amount ?? '';
    final invoiceNum = booking.invoiceId ?? '';
    final providerImage = booking.assignedProvider?.profileImage;
    final serviceCategoryName = booking.serviceCategory?.name;
    final chatId = booking.chatId;
    final providerPhoneNumber = booking.assignedProvider?.phoneNumber ?? '';
    final status = booking.status;

    final isAssigned =
        status?.toUpperCase() == BookingEnums.assigned.name.toUpperCase();
    final isArrived =
        status?.toUpperCase() == BookingEnums.arrived.name.toUpperCase();
    // status?.toUpperCase() == BookingEnums.completed.name.toUpperCase();
    final isAwaitingProvider = isAssigned || isArrived;

    final isProgress =
        status?.toUpperCase() == BookingEnums.progress.name.toUpperCase();
    final isCompleted =
        booking.completedBy?.toLowerCase() == UserType.provider.value;

    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 50.h),
      child: Column(
        children: [
          16.verticalSpace,
          BlocBuilder<RatingsBloc, RatingsState>(
            builder: (context, rState) {
              final loaded =
                  rState is RatingsLoaded ? rState : const RatingsLoaded();

              final providerRating =
                  loaded.providerRatings?.averageRatings?.toStringAsFixed(1) ??
                  '0.0';

              final providerReviewCount =
                  '(${loaded.providerRatings?.totalReviews ?? 0} reviews)';

              return ServicePersonCard(
                name: providerName,
                subtitle: serviceCategoryName ?? '',
                rating: providerRating,
                reviewCount: providerReviewCount,
                avatar: providerImage ?? '',
                showActions: true,
                chatId: chatId,
                phoneNumber: providerPhoneNumber,
              );
            },
          ),
          16.verticalSpace,
          ServiceDetailInvoiceCard(invoiceNum: invoiceNum, amount: amount),
          const Spacer(),
          Row(
            children: [
              if (isAwaitingProvider) ...[
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
              ],
              if (isCompleted || isProgress) ...[
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
                      if (serviceRequestId == null) return;
                      await pushScreen(
                        context,
                        ServiceCompletedScreen(
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
      builder: (_) => const PaymentAppealDialog(isProvider: false),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    showLoadingDialog(context);

    final result = await SupportRepo.instance.fileDispute(
      requestId: serviceRequestId,
      reason: 'Service Appeal',
      details:
          'Customer filed an appeal for service request #$serviceRequestId',
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
      ChatDetailScreen(chatId: chatId, userType: UserType.customer),
    );
  }
}
