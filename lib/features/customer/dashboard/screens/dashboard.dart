import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/service_catalog_bloc/service_catalog_bloc.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/notification_service.dart';
import 'package:resq360/core/utils/app_gen_utils.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/bookings/data/bloc/customer_booking_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/advertisement_bloc/customer_advertisement_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/creator_type.enum.dart';
import 'package:resq360/features/customer/dashboard/screens/advertisement_screen.dart';
import 'package:resq360/features/customer/dashboard/screens/notification_screen.dart';
import 'package:resq360/features/customer/dashboard/screens/wallet_screen.dart';
import 'package:resq360/features/customer/dashboard/widgets/advertisment_carousel.dart';
import 'package:resq360/features/customer/dashboard/widgets/ongoing_service_widget.dart';
import 'package:resq360/features/customer/dashboard/widgets/service_category_widget.dart';
import 'package:resq360/features/customer/services/screens/service_categories_screen.dart';
import 'package:resq360/features/customer/services/screens/service_providers_screen.dart';
import 'package:resq360/features/intro/screens/select_account_type_screen.dart';
import 'package:resq360/features/main_layout_provider.dart';
import 'package:resq360/features/provider/bookings/data/models/booking_enums.dart';
import 'package:resq360/features/provider/bookings/screens/client_service_details_screen.dart';
import 'package:resq360/features/settings/screens/address_screen.dart';
import 'package:resq360/features/widgets/header_widget.dart';
import 'package:resq360/features/widgets/promo_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGuest = false;
  int _unreadCount = 0;

  String _guestAddress() {
    final place = dashboardViewModel.currentPlacemark;
    if (place == null) return 'Unknown location';
    final parts =
        [
          place.street,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((value) => value != null && value.isNotEmpty).toList();
    return parts.isEmpty ? 'Unknown location' : parts.join(', ');
  }

  @override
  void initState() {
    super.initState();
    unawaited(_initDashboard());
  }

  Future<void> _initDashboard() async {
    final isGuest = await AuthLocalRepo.instance.getGuestMode();
    // if (!_isGuest) {
    //   final unreadCount =
    //       await NotificationRepo.instance.getUnreadNotificationCount();
    //   if (!mounted) return;
    //   setState(() {
    //     _unreadCount = unreadCount;
    //   });
    // }

    if (!mounted) return;
    setState(() {
      _isGuest = isGuest;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_isGuest) {
        context.read<CustomerAuthBloc>().add(const CustomergetUserProfile());
        final unreadCount =
            await NotificationRepo.instance.getUnreadNotificationCount();
        if (!mounted) return;
        setState(() {
          _unreadCount = unreadCount;
        });
      }

      context.read<ServiceCatalogBloc>().add(const FetchServices());

      context.read<CustomerAdvertisementBloc>().add(
        const FetchProviderAdvertisements(),
      );

      context.read<CustomerAdvertisementBloc>().add(
        CustomerFetchAdvertisement(creatorType: CreatorType.admin.name),
      );

      if (!_isGuest) {
        context.read<CustomerBookingBloc>().add(
          FetchCustomerBookings(status: BookingStatus.ongoing.value),
        );
      }
    });
  }

  Future<void> _requireLogin() async {
    await showErrorSnackbar(context, 'Please log in to continue');
    await pushScreen(context, const SelectAccountTypeScreen());
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
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 10.h),
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
                      return AnimatedBuilder(
                        animation: dashboardViewModel,
                        builder: (context, _) {
                          return HeaderWidget(
                            name: user?.fullName?.capitalize ?? 'Friend',
                            address:
                                user?.location?.firstOrNull?.address ??
                                (_isGuest
                                    ? _guestAddress()
                                    : 'Unknown location'),
                            profileImage: user?.profileImage ?? '',
                            onTapAddress: () async {
                              if (_isGuest) {
                                await _requireLogin();
                                return;
                              }
                              await pushScreen(context, const AddressScreen());
                            },
                          );
                        },
                      );
                    },
                  ),

                  const Spacer(),
                  IconButton(
                    icon: AppAssets.ASSETS_ICONS_WALLET_SVG.svg,
                    onPressed: () async {
                      if (_isGuest) {
                        await _requireLogin();
                        return;
                      }
                      await pushScreen(context, const WalletScreen());
                    },
                  ),
                  IconButton(
                    icon:
                        _unreadCount > 0
                            ? AppAssets.ASSETS_ICONS_NOTIFICATION_SVG.svg
                            : Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colors.neutral.shade300,
                                ),
                                borderRadius: BorderRadiusDirectional.circular(
                                  17,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.notifications_none,
                                  color: colors.neutral.shade500,
                                  size: 17,
                                ),
                              ),
                            ),
                    onPressed: () async {
                      if (_isGuest) {
                        await _requireLogin();
                        return;
                      }
                      await pushScreen(context, const NotificationScreen());
                    },
                  ),
                  5.horizontalSpace,
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: colors.primary,
                onRefresh: () async {
                  if (!_isGuest) {
                    context.read<CustomerAuthBloc>().add(
                      const CustomergetUserProfile(),
                    );
                  }

                  context.read<ServiceCatalogBloc>().add(const FetchServices());
                  context.read<CustomerAdvertisementBloc>().add(
                    const FetchProviderAdvertisements(),
                  );

                  context.read<CustomerAdvertisementBloc>().add(
                    CustomerFetchAdvertisement(
                      creatorType: CreatorType.admin.name,
                    ),
                  );
                  if (!_isGuest) {
                    context.read<CustomerBookingBloc>().add(
                      FetchCustomerBookings(
                        status: BookingStatus.ongoing.value,
                      ),
                    );
                  }
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

                    const PromoCardWidget(),

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
                            return const SizedBox.shrink();
                          }

                          if (state.bookings.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final ongoingBooking = state.bookings.first;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              UrbText(
                                'Ongoing Service',
                                size: 18,
                                height: 28.5,
                                weight: FontWeight.w700,
                                color: colors.black,
                              ),
                              12.verticalSpace,
                              GestureDetector(
                                onTap: () async {
                                  await pushScreen(
                                    context,
                                    ProviderServiceDetailScreen(
                                      booking: ongoingBooking,
                                    ),
                                  );
                                },
                                child: OngoingServiceCard(
                                  booking: ongoingBooking,
                                ),
                              ),
                            ],
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

                            if (state is ProviderAdvertisementsFetched) {
                              final ads = state.advertisements;
                              await pushScreen(
                                context,
                                RecommendedListScreen(advertisements: ads),
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
                          return Center(
                            child: CircularProgressIndicator(
                              color: context.appColors.primary,
                            ),
                          );
                        }

                        if (state is ProviderAdvertisementsFetched) {
                          final ads = state.advertisements;

                          if (ads.isEmpty) {
                            return Padding(
                              padding: pad(horizontal: 16, vertical: 20),
                              child: const GenText(
                                'No advertisements available',
                                textAlign: TextAlign.center,
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
                            error: state.error,
                            onPressed: () {
                              context.read<CustomerAdvertisementBloc>().add(
                                const FetchProviderAdvertisements(),
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
