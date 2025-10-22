import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/service_bloc/customer_services_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';
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
  bool _sortByProximity = false;

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> providers = [
    {
      'name': 'QuickTow Emergency',
      'service': 'Towing Service',
      'rating': 4.9,
      'reviews': 347,
      'distance': '1.0km',
      'description':
          'With over 8 years experience we provide prompt and professional towing service.',
      'status': 'Online',
      'image': 'https://randomuser.me/api/portraits/men/32.jpg',
    },
    {
      'name': 'Homify',
      'service': 'Cleaning Service',
      'rating': 4.9,
      'reviews': 347,
      'distance': '1.0km',
      'description':
          'With over 10 years experience we provide prompt and professional cleaning service.',
      'status': 'Online',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
    },
    {
      'name': 'QuickTow Emergency',
      'service': 'Towing Service',
      'rating': 4.9,
      'reviews': 347,
      'distance': '1.0km',
      'description':
          'With over 8 years experience we provide prompt and professional towing service.',
      'status': 'Offline',
      'image': 'https://randomuser.me/api/portraits/men/32.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initial fetch (All providers)
    context.read<CustomerServicesBloc>().add(
      CustomerFetchProviders(
        categoryId: widget.serviceProviderId,
        nearYou: _sortByProximity,
      ),
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchProviders();
      }
    });
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

    context.read<CustomerServicesBloc>().add(
      CustomerFetchProviders(
        categoryId: widget.serviceProviderId,
        activityStatus: activityStatus,
        nearYou: _sortByProximity,
        search: _searchController.text.isNotEmpty
                ? _searchController.text
                : null,
      ),
    );
  }

  void _toggleProximity() {
    setState(() {
      _sortByProximity = !_sortByProximity;
    });
    _fetchProviders();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      appBar: AppBar(
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
      body: Column(
        children: [
          Padding(
            padding: pad(horizontal: 16),
            child: FilterSearchFormField(
              controller: _searchController,
              hintText: 'Search for services',
              onTapSuffix: () {},
              onChanged: (value) {
               Future.delayed(const Duration(milliseconds: 500), _fetchProviders);

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
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () {
                    log('Ping Providers pressed');
                    _toggleProximity();
                  },
                  icon: AppAssets.ASSETS_ICONS_NOTIFICATION_BELL_SVG.svg,
                  label: GenText(
                    'Ping Providers',
                    size: 12,
                    height: 20,
                    weight: FontWeight.w400,
                    color: colors.whiteColor,
                  ),
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
            child: BlocBuilder<CustomerServicesBloc, CustomerServicesState>(
              builder: (context, state) {
                if (state is CustomerServicesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CustomerServicesError) {
                  return Center(
                    child: Text(
                      state.error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (state is CustomerProvidersLoaded) {
                  final providers = state.providers;
                  if (providers.isNotEmpty) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _ProviderList(
                          providers: providers,
                        ),
                        _ProviderList(
                          providers:
                              providers
                                  .where((p) => p.activityStatus == 'Online')
                                  .toList(),
                        ),
                        _ProviderList(
                          providers:
                              providers
                                  .where((p) => p.activityStatus == 'Offline')
                                  .toList(),
                        ),
                      ],
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
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderList extends StatelessWidget {
  const _ProviderList({
    required this.providers,
    // required this.providerId
  });
  final List<ServiceProvider> providers;
  // final int  providerId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: providers.length,
      padding: pad(horizontal: 16, vertical: 8),
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
                  providerId: provider.id!,
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
                  CircleAvatar(
                    radius: 26,
                    // backgroundImage: NetworkImage(provider.),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UrbText(
                          provider.companyName ?? '',
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
                            GenText('4.8', size: 12, color: colors.black),
                            2.horizontalSpace,
                            GenText(
                              '(127)',
                              size: 12,
                              color: colors.neutral.shade300,
                            ),
                            10.horizontalSpace,
                            AppAssets.ASSETS_ICONS_LOCATION_SVG.svgColor(
                              color: colors.neutral.shade300,
                            ),
                            2.horizontalSpace,
                            GenText(
                              '1.2km',
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
