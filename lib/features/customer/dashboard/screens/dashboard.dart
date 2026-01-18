import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/service_catalog_bloc/service_catalog_bloc.dart';
import 'package:resq360/core/utils/app_gen_utils.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/bookings/data/bloc/customer_booking_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/advertisement_bloc/customer_advertisement_bloc.dart';
import 'package:resq360/features/customer/dashboard/screens/advertisement_screen.dart';
import 'package:resq360/features/customer/dashboard/screens/notification_screen.dart';
import 'package:resq360/features/customer/dashboard/screens/wallet_screen.dart';
import 'package:resq360/features/customer/dashboard/widgets/advertisment_carousel.dart';
import 'package:resq360/features/customer/dashboard/widgets/header_widget.dart';
import 'package:resq360/features/customer/dashboard/widgets/ongoing_service_widget.dart';
import 'package:resq360/features/customer/dashboard/widgets/service_category_widget.dart';
import 'package:resq360/features/customer/services/screens/service_categories_screen.dart';
import 'package:resq360/features/customer/services/screens/service_providers_screen.dart';
import 'package:resq360/features/provider/bookings/data/models/booking_enums.dart';
import 'package:resq360/features/settings/screens/address_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceCatalogBloc>().add(const FetchServices());
      context.read<CustomerAdvertisementBloc>().add(
        CustomerFetchAdvertisement(),
      );
      context.read<CustomerBookingBloc>().add(
        FetchCustomerBookings(status: BookingStatus.ongoing.value),
      );
      context.read<CustomerAuthBloc>().add(
        const CustomergetUserProfile(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 10.h,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<CustomerAuthBloc, CustomerAuthState>(
                    buildWhen: (previous, current) {
                      return !(previous is CustomerProfileLoaded &&
                          current is CustomerAuthLoading);
                    },
                    builder: (context, v) {
                      final user = v is CustomerProfileLoaded ? v.user : null;
                      return HeaderWidget(
                        name: user?.fullName?.capitalize ?? 'N/A',
                        address: user?.location?.firstOrNull?.address ?? 'N/A',
                        profileImage: user?.profileImage ?? '',
                        onTapAddress: () async {
                          await pushScreen(context, const AddressScreen());
                        },
                      );
                    },
                  ),

                  const Spacer(),
                  IconButton(
                    icon: AppAssets.ASSETS_ICONS_WALLET_SVG.svg,
                    onPressed: () async {
                      await pushScreen(context, const WalletScreen());
                    },
                  ),
                  IconButton(
                    icon: AppAssets.ASSETS_ICONS_NOTIFICATION_SVG.svg,
                    onPressed: () async {
                      await pushScreen(context, const NotificationScreen());
                    },
                  ),
                  10.horizontalSpace,
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: colors.primary,
                onRefresh: () async {
                  context.read<CustomerAuthBloc>().add(
                    const CustomergetUserProfile(),
                  );

                  context.read<ServiceCatalogBloc>().add(const FetchServices());
                  context.read<CustomerAdvertisementBloc>().add(
                    CustomerFetchAdvertisement(),
                  );
                  context.read<CustomerBookingBloc>().add(
                    FetchCustomerBookings(status: BookingStatus.ongoing.value),
                  );
                },
                child: ListView(
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 10.h,
                    bottom: 50.h,
                  ),
                  children: [
                    10.verticalSpace,
                    GestureDetector(
                      onTap: () async {
                        await AppGenUtil.offKeyboard();

                        await pushScreen(
                          context,
                          const ServiceCategoryScreen(),
                        );
                      },
                      child: Container(
                        padding: pad(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: colors.neutral.shade100),
                        ),
                        child: Row(
                          children: [
                            AppAssets.ASSETS_ICONS_SEARCH_SVG.svg,
                            20.horizontalSpace,
                            GenText(
                              'Search for services',
                              color: colors.neutral.shade300,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 20.verticalSpace,
                    // const PromoCardWidget(),
                    20.verticalSpace,
                    UrbText(
                      'Ongoing Service',
                      size: 18,
                      height: 28.5,
                      weight: FontWeight.w700,
                      color: colors.black,
                    ),
                    12.verticalSpace,
                    BlocBuilder<CustomerBookingBloc, CustomerBookingState>(
                      builder: (context, state) {
                        if (state is CustomerBookingLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: colors.primary,
                            ),
                          );
                        }

                        if (state is CustomerBookingLoaded) {
                          if (state.bookings.isEmpty) {
                            return const GenText('No ongoing service');
                          }

                          if (state.bookings.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final ongoingBooking = state.bookings.first;

                          return OngoingServiceCard(
                            booking: ongoingBooking,
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                    20.verticalSpace,
                    Row(
                      children: [
                        UrbText(
                          'What service do you need?',
                          size: 18,
                          height: 28.5,
                          weight: FontWeight.w700,
                          color: colors.black,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            await pushScreen(
                              context,
                              const ServiceCategoryScreen(),
                            );
                          },
                          child: UrbText(
                            'View All',
                            size: 12,
                            height: 20.5,
                            weight: FontWeight.w400,
                            color: colors.primary.shade500,
                          ),
                        ),
                      ],
                    ),
                    20.verticalSpace,
                    BlocBuilder<ServiceCatalogBloc, ServiceCatalogState>(
                      builder: (context, state) {
                        if (state is ServiceCatalogLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: colors.primary,
                            ),
                          );
                        }

                        if (state is ServicesLoaded) {
                          final categories = state.services;

                          return SizedBox(
                            height: 130,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              separatorBuilder: (_, _) => 12.horizontalSpace,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return ServiceCategoryWidget(
                                  category: category,
                                  onTap: () async {
                                    await pushScreen(
                                      context,
                                      ServiceProvidersScreen(
                                        serviceProviderId: category.id,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        }

                        if (state is ServiceCatalogError) {
                          return Center(child: Text(state.error));
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                    30.verticalSpace,
                    Row(
                      children: [
                        UrbText(
                          'Recommended for You',
                          size: 18,
                          height: 28.5,
                          weight: FontWeight.w700,
                          color: colors.black,
                        ),
                        const Spacer(),

                        GestureDetector(
                          onTap: () async {
                            final state =
                                context.read<CustomerAdvertisementBloc>().state;

                            if (state is CustomerAdvertisementFetched) {
                              await pushScreen(
                                context,
                                RecommendedListScreen(
                                  advertisements: state.adverisementList,
                                ),
                              );
                            }
                          },
                          child: UrbText(
                            'View All',
                            size: 12,
                            height: 20.5,
                            weight: FontWeight.w400,
                            color: colors.primary.shade500,
                          ),
                        ),
                      ],
                    ),

                    12.verticalSpace,

                    BlocBuilder<
                      CustomerAdvertisementBloc,
                      CustomerAdvertisementState
                    >(
                      builder: (context, state) {
                        if (state is CustomerAdvertisementLoading) {
                          return const CircularProgressIndicator();
                        }

                        if (state is CustomerAdvertisementFetched) {
                          final ads = state.adverisementList;

                          if (ads.isEmpty) {
                            return const Center(
                              child: Text(
                                'No advertisements available',
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }

                          return GestureDetector(
                            onTap: () async {
                              await pushScreen(
                                context,
                                RecommendedListScreen(advertisements: ads),
                              );
                            },
                            child: AdvertisementCarousel(ads: ads),
                          );
                        }

                        if (state is CustomerAdvertisementError) {
                          return ErrorMessageAndButton(
                            error: 'No data currently available.',
                            onPressed: () {
                              context.read<CustomerAdvertisementBloc>().add(
                                CustomerFetchAdvertisement(),
                              );
                            },
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),

                    30.verticalSpace,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
