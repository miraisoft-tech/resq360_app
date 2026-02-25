import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/core/services/notification_service.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/advertisement_bloc/customer_advertisement_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/promotion_bloc/promotion_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/creator_type.enum.dart';
import 'package:resq360/features/customer/dashboard/screens/notification_screen.dart';
import 'package:resq360/features/provider/authentication/data/bloc/provider_auth_bloc.dart';
import 'package:resq360/features/provider/authentication/data/models/provider_response.dart';
import 'package:resq360/features/provider/bookings/data/bloc/provider_service_bloc.dart';
import 'package:resq360/features/provider/bookings/data/models/booking_enums.dart';
import 'package:resq360/features/provider/bookings/screens/client_service_details_screen.dart';
import 'package:resq360/features/provider/dashboard/screens/promote_service_screen.dart';
import 'package:resq360/features/provider/dashboard/screens/provider_wallet_screen.dart';
import 'package:resq360/features/provider/dashboard/widgets/advertisement_countdown_timer.dart';
import 'package:resq360/features/provider/dashboard/widgets/provider_account_progress.dart';
import 'package:resq360/features/provider/dashboard/widgets/provider_ongoing_service.dart';
import 'package:resq360/features/provider/dashboard/widgets/provider_stats_card.dart';
import 'package:resq360/features/provider/dashboard/widgets/provider_todo.dart';
import 'package:resq360/features/provider/dashboard/widgets/service_requests.dart';
import 'package:resq360/features/settings/screens/address_screen.dart';
import 'package:resq360/features/settings/screens/settings_screen.dart';
import 'package:resq360/features/widgets/header_widget.dart';
import 'package:resq360/features/widgets/promo_card_widget.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

String revenue = '-';
bool isApproved = false;
bool profileNotDone = false;
ProviderModel? providerData;
int _unreadCount = 0;

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  // int? providerId;
  @override
  void initState() {
    super.initState();
    unawaited(_initDashboard());
  }

  Future<void> _initDashboard() async {
    final unreadCount =
        await NotificationRepo.instance.getUnreadNotificationCount();

    if (!mounted) return;
    setState(() {
      _unreadCount = unreadCount;
    });

    context.read<ProviderAuthBloc>().add(
      const ProvidergetProviderProfile(),
    );

    context.read<CustomerAdvertisementBloc>().add(
      CustomerFetchAdvertisement(creatorType: CreatorType.admin.name),
    );

    context.read<ProviderServiceBloc>().add(
      ProviderFetchBookings(
        status: BookingStatus.ongoing.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) async {
        if (state is BookingStarted) {
          await showSuccessSnackbar(
            context,
            'Service started successfully',
          );
          context.read<ProviderServiceBloc>().add(
            ProviderFetchBookings(
              status: BookingStatus.ongoing.value,
            ),
          );
        }
        if (state is BookingError) {
          await showErrorSnackbar(context, state.error);
        }
      },
      child: Scaffold(
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
                    BlocBuilder<ProviderAuthBloc, ProviderAuthState>(
                      buildWhen: (previous, current) {
                        return !(previous is ProviderProfileLoadedState &&
                            current is ProviderAuthLoadingState);
                      },
                      builder: (context, v) {
                        final user =
                            v is ProviderProfileLoadedState ? v.user : null;
                        providerData = user;
                        isApproved = providerData?.isApproved ?? false;
                        if (providerData != null) {
                          final providerId = providerData!.id;
                          if (providerId != null) {
                            context.read<PromotionBloc>().add(
                              FetchActivePromotions(providerId),
                            );
                          }
                        }
                        // final profileNotDone =
                        //     !(providerData?.isEmailVerified == true &&
                        //         providerData?.isApproved == true &&
                        //         providerData?.isKYCVerified == true &&
                        //         (providerData?.providerServices?.isNotEmpty ??
                        //             false) &&
                        //         providerData?.address != null &&
                        //         (providerData?.openingHours != null &&
                        //             providerData?.closingHours != null));

                        return HeaderWidget(
                          name: user?.fullName?.capitalize ?? 'N/A',
                          address: user?.address?.address ?? 'N/A',
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
                        await pushScreen(context, const ProviderWalletScreen());
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
                                  borderRadius:
                                      BorderRadiusDirectional.circular(
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
                        await pushScreen(context, const NotificationScreen());
                      },
                    ),
                    10.horizontalSpace,
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProviderAuthBloc>().add(
                      const ProvidergetProviderProfile(),
                    );

                    context.read<ProviderServiceBloc>().add(
                      ProviderFetchBookings(
                        status: BookingStatus.ongoing.value,
                      ),
                    );
                    context.read<CustomerAdvertisementBloc>().add(
                      CustomerFetchAdvertisement(
                        creatorType: CreatorType.admin.name,
                      ),
                    );
                  },

                  color: colors.primary.shade500,
                  child: ListView(
                    padding: EdgeInsets.only(
                      top: 20.h,
                      left: 16.w,
                      right: 16.w,
                      bottom: 100.h,
                    ),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BlocBuilder<
                            ProviderServiceBloc,
                            ProviderServiceState
                          >(
                            builder: (context, state) {
                              if (state is ProviderServicesError) {
                                const ProviderStatsCard(
                                  title: 'Engagement',
                                  value: '-',
                                  icon:
                                      AppAssets
                                          .ASSETS_ICONS_ENGAGEMENT_ICON_SVG,
                                );
                              }

                              if (state is ProviderBookingsLoaded) {
                                final bookings = state.bookings;
                                return ProviderStatsCard(
                                  title: 'Engagement',
                                  value: bookings.length.toString(),
                                  icon:
                                      AppAssets
                                          .ASSETS_ICONS_ENGAGEMENT_ICON_SVG,
                                );
                              }
                              return const ProviderStatsCard(
                                title: 'Engagement',
                                value: '-',
                                icon:
                                    AppAssets.ASSETS_ICONS_ENGAGEMENT_ICON_SVG,
                              );
                            },
                          ),

                          16.horizontalSpace,
                          BlocBuilder<ProviderAuthBloc, ProviderAuthState>(
                            builder: (context, state) {
                              final revenue =
                                  state is ProviderProfileLoadedState
                                      ? state.user.wallet?.availableBalance
                                              ?.toString() ??
                                          '-'
                                      : '-';
                              return ProviderStatsCard(
                                title: 'Revenue',
                                value: '₦${AppTextUtil.formatAmount(revenue)}',
                                icon: AppAssets.ASSETS_ICONS_REVENUE_ICON_SVG,
                              );
                            },
                          ),
                        ],
                      ),
                      20.verticalSpace,
                      BlocBuilder<ProviderAuthBloc, ProviderAuthState>(
                        builder: (context, authState) {
                          if (authState is ProviderProfileLoadedState) {
                            final provider = authState.user;

                            // final progress = calculateProviderProgress(
                            //   provider,
                            // );

                            final isProfileComplete = isProviderProfileComplete(
                              provider,
                            );

                            return Column(
                              children: [
                                if (!isProfileComplete) ...[
                                  ProviderAccountProgress(provider: provider),
                                  20.verticalSpace,
                                ],

                                if (!isProfileComplete) ...[
                                  GestureDetector(
                                    onTap:
                                        () => pushScreen(
                                          context,
                                          const SettingsScreen(),
                                        ),
                                    child: ToDoSection(provider: provider),
                                  ),
                                  30.verticalSpace,
                                ],
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const PromoCardWidget(),
                      30.verticalSpace,
                      BlocBuilder<ProviderServiceBloc, ProviderServiceState>(
                        builder: (context, state) {
                          if (state is ProviderServicesLoading) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: colors.primary,
                              ),
                            );
                          }
                          if (state is ProviderBookingsLoaded) {
                            final booking = state.bookings.firstOrNull;
                            final serviceRequestId = booking?.id;
                            if (serviceRequestId == null) {
                              return const SizedBox.shrink();
                            }
                            if (booking != null) {
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await pushScreen(
                                        context,
                                        ProviderServiceDetailScreen(
                                          booking: booking,
                                        ),
                                      );
                                    },
                                    child: ProviderOngoingService(
                                      booking: booking,
                                    ),
                                  ),
                                  20.verticalSpace,
                                ],
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      BlocBuilder<PromotionBloc, PromotionState>(
                        builder: (context, state) {
                          if (state is ActivePromotionsFetched) {
                            final activeAds = state.promotions;
                            if (activeAds.isNotEmpty &&
                                activeAds.first.endDate != null) {
                              return Column(
                                children: [
                                  AdvertCountdownTimer(
                                    endDate: activeAds.first.endDate!,
                                  ),
                                  30.verticalSpace,
                                ],
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const ServiceRequests(),
                      20.verticalSpace,
                      Container(
                        padding: pad(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: colors.error.shade50,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GenText(
                              'You can reach more clients if you promote your page, your page will be displayed to all clients for 24hrs.',
                              height: 24.5,
                              color: colors.black,
                            ),
                            10.verticalSpace,
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary.shade500,
                                padding: pad(horizontal: 14, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              onPressed: () async {
                                await pushScreen(
                                  context,
                                  const PromoteServiceScreen(),
                                );

                                // await GeneralDialogs.showCustomDialog<void>(
                                //   context,
                                //   body: const ServiceRequestNotification(),
                                // );
                              },
                              child: const GenText(
                                'Promote Page',
                                color: Colors.white,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 20.verticalSpace,
                      // GestureDetector(
                      //   onTap: () async {
                      //     await pushScreen(
                      //       context,
                      //       const PromoteServiceScreen(),
                      //     );
                      //   },
                      //   child: Container(
                      //     padding: pad(horizontal: 16, vertical: 14),
                      //     decoration: BoxDecoration(
                      //       border: Border.all(color: colors.primary.shade500),
                      //       borderRadius: BorderRadius.circular(12.r),
                      //     ),
                      //     child: Row(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Expanded(
                      //           child: GenText(
                      //             'Boost your visibility and attract more clients with our 10% off promotion package. Don’t miss this chance to grow your business',
                      //             size: 12,
                      //             height: 20.5,
                      //             color: colors.black,
                      //           ),
                      //         ),
                      //         8.horizontalSpace,
                      //         AppAssets.ASSETS_IMAGES_SPEAKER_ICON_PNG
                      //             .imageAsset(
                      //               width: 120.w,
                      //               height: 80.h,
                      //               fit: BoxFit.contain,
                      //             ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isProviderProfileComplete(ProviderModel provider) {
    final hasProfileImage =
        provider.profileImage != null &&
        provider.profileImage!.trim().isNotEmpty;

    final hasServices = provider.providerServices?.isNotEmpty ?? false;

    final hasDescription =
        provider.description != null && provider.description!.trim().isNotEmpty;

    final hasAddress = provider.address != null;

    final hasWorkingHours =
        provider.openingHours != null && provider.closingHours != null;

    final kycApproved =
        provider.isKYCVerified ||
        provider.kycStatus?.toUpperCase() == 'APPROVED';

    return hasProfileImage &&
        hasServices &&
        hasDescription &&
        hasAddress &&
        hasWorkingHours &&
        kycApproved;
  }
}
