import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/authentication/screens/login_screen.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/service_provider_bloc/service_provider_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/models/service_models/service_request.model.dart';
import 'package:resq360/features/customer/services/screens/service_provider_details_screen.dart';
import 'package:resq360/features/widgets/inputs/filter_search_field.dart';

class ServiceProvidersScreen extends StatefulWidget {
  const ServiceProvidersScreen({required this.serviceProviderId, super.key});

  final int serviceProviderId;
  @override
  State<ServiceProvidersScreen> createState() => _ServiceProvidersScreenState();
}

class _ServiceProvidersScreenState extends State<ServiceProvidersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _sortByProximity = false;
  bool _isGuest = false;

  final TextEditingController _searchController = TextEditingController();

  List<ServiceProvider> providers = [];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    unawaited(_loadGuestMode());

    context.read<ServiceProviderBloc>().add(
      FetchServiceProviders(
        categoryId: widget.serviceProviderId,
        nearYou: _sortByProximity,
      ),
    );
    log('Fetching providers for categoryId: ${widget.serviceProviderId}');
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchProviders();
      }
    });
  }

  Future<void> _loadGuestMode() async {
    final isGuest = await AuthLocalRepo.instance.getGuestMode();
    if (!mounted) return;
    setState(() => _isGuest = isGuest);
  }

  Future<void> _requireLogin() async {
    await showErrorSnackbar(context, 'Please log in to continue');
    await pushScreen(context, const LoginScreen());
  }

  void _fetchProviders() {
    String? activityStatus;

    switch (_tabController.index) {
      case 1:
        activityStatus = 'online';

      case 2:
        activityStatus = 'offline';

      default:
        activityStatus = null;
    }

    context.read<ServiceProviderBloc>().add(
      FetchServiceProviders(
        categoryId: widget.serviceProviderId,
        activityStatus: activityStatus,
        nearYou: _sortByProximity,
        search:
            _searchController.text.isNotEmpty ? _searchController.text : null,
      ),
    );
  }

  Future<void> _pingProviders() async {
    if (_isGuest) {
      await _requireLogin();
      return;
    }
    final event = PingServiceProviders(
      serviceCategoryId: widget.serviceProviderId,
    );
    context.read<ServiceProviderBloc>().add(event);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      appBar: AppBar(
          forceMaterialTransparency: true,
        backgroundColor: colors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.black),
          onPressed: () => pop(context),
        ),
        centerTitle: true,
        title: UrbText(
          'Service Providers',
          size: 22,
          height: 32,
          weight: FontWeight.w700,
          color: colors.black,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchProviders();
        },
        color: colors.primary,
        child: Column(
          children: [
            Padding(
              padding: pad(horizontal: 16),
              child: FilterSearchFormField(
                controller: _searchController,
                hintText: 'Search for services',
                onTapSuffix: () {},
                onChanged: (value) {
                  Future.delayed(
                    const Duration(milliseconds: 500),
                    _fetchProviders,
                  );
                },
                prefixIconPath: AppAssets.ASSETS_ICONS_SEARCH_SVG,
              ),
            ),
            24.verticalSpace,
            TabBar(
              controller: _tabController,
              indicatorColor: colors.primary.shade500,
              labelColor: colors.primary.shade500,
              unselectedLabelColor: colors.black,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Online'),
                Tab(text: 'Offline'),
              ],
            ),
            10.verticalSpace,
            Padding(
              padding: pad(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GenText(
                    'Sorted by Proximity',
                    size: 13,
                    color: colors.textColor.shade500,
                  ),
                  BlocConsumer<ServiceProviderBloc, ServiceProviderState>(
                    listener: (context, state) {
                      if (state is ServiceProvidersError) {
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          await showErrorSnackbar(
                            context,
                            state.error,
                          );
                        });
                      }

                      if (state is PingProvidersSuccess) {
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          await showSuccessSnackbar(
                            context,
                            'Providers pinged successfully!',
                          );
                        });
                      }
                    },
                    builder: (context, state) {
                      if (state is PingProvidersLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary.shade500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: () async {
                          log('Ping Providers pressed');
                          await _pingProviders();
                        },
                        icon: AppAssets.ASSETS_ICONS_NOTIFICATION_BELL_SVG.svg,
                        label: GenText(
                          'Ping Providers',
                          size: 12,
                          height: 20,
                          weight: FontWeight.w400,
                          color: colors.whiteColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            20.verticalSpace,
            Container(
              width: double.infinity,
              padding: pad(horizontal: 8, vertical: 4),
              margin: pad(horizontal: 16),
              decoration: BoxDecoration(
                color: colors.error.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: GenText(
                'Ping Providers: Send your request to multiple providers at once to get faster response.',
                size: 10,
                height: 20,
                weight: FontWeight.w400,
                color: colors.black,
              ),
            ),
            20.verticalSpace,
            Expanded(
              child: BlocBuilder<ServiceProviderBloc, ServiceProviderState>(
                builder: (context, state) {
                  if (state is ServiceProvidersLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colors.primary.shade500,
                      ),
                    );
                  }

                  if (state is ServiceProvidersLoaded) {
                    providers = state.providers;
                    if (providers.isNotEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          _fetchProviders();
                        },
                        color: colors.primary,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _ProviderList(
                              providers: providers,
                              serviceCategoryId: widget.serviceProviderId,
                            ),
                            _ProviderList(
                              providers:
                                  providers
                                      .where(
                                        (p) => p.activityStatus == 'online',
                                      )
                                      .toList(),
                            serviceCategoryId: widget.serviceProviderId
                            ),
                            _ProviderList(
                              providers:
                                  providers
                                      .where(
                                        (p) => p.activityStatus == 'offline',
                                      )
                                      .toList(),
                            serviceCategoryId: widget.serviceProviderId
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: GenText(
                          'No service providers found.',
                          size: 16,
                          color: colors.textColor.shade500,
                        ),
                      );
                    }
                  }
                  if (providers.isNotEmpty) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _ProviderList(providers: providers, serviceCategoryId: widget.serviceProviderId),
                        _ProviderList(
                          providers:
                              providers
                                  .where((p) => p.activityStatus == 'online')
                                  .toList(),
                        serviceCategoryId: widget.serviceProviderId
                        ),
                        _ProviderList(
                          providers:
                              providers
                                  .where((p) => p.activityStatus == 'offline')
                                  .toList(),
                        serviceCategoryId: widget.serviceProviderId
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderList extends StatelessWidget {
  const _ProviderList({
    required this.providers,
    required this.serviceCategoryId,
  });
  final List<ServiceProvider> providers;
  final int serviceCategoryId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (providers.isEmpty) {
      return Padding(
        padding: pad(horizontal: 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: colors.greyColor,
              ),
              16.verticalSpace,
              UrbText(
                'No providers found',
                size: 16,
                weight: FontWeight.w600,
                color: colors.greyColor,
              ),
              8.verticalSpace,
              GenText(
                'There are no service providers available in this category',
                color: colors.textColor.shade500,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: providers.length,
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 8.h,
        bottom: 100.h,
      ),
      itemBuilder: (context, index) {
        final provider = providers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _ProviderCard(
            provider: provider,
            onTap: () async {
              await pushScreen(
                context,
                ServiceProviderDetailsScreen(
                  provider: provider,
                  serviceCategoryId: serviceCategoryId,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({required this.provider, this.onTap});
  final ServiceProvider provider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final isOnline = provider.activityStatus?.toLowerCase() == 'online';
    final distanceInKm = provider.distanceKM ?? 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.lightGreyColor2),
          color: colors.whiteColor,
        ),
        child: Padding(
          padding: pad(vertical: 12, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PictureWidget(
                    image: provider.profileImage,
                    radius: 30,
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UrbText(
                          provider.companyName,
                          height: 24.5,
                          weight: FontWeight.w600,
                          color: colors.black,
                        ),
                        2.verticalSpace,
                        GenText(
                          provider.serviceName ?? '',
                          size: 13,
                          color: colors.textColor.shade500,
                        ),
                        6.verticalSpace,
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.orange,
                            ),
                            4.horizontalSpace,
                            GenText(
                              provider.averageRating.toString(),
                              size: 12,
                              color: colors.black,
                            ),
                            2.horizontalSpace,
                            GenText(
                              '(${provider.totalReviews})',
                              size: 12,
                              color: colors.neutral.shade300,
                            ),
                            10.horizontalSpace,
                            AppAssets.ASSETS_ICONS_LOCATION_SVG.svgColor(
                              color: colors.neutral.shade300,
                            ),
                            2.horizontalSpace,
                            GenText(
                             distanceInKm.toString(),
                              size: 12,
                              color: colors.neutral.shade300,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: pad(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          isOnline
                              ? colors.success.shade50
                              : colors.secondary.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GenText(
                      provider.activityStatus ?? '',
                      size: 12,
                      weight: FontWeight.w600,
                      color:
                          isOnline
                              ? colors.success.shade700
                              : colors.secondary.shade600,
                    ),
                  ),
                ],
              ),
              12.verticalSpace,
              GenText(
                provider.description ?? '',
                size: 13,
                height: 20,
                color: colors.textColor.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
