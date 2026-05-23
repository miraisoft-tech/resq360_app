import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/core/bloc/service_detail_bloc/service_detail_bloc.dart';
import 'package:resq360/core/models/booking_enums.dart';
import 'package:resq360/features/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/chat/screens/payment_appeal.dialog.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/provider/bookings/screens/client_service_completed_screen.dart';
import 'package:resq360/features/settings/data/service/support_service.dart';

class ProviderUpcomingService extends StatefulWidget {
  const ProviderUpcomingService({required this.booking, super.key});
  final Bookings booking;
  @override
  State<ProviderUpcomingService> createState() =>
      _ProviderUpcomingServiceState();
}

class _ProviderUpcomingServiceState extends State<ProviderUpcomingService> {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final serviceRequestId = widget.booking.id;
    final isProgress =
        widget.booking.status?.toUpperCase() ==
        BookingEnums.progress.name.toUpperCase();

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) async {
        if (state is BookingStarted) {
          await showSuccessSnackbar(context, 'Service has started');
        }

        if (state is BookingArrived) {
          await showSuccessSnackbar(context, 'Provider arrival confirmed');
        }
      },
      child: Col(
        children: [
          UrbText(
            'Current Service',
            size: 18,
            weight: FontWeight.w700,
            color: appColors.black,
          ),
          20.verticalSpace,
          Container(
            padding: pad(horizontal: 14, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: appColors.textColor.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PictureWidget(
                      image: widget.booking.user?.profileImage ?? '',
                    ),
                    10.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            children: [
                              GenText(
                                widget.booking.user?.fullName ?? 'Unknown User',
                                height: 24.5,
                                weight: FontWeight.w500,
                                maxLines: 1,
                              ),
                              5.w.horizontalSpace,
                              GenText(
                                '(${widget.booking.serviceCategory?.name ?? 'Service'})',
                                height: 24.5,
                                weight: FontWeight.w400,
                                color: appColors.neutral.shade400,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              AppAssets.ASSETS_ICONS_LOCATION_SVG.svgColor(
                                color: appColors.neutral.shade400,
                              ),
                              2.horizontalSpace,
                              Expanded(
                                child: GenText(
                                  widget.booking.distanceKM != null
                                      ? '${widget.booking.distanceKM!.toStringAsFixed(2)} km away'
                                      : 'Distance unknown',
                                  height: 24.5,
                                  weight: FontWeight.w400,
                                  color: appColors.neutral.shade400,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                10.verticalSpace,
                // if (isAssigned || isArrived)
                //   Row(
                //     children: [
                //       Expanded(
                //         child: WideButton(
                //           label: 'Cancel',
                //           backgroundColor: appColors.primary.shade50,
                //           textColor: appColors.primary.shade500,
                //           onPressed: () async {
                //             if (serviceRequestId == null) return;
                //             await pushScreen(
                //               context,
                //               CancelClientServiceScreen(
                //                 serviceRequestId: serviceRequestId,
                //               ),
                //             );
                //             if (context.mounted) {
                //               context.read<ServiceDetailBloc>().add(
                //                 const RefreshServiceDetail(),
                //               );
                //             }
                //           },
                //         ),
                //       ),
                //       12.horizontalSpace,
                //       Expanded(
                //         child: WideButton(
                //           label: isAssigned ? 'Mark Arrived' : 'Start Service',
                //           backgroundColor: appColors.primary.shade500,
                //           textColor: appColors.whiteColor,
                //           onPressed: () async {
                //             if (isAssigned) {
                //               if (serviceRequestId != null) {
                //                 context.read<BookingBloc>().add(
                //                   ArriveBooking(
                //                     serviceRequestId: serviceRequestId,
                //                   ),
                //                 );
                //               }
                //             } else if (isArrived) {
                //               if (serviceRequestId != null) {
                //                 context.read<BookingBloc>().add(
                //                   StartBooking(
                //                     serviceRequestId: serviceRequestId,
                //                   ),
                //                 );
                //               }
                //             }
                //           },
                //         ),
                //       ),
                //     ],
                //   ),
                if (isProgress)
                  Row(
                    children: [
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
                  ),
              ],
            ),
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
