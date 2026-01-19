import 'package:resq360/__lib.dart';
import 'package:resq360/core/bloc/booking_bloc/booking_bloc.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/advertisement_bloc/customer_advertisement_bloc.dart';
import 'package:resq360/features/customer/dashboard/screens/notification_screen.dart';
import 'package:resq360/features/provider/authentication/data/models/provider_response.dart';
import 'package:resq360/features/provider/bookings/data/bloc/provider_service_bloc.dart';
import 'package:resq360/features/provider/bookings/data/models/booking_enums.dart';
import 'package:resq360/features/provider/dashboard/screens/promote_service_screen.dart';
import 'package:resq360/features/provider/dashboard/screens/provider_wallet_screen.dart';
import 'package:resq360/features/provider/dashboard/widgets/advertisement_countdown_timer.dart';
import 'package:resq360/features/provider/dashboard/widgets/provider_account_progress.dart';
import 'package:resq360/features/provider/dashboard/widgets/provider_ongoing_service.dart';
import 'package:resq360/features/provider/dashboard/widgets/provider_stats_card.dart';
import 'package:resq360/features/provider/dashboard/widgets/provider_todo.dart';
import 'package:resq360/features/provider/dashboard/widgets/service_requests.dart';
import 'package:resq360/features/settings/screens/settings_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

String revenue = '-';
bool isAproved = false;
bool profileNotDone = false;
ProviderModel? providerData;

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int? providerId;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeProvider();
      context.read<ProviderServiceBloc>().add(
        ProviderFetchBookings(
          status: BookingStatus.ongoing.value,
        ),
      );
    });
  }

  Future<void> _initializeProvider() async {
    final provider = await AuthLocalRepo.instance.getProviderAuthCredentials();
    if (provider?.id != null) {
      setState(() {
        providerId = provider!.id;
      });
      context.read<CustomerAdvertisementBloc>().add(
        FetchProviderActiveAdvertisements(providerId: provider!.id!),
      );
    }
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
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: colors.whiteColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: FutureBuilder<ProviderModel?>(
            future: AuthLocalRepo.instance.getProviderAuthCredentials(),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.hasError) {
                return Center(child: Text('Error: ${asyncSnapshot.error}'));
              }

              if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                return const Center(child: Text('No user found'));
              }
              providerData = asyncSnapshot.data;
              final provider = asyncSnapshot.data!;
              final fullName = provider.fullName?.trim();
              final address = provider.address?.city ?? 'N/A';
              final balance = provider.wallet?.balance.toString();
              final description = provider.description;
              final profileImage = provider.profileImage ?? '';

              if (balance != null) {
                revenue = balance;
              }
              final kyc = provider.kycStatus;
              if (kyc == 'APPROVED') {
                isAproved = true;
              } else {
                isAproved = false;
              }

              profileNotDone = false;

              if (description == null || description.trim().isEmpty) {
                profileNotDone = true;
              }

              if (profileImage.trim().isEmpty) {
                profileNotDone = true;
              }

              log('provider dashboard $fullName');
              return _buildHeader(context, fullName!, address, profileImage);
            },
          ),
          actions: [
            IconButton(
              icon: AppAssets.ASSETS_ICONS_WALLET_SVG.svg,
              onPressed: () async {
                await pushScreen(context, const ProviderWalletScreen());
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
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<ProviderServiceBloc>().add(
              ProviderFetchBookings(
                status: BookingStatus.ongoing.value,
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
                  BlocBuilder<ProviderServiceBloc, ProviderServiceState>(
                    builder: (context, state) {
                      // if (state is ProviderServicesLoading) {
                      //  return  Center(child: CircularProgressIndicator(
                      //  color: appColors.primary,

                      // ));
                      // }

                      if (state is ProviderServicesError) {
                        const ProviderStatsCard(
                          title: 'Engagement',
                          value: '-',
                          icon: AppAssets.ASSETS_ICONS_ENGAGEMENT_ICON_SVG,
                        );
                      }

                      if (state is ProviderBookingsLoaded) {
                        final bookings = state.bookings;
                        return ProviderStatsCard(
                          title: 'Engagement',
                          value: bookings.length.toString(),
                          icon: AppAssets.ASSETS_ICONS_ENGAGEMENT_ICON_SVG,
                        );
                      }
                      return const ProviderStatsCard(
                        title: 'Engagement',
                        value: '-',
                        icon: AppAssets.ASSETS_ICONS_ENGAGEMENT_ICON_SVG,
                      );
                    },
                  ),

                  16.horizontalSpace,
                  ProviderStatsCard(
                    title: 'Revenue',
                    value: revenue,
                    icon: AppAssets.ASSETS_ICONS_REVENUE_ICON_SVG,
                  ),
                ],
              ),
              20.verticalSpace,
              if (!isAproved) ...[
                if (providerData != null)
                  ProviderAccountProgress(
                    provider: providerData!,
                  ),
              ],

              if (profileNotDone) ...[
                if (providerData != null)
                  GestureDetector(
                    onTap: () => pushScreen(context, const SettingsScreen()),
                    child: ToDoSection(
                      provider: providerData!,
                    ),
                  ),
                30.verticalSpace,
              ],

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
                      return ProviderOngoingService(
                        booking: booking,
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
              30.verticalSpace,
              BlocBuilder<
                CustomerAdvertisementBloc,
                CustomerAdvertisementState
              >(
                builder: (context, state) {
                  if (state is ProviderActiveAdvertisementsFetched) {
                    final activeAds = state.advertisements;
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
              30.verticalSpace,
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
                        await pushScreen(context, const PromoteServiceScreen());

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
              20.verticalSpace,
              Container(
                padding: pad(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.primary.shade500),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GenText(
                        'Boost your visibility and attract more clients with our 10% off promotion package. Don’t miss this chance to grow your business',
                        size: 12,
                        height: 20.5,
                        color: colors.black,
                      ),
                    ),
                    8.horizontalSpace,
                    AppAssets.ASSETS_IMAGES_SPEAKER_ICON_PNG.imageAsset(
                      width: 120.w,
                      height: 80.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildHeader(
  BuildContext context,
  String name,
  String address,
  String profileImage,
) {
  final colors = context.appColors;
  return Row(
    children: [
      GestureDetector(
        onTap: () async {
          await pushScreen(context, const SettingsScreen());
        },
        child: PictureWidget(
          image: profileImage,
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
              SizedBox(
                width: address.length > 10 ? 140.w : 30.w,
                child: GenText(
                  address,
                  height: 24,
                  color: colors.black,
                  weight: FontWeight.w500,
                ),
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
