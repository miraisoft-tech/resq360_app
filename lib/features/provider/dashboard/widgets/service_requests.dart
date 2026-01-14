import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/provider/bookings/data/bloc/provider_service_bloc.dart';
import 'package:resq360/features/provider/bookings/data/models/booking_enums.dart';
import 'package:resq360/features/provider/bookings/screens/bookings_screen.dart';
import 'package:resq360/features/provider/dashboard/screens/customer_details_screen.dart';

class ServiceRequests extends StatefulWidget {
  const ServiceRequests({super.key});

  @override
  State<ServiceRequests> createState() => _ServiceRequestsState();
}

class _ServiceRequestsState extends State<ServiceRequests> {
  @override
  void initState() {
    super.initState();

    context.read<ProviderServiceBloc>().add(
      ProviderFetchBookings(status: BookingStatus.upcoming.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocBuilder<ProviderServiceBloc, ProviderServiceState>(
      builder: (context, state) {
        if (state is ProviderBookingsLoaded) {
          final bookings = state.bookings;
          if (bookings.isEmpty) {
            return const Center(child: GenText('No bookings found.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UrbText(
                    'Service Requests',
                    size: 18,
                    weight: FontWeight.w700,
                    color: colors.black,
                  ),
                  // 4.horizontalSpace,
                  // Container(
                  //   padding: pad(horizontal: 6, vertical: 2),
                  //   decoration: BoxDecoration(
                  //     color: colors.error.shade50,
                  //     borderRadius: BorderRadius.circular(10.r),
                  //   ),
                  //   child: GenText(
                  //     '4 new',
                  //     size: 11,
                  //     color: colors.error.shade500,
                  //   ),
                  // ),
                  const Spacer(),
                  GestureDetector(
                    onTap:
                        () =>
                            pushScreen(context, const ProviderBookingsScreen()),
                    child: GenText(
                      'View All',
                      size: 13,
                      color: colors.primary.shade500,
                    ),
                  ),
                ],
              ),
              20.verticalSpace,
              ...state.bookings.map(
                (booking) => _RequestTile(
                  name: booking.user?.fullName ?? 'Unknown User',
                  service: booking.serviceCategory?.name ?? 'Unknown Service',
                  distance: '1.0 km Away',
                  user: booking.user,
                ),
              ),

              // const _RequestTile(
              //   name: 'Jane Doe',
              //   service: 'Tow request',
              //   distance: '1.0 km Away',
              // ),
              // const _RequestTile(
              //   name: 'John Paul',
              //   service: 'Mechanic service',
              //   distance: '1.4 km Away',
              // ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.name,
    required this.service,
    required this.distance,
    required this.user,
  });

  final String name;
  final String service;
  final String distance;
  final User? user;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: () async {
        if (user != null) {
          await pushScreen(context,  CustomerDetailsScreen(user: user!,));
        }
      },
      child: Container(
        padding: pad(horizontal: 12, vertical: 20),
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: colors.textColor.shade100),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            const PictureWidget(),
            10.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GenText(name, weight: FontWeight.w400),
                    4.horizontalSpace,
                    GenText(
                      '($service)',
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
                    4.horizontalSpace,
                    GenText(
                      distance,
                      size: 12,
                      weight: FontWeight.w400,
                      color: colors.neutral.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
