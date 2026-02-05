import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/core/models/booking_enums.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/provider/bookings/screens/cancel_client_service_screen.dart';

class ProviderOngoingService extends StatefulWidget {
  const ProviderOngoingService({required this.booking, super.key});
  final Bookings booking;
  @override
  State<ProviderOngoingService> createState() => _ProviderOngoingServiceState();
}

class _ProviderOngoingServiceState extends State<ProviderOngoingService> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final serviceRequestId = widget.booking.id;

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) async {
        if (state is BookingStarted) {
          await showSuccessSnackbar(context, 'Service has started');
        }
      },
      child: Col(
        children: [
          UrbText(
            'Ongoing Service',
            size: 18,
            weight: FontWeight.w700,
            color: colors.black,
          ),
          20.verticalSpace,
          Container(
            padding: pad(horizontal: 14, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: colors.textColor.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Align(
                //   alignment: Alignment.topRight,
                //   child: Icon(
                //     Icons.close,
                //     color: colors.textColor.shade400,
                //     size: 20,
                //   ),
                // ),
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
                          Row(
                            children: [
                              Expanded(
                                child: GenText(
                                  widget.booking.user?.fullName ??
                                      'Unknown User',
                                  height: 24.5,
                                  weight: FontWeight.w500,
                                  maxLines: 1,
                                ),
                              ),
                              Expanded(
                                child: GenText(
                                  ' (${widget.booking.serviceCategory?.name ?? 'Service'})',
                                  height: 24.5,
                                  weight: FontWeight.w400,
                                  color: colors.neutral.shade400,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              AppAssets.ASSETS_ICONS_LOCATION_SVG.svgColor(
                                color: colors.neutral.shade400,
                              ),
                              2.horizontalSpace,
                              Expanded(
                                child: GenText(
                                  'Unknown location',
                                  height: 24.5,
                                  weight: FontWeight.w400,
                                  color: colors.neutral.shade400,
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: pad(horizontal: 14),
                          elevation: 0,
                          backgroundColor: colors.error.shade50,
                          foregroundColor: colors.primary.shade500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: () async {
                          if (serviceRequestId != null) {
                            await pushScreen(
                              context,
                              CancelSlientServiceScreen(
                                serviceRequestId: serviceRequestId,
                              ),
                            );
                          }
                        },
                        child: GenText(
                          'Cancel',
                          height: 16.5,
                          color: colors.primary.shade500,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.booking.status?.toUpperCase() ==
                        BookingEnums.progress.name)
                      20.horizontalSpace,
                    Expanded(
                      child: BlocBuilder<BookingBloc, BookingState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed:
                                state is BookingLoading
                                    ? null
                                    : () {
                                      log(serviceRequestId);
                                      if (serviceRequestId != null) {
                                        context.read<BookingBloc>().add(
                                          StartBooking(
                                            serviceRequestId: serviceRequestId,
                                          ),
                                        );
                                      }
                                    },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                    (states) {
                                      return colors.primary.shade500;
                                    },
                                  ),
                              foregroundColor: WidgetStateProperty.all(
                                colors.whiteColor,
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                            child:
                                state is BookingLoading
                                    ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.whiteColor,
                                      ),
                                    )
                                    : GenText(
                                      'Start Service',
                                      height: 16.5,
                                      color: colors.whiteColor,
                                      weight: FontWeight.w500,
                                    ),
                          );
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
}
