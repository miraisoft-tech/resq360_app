import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/chat/screens/payment_appeal.dialog.dart';
import 'package:resq360/features/chat/screens/service_cancelled_screen.dart';
// import 'package:resq360/features/chat/screens/service_completed_screen.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
// import 'package:resq360/features/provider/bookings/data/models/booking_enums.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';

class OngoingServiceCard extends StatefulWidget {
  const OngoingServiceCard({required this.booking, super.key});

  final Bookings booking;

  @override
  State<OngoingServiceCard> createState() => _OngoingServiceCardState();
}

class _OngoingServiceCardState extends State<OngoingServiceCard> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final providerName =
        widget.booking.assignedProvider?.fullName ?? 'Assigned Provider';

    final serviceName = widget.booking.serviceCategory?.name ?? 'Service';

    final status = widget.booking.status ?? 'PENDING';
    final serviceRequestId = widget.booking.id;

    return Container(
      padding: pad(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colors.whiteColor,
        border: Border.all(color: colors.lightGreyColor2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              PictureWidget(
                image: widget.booking.assignedProvider?.profileImage,
              ),
              8.horizontalSpace,
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
                          maxLines: 1,
                        ),
                        const Spacer(),
                        Container(
                          padding: pad(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.success.shade50,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: GenText(
                            status.replaceAll('_', ' '),
                            size: 10,
                            height: 20.5,
                            color: colors.success.shade700,
                          ),
                        ),
                      ],
                    ),
                    GenText(
                      serviceName,
                      size: 12,
                      height: 20.5,
                      weight: FontWeight.w500,
                      color: colors.neutral.shade400,
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
                          color: colors.black,
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
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: pad(horizontal: 14, vertical: 10),
                    elevation: 0,
                    backgroundColor: colors.error.shade50,
                    foregroundColor: colors.primary.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () => _handleAppeal(context, serviceRequestId),
                  child: GenText(
                    'Appeal',
                    height: 16.5,
                    color: colors.primary.shade500,
                    weight: FontWeight.w500,
                  ),
                ),
              ),

              20.horizontalSpace,
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: pad(horizontal: 14, vertical: 10),
                    backgroundColor: colors.primary.shade500,
                    foregroundColor: colors.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),

                  onPressed: () async {
                    final serviceRequestId = widget.booking.id;
                    if (serviceRequestId == null) return;
                    await pushScreen(
                      context,
                      ServiceCancelledScreen(
                        serviceRequestId: serviceRequestId,
                      ),
                    );
                  },
                  child: GenText(
                    'Cancel',
                    height: 16.5,
                    color: colors.whiteColor,
                    weight: FontWeight.w500,
                  ),
                ),
              ),

              // if (status == BookingStatus.completed.value) ...[
              // 20.horizontalSpace,
              // Expanded(
              //   child: ElevatedButton(
              //     onPressed: () async {
              //       final serviceRequestId = widget.booking.id;
              //       if (serviceRequestId == null) return;

              //       await pushScreen(
              //         context,
              //         ServiceCompletedScreen(
              //           serviceRequestId: serviceRequestId,
              //         ),
              //       );
              //     },
              //     style: ElevatedButton.styleFrom(
              //       padding: pad(horizontal: 14, vertical: 10),
              //       backgroundColor: colors.primary.shade500,
              //       foregroundColor: colors.whiteColor,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8.r),
              //       ),
              //     ),
              //     child: GenText(
              //       'Complete',
              //       height: 16.5,
              //       color: colors.whiteColor,
              //       weight: FontWeight.w500,
              //     ),
              //   ),
              // ),
            ],
            // ],
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
      ChatDetailScreen(
        chatId: chatId,
        userType:
            widget.booking.userId != null
                ? UserType.customer
                : UserType.provider,
      ),
    );
  }
}
