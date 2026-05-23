import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/core/models/booking_enums.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/chat/screens/payment_appeal.dialog.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/bookings/screens/cancel_client_service_screen.dart';
import 'package:resq360/features/provider/bookings/screens/client_service_completed_screen.dart';
import 'package:resq360/features/provider/dashboard/data/bloc/provider_ongoing_bloc.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';

class ProviderOngoingServiceCard extends StatefulWidget {
  const ProviderOngoingServiceCard({required this.booking, super.key});

  final Bookings booking;

  @override
  State<ProviderOngoingServiceCard> createState() =>
      _ProviderOngoingServiceCardState();
}

class _ProviderOngoingServiceCardState
    extends State<ProviderOngoingServiceCard> {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final clientName =
        widget.booking.user?.fullName ??
        widget.booking.assignedProvider?.fullName ??
        'Client';
    final serviceName = widget.booking.serviceCategory?.name ?? 'Service';
    final serviceRequestId = widget.booking.id;
    final status = widget.booking.status;

    final isAssigned =
        status?.toUpperCase() == BookingEnums.assigned.name.toUpperCase();
    final isArrived =
        status?.toUpperCase() == BookingEnums.arrived.name.toUpperCase();
    final isProgress =
        status?.toUpperCase() == BookingEnums.progress.name.toUpperCase();

    return Container(
      padding: pad(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: appColors.whiteColor,
        border: Border.all(color: appColors.lightGreyColor2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              PictureWidget(
                image:
                    widget.booking.user?.profileImage ??
                    widget.booking.assignedProvider?.profileImage,
              ),
              8.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GenText(
                          clientName,
                          height: 24.5,
                          weight: FontWeight.w500,
                          color: appColors.black,
                          maxLines: 1,
                        ),
                        const Spacer(),
                        Container(
                          padding: pad(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: appColors.success.shade50,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: GenText(
                            status?.replaceAll('_', ' ') ?? 'N/A',
                            size: 10,
                            height: 20.5,
                            color: appColors.success.shade700,
                          ),
                        ),
                      ],
                    ),
                    GenText(
                      serviceName,
                      size: 12,
                      height: 20.5,
                      weight: FontWeight.w500,
                      color: appColors.neutral.shade400,
                      maxLines: 1,
                    ),
                    Row(
                      children: [
                        AppAssets.ASSETS_ICONS_TOW_ICON_SVG.svg,
                        4.horizontalSpace,
                        GenText(
                          '₦${AppTextUtil.formatAmount(widget.booking.amount?.toString() ?? '0')}',
                          size: 12,
                          height: 20.5,
                          weight: FontWeight.w400,
                          color: appColors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          20.verticalSpace,
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
                        context.read<ProviderOngoingBloc>().add(
                          const FetchProviderOngoingService(),
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
                      if (serviceRequestId == null) return;
                      if (isAssigned) {
                        context.read<BookingBloc>().add(
                          ArriveBooking(serviceRequestId: serviceRequestId),
                        );
                      } else if (isArrived) {
                        context.read<BookingBloc>().add(
                          StartBooking(serviceRequestId: serviceRequestId),
                        );
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
                      if (serviceRequestId == null) return;
                      await pushScreen(
                        context,
                        ClientServiceCompletedScreen(
                          serviceRequestId: serviceRequestId,
                        ),
                      );
                      if (context.mounted) {
                        context.read<ProviderOngoingBloc>().add(
                          const FetchProviderOngoingService(),
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
