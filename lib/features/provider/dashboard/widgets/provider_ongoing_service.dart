import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/features/provider/bookings/data/bloc/provider_service_bloc.dart';
import 'package:resq360/features/provider/bookings/data/models/booking_enums.dart';
import 'package:resq360/features/provider/bookings/screens/cancel_client_service_screen.dart';

class ProviderOngoingService extends StatefulWidget {
  const ProviderOngoingService({super.key});

  @override
  State<ProviderOngoingService> createState() => _ProviderOngoingServiceState();
}

class _ProviderOngoingServiceState extends State<ProviderOngoingService> {
  @override
  void initState() {
    super.initState();

    context.read<ProviderServiceBloc>().add(
      ProviderFetchBookings(status: BookingStatus.pending.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Col(
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
          child: MultiBlocListener(
            listeners: [
              BlocListener<ProviderServiceBloc, ProviderServiceState>(
                listener: (context, state) async {
                  if (state is ProviderServicesError) {
                    await showErrorSnackbar(context, state.error);
                  }
                },
              ),
              BlocListener<BookingBloc, BookingState>(
                listener: (context, state) async {
                  if (state is BookingStarted) {
                    await showSuccessSnackbar(
                      context,
                      'Service started successfully',
                    );
                    context.read<ProviderServiceBloc>().add(
                      ProviderFetchBookings(
                        status: BookingStatus.pending.value,
                      ),
                    );
                  }
                },
              ),
            ],
            child: BlocBuilder<ProviderServiceBloc, ProviderServiceState>(
              builder: (context, state) {
                if (state is ProviderServicesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProviderBookingsLoaded) {
                  final booking = state.bookings.firstOrNull;
                  final serviceRequestId = booking?.id;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          Icons.close,
                          color: colors.textColor.shade400,
                          size: 20,
                        ),
                      ),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage(
                              AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
                            ),
                          ),
                          10.horizontalSpace,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GenText(
                                    booking?.user?.fullName ?? 'Unknown User',
                                    height: 24.5,
                                    weight: FontWeight.w500,
                                  ),
                                  GenText(
                                    ' (${booking?.serviceCategory?.name ?? 'Service'})',
                                    height: 24.5,
                                    weight: FontWeight.w400,
                                    color: colors.neutral.shade400,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  AppAssets.ASSETS_ICONS_LOCATION_SVG.svgColor(
                                    color: colors.neutral.shade400,
                                  ),
                                  2.horizontalSpace,
                                  GenText(
                                    'Unknown location',
                                    height: 24.5,
                                    weight: FontWeight.w400,
                                    color: colors.neutral.shade400,
                                  ),
                                ],
                              ),
                            ],
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
                          20.horizontalSpace,
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (serviceRequestId != null) {
                                  context.read<BookingBloc>().add(
                                    StartBooking(
                                      serviceRequestId: serviceRequestId,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary.shade500,
                                foregroundColor: colors.whiteColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: GenText(
                                'Start Service',
                                height: 16.5,
                                color: colors.whiteColor,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }
}
