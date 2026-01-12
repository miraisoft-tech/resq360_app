import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/service_catalog_bloc/service_catalog_bloc.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/utils/app_gen_utils.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/customer_user_model.dart';
import 'package:resq360/features/customer/bookings/data/bloc/customer_booking_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/advertisement_bloc/customer_advertisement_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';
import 'package:resq360/features/customer/dashboard/screens/notification_screen.dart';
import 'package:resq360/features/customer/dashboard/screens/wallet_screen.dart';
import 'package:resq360/features/customer/dashboard/widgets/ongoing_service_widget.dart';
import 'package:resq360/features/customer/dashboard/widgets/recommended_card_widget.dart';
import 'package:resq360/features/customer/dashboard/widgets/service_category_widget.dart';
import 'package:resq360/features/customer/services/screens/service_categories_screen.dart';
import 'package:resq360/features/customer/services/screens/service_provider_details_screen.dart';
import 'package:resq360/features/customer/services/screens/service_providers_screen.dart';
import 'package:resq360/features/provider/bookings/data/models/booking_enums.dart';
import 'package:resq360/features/settings/screens/settings_screen.dart';
import 'package:resq360/features/widgets/inputs/filter_search_field.dart';
import 'package:resq360/features/widgets/promo_card_widget.dart';

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
        FetchCustomerBookings(status: BookingStatus.pending.value),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      body: SafeArea(
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
              FetchCustomerBookings(status: BookingStatus.pending.value),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<CustomerAuthBloc, CustomerAuthState>(
                    builder: (context, state) {
                      if (state is CustomerAuthLoginSuccess) {
                        final user = state.user;
                        return HeaderWidget(
                          name: user.fullName?.capitalize ?? 'user',
                          location: 'N/A',
                        );
                      }

                      return FutureBuilder<CustomerUserModel?>(
                        future: AuthLocalRepo.instance.getAuthCredentials(),
                        builder: (context, snapshot) {
                          final userName = snapshot.data?.fullName ?? 'user';
                          return HeaderWidget(
                            name: userName.capitalize,
                            location: 'N/A',
                          );
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
              10.verticalSpace,
              FilterSearchFormField(
                controller: TextEditingController(),
                hintText: 'Search for services',
                onTapSuffix: () {},
                onChanged: (value) {},
                onTap: () async {
                  await AppGenUtil.offKeyboard();

                  await pushScreen(context, const ServiceCategoryScreen());
                },
                prefixIconPath: AppAssets.ASSETS_ICONS_SEARCH_SVG,
              ),
              20.verticalSpace,
              const PromoCardWidget(),
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
                    return  Center(child: CircularProgressIndicator(
                       color: colors.primary,

                    ));
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
                      await pushScreen(context, const ServiceCategoryScreen());
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
                   return  Center(child: CircularProgressIndicator(
                       color: colors.primary,

                    ));
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
                  // GestureDetector(
                  //   onTap: () async {
                  //     // await pushScreen(context, const ServiceProvidersScreen(serviceProviderId: null,));
                  //   },
                  //   child: UrbText(
                  //     'View All',
                  //     size: 12,
                  //     height: 20.5,
                  //     weight: FontWeight.w400,
                  //     color: colors.primary.shade500,
                  //   ),
                  // ),
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

                    return AdvertisementCarousel(ads: ads);
                  }

                  if (state is CustomerAdvertisementError) {
                    return ErrorMessageAndButton(
                      error: state.error,
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
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({required this.name, required this.location, super.key});

  final String name;
  final String location;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            await pushScreen(context, const SettingsScreen());
          },
          child: const CircleAvatar(
            radius: 19,
            backgroundImage: AssetImage(
              AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
            ),
          ),
        ),
        10.horizontalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GenText(
              'Hello, $name 👋',
              size: 12,
              height: 20,
              weight: FontWeight.w400,
              color: colors.neutral.shade500,
            ),
            Row(
              children: [
                AppAssets.ASSETS_ICONS_LOCATION_SVG.svg,
                4.horizontalSpace,
                GenText(
                  location,
                  height: 24,
                  color: colors.black,
                  weight: FontWeight.w500,
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 14,
                  color: colors.textColor.shade500,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class AdvertisementCarousel extends StatefulWidget {
  const AdvertisementCarousel({required this.ads, super.key});
  final List<Advertisement> ads;

  @override
  State<AdvertisementCarousel> createState() => _AdvertisementCarouselState();
}

class _AdvertisementCarouselState extends State<AdvertisementCarousel> {
  late final PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);

    _pageController.addListener(() {
      final newIndex = _pageController.page?.round() ?? 0;

      if (newIndex != currentIndex) {
        setState(() => currentIndex = newIndex);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 165.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.ads.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  final providerId = widget.ads[index].providerId;
                  if (providerId == null) return;
                  await pushScreen(
                    context,
                    ServiceProviderDetailsScreen( providerId: providerId,),
                  );
                },
                child: RecommendedCard(advertisement: widget.ads[index]),
              );
            },
          ),
        ),
        5.verticalSpace,
        SmallDotIndicator(
          total: widget.ads.length,
          currentIndex: currentIndex,
        ),
      ],
    );
  }
}
