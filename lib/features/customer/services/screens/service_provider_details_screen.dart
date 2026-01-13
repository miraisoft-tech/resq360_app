import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/customer/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/providers_bloc/provider_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/service_request_bloc.dart/service_request_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';
import 'package:resq360/features/customer/dashboard/widgets/chip_widget.dart';
import 'package:resq360/features/customer/dashboard/widgets/review_summary_card.dart';
import 'package:resq360/features/customer/dashboard/widgets/user_review_card.dart';
import 'package:resq360/features/settings/data/bloc/ratings_bloc/ratings_bloc.dart';

class ServiceProviderDetailsScreen extends StatefulWidget {
  const ServiceProviderDetailsScreen({
    this.provider,
    this.providerId,
    super.key,
  }) : assert(
         provider != null || providerId != null,
         'Either provider or providerId must be provided',
       );

  final ServiceProvider? provider;
  final int? providerId;

  @override
  State<ServiceProviderDetailsScreen> createState() =>
      _ServiceProviderDetailsScreenState();
}

class _ServiceProviderDetailsScreenState
    extends State<ServiceProviderDetailsScreen> {
  int currentIndex = 0;
  ServiceProvider? _provider;

  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'Maria Okoro',
      'avatar': 'https://randomuser.me/api/portraits/women/47.jpg',
      'rating': 5,
      'date': '1 day ago',
      'comment':
          'QuickTow Emergency is simply the best, they arrived in time and towed my vehicle to my destination. I would recommend their service',
    },
  ];

  @override
  void initState() {
    super.initState();

    if (widget.provider != null) {
      _provider = widget.provider;
      _loadRatings();
    } else if (widget.providerId != null) {
      context.read<ProviderBloc>().add(
        FetchAServiceProvider(providerId: widget.providerId!),
      );
    }
  }

  void _loadRatings() {
    if (_provider != null) {
      context.read<RatingsBloc>().add(
        FetchProviderRatingsById(providerId: _provider!.id),
      );
    }
  }

  Future<void> _createServiceRequest() async {
    final providerServiceId = _provider?.providerServiceId;
    if (providerServiceId == null) return;

    context.read<ServiceRequestBloc>().add(
      CreateServiceRequest(providerServiceId: providerServiceId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocListener<ProviderBloc, ProviderState>(
      listener: (context, state) async {
        if (state is ProviderLoaded) {
          setState(() {
            _provider = state.provider;
          });
          _loadRatings();
        } else if (state is ProviderError) {
          await showSnackBar(context, 'Error', state.error);
          await pop(context);
        }
      },
      child: BlocBuilder<ProviderBloc, ProviderState>(
        builder: (context, providerState) {
          if (providerState is ProviderLoading || _provider == null) {
            return Scaffold(
              backgroundColor: colors.whiteColor,
              appBar: AppBar(
                backgroundColor: colors.whiteColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.black),
                  onPressed: () => pop(context),
                ),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final provider = _provider!;
          final providerServices = provider.providerServices;
          final serviceGallery = provider.images;
          final serviceGroups =
              providerServices
                  .map(
                    (service) => _ServiceGroup(
                      title: service.name,
                      items: [service.service.name],
                    ),
                  )
                  .toList();

          return BlocListener<ServiceRequestBloc, ServiceRequestState>(
            listener: (context, state) async {
              if (state is ServiceRequestLoading) {
                await showLoadingDialog(context);
              }

              if (state is ServiceRequestCreated) {
                await pop(context);
                await pushScreen(
                  context,
                  ChatDetailScreen(chatId: state.chatId),
                );
              } else if (state is ServiceRequestError) {
                await pop(context);
                await showSnackBar(context, 'Error', state.error);
              }
            },
            child: Scaffold(
              backgroundColor: colors.whiteColor,
              body: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          pinned: true,
                          expandedHeight: 260,
                          elevation: 0,
                          backgroundColor: colors.whiteColor,
                          leading: IconButton(
                            icon: Icon(Icons.arrow_back, color: colors.black),
                            onPressed: () => pop(context),
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            background: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                PageView.builder(
                                  itemCount: serviceGallery.length,
                                  onPageChanged: (i) {
                                    setState(() => currentIndex = i);
                                  },
                                  itemBuilder: (_, index) {
                                    return Image.network(
                                      serviceGallery[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (_, _, _) =>
                                              const Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                                Positioned(
                                  bottom: 12,
                                  child: Container(
                                    padding: pad(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: GenText(
                                      '${currentIndex + 1}/${serviceGallery.length}',
                                      color: colors.whiteColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: pad(horizontal: 16, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (provider.activityStatus != null)
                                  Container(
                                    padding: pad(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colors.success.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: GenText(
                                      provider.activityStatus!,
                                      size: 12,
                                      color: colors.success.shade800,
                                    ),
                                  ),

                                15.verticalSpace,

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CircleAvatar(
                                      radius: 25,
                                      backgroundImage: NetworkImage(
                                        'https://randomuser.me/api/portraits/men/32.jpg',
                                      ),
                                    ),
                                    12.horizontalSpace,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          UrbText(
                                            provider.companyName,
                                            height: 24.5,
                                            weight: FontWeight.w700,
                                            color: colors.black,
                                          ),
                                          6.verticalSpace,
                                          Row(
                                            children: [
                                              4.horizontalSpace,
                                              BlocBuilder<
                                                RatingsBloc,
                                                RatingsState
                                              >(
                                                builder: (
                                                  context,
                                                  ratingState,
                                                ) {
                                                  if (ratingState
                                                      is ProviderRatingsLoaded) {
                                                    final ratings =
                                                        ratingState.ratings;

                                                    final avg =
                                                        (ratings.averageRatings ??
                                                                0)
                                                            .toDouble();
                                                    final total =
                                                        ratings.totalReviews ??
                                                        0;

                                                    return Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.star,
                                                          size: 16,
                                                          color: Colors.orange,
                                                        ),
                                                        4.horizontalSpace,
                                                        GenText(
                                                          avg.toStringAsFixed(
                                                            1,
                                                          ),
                                                          color: colors.black,
                                                        ),

                                                        6.horizontalSpace,
                                                        GenText(
                                                          '($total)',
                                                          size: 12,
                                                          color:
                                                              colors
                                                                  .neutral
                                                                  .shade300,
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                  return Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star,
                                                        size: 16,
                                                        color: Colors.orange,
                                                      ),
                                                      4.horizontalSpace,
                                                      GenText(
                                                        '--',
                                                        color: colors.black,
                                                      ),
                                                      6.horizontalSpace,
                                                      GenText(
                                                        '(...)',
                                                        size: 12,
                                                        color:
                                                            colors
                                                                .neutral
                                                                .shade300,
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),

                                              10.horizontalSpace,
                                              AppAssets
                                                  .ASSETS_ICONS_LOCATION_SVG
                                                  .svgColor(
                                                    color:
                                                        colors.neutral.shade300,
                                                  ),
                                              2.horizontalSpace,
                                              GenText(
                                                provider.distance != null
                                                    ? '${(provider.distance! / 1000).toStringAsFixed(1)} km'
                                                    : 'N/A',
                                                size: 12,
                                                color: colors.neutral.shade300,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    SVGButton(
                                      path:
                                          AppAssets.ASSETS_ICONS_CHAT_ICON_SVG,
                                      onTap: () async {
                                        await _createServiceRequest();
                                      },
                                    ),
                                    15.horizontalSpace,
                                    SVGButton(
                                      path:
                                          AppAssets.ASSETS_ICONS_CALL_ICON_SVG,
                                      onTap: () async {
                                        // await DialerUtil.open(provider.)
                                      },
                                    ),
                                  ],
                                ),

                                20.verticalSpace,

                                Wrap(
                                  spacing: 8,
                                  children:
                                      providerServices
                                          .map(
                                            (ps) => ChipWidget(
                                              label: ps.service.name,
                                            ),
                                          )
                                          .toList(),
                                ),

                                30.verticalSpace,

                                /// OVERVIEW
                                GenText(
                                  'Overview',
                                  height: 24,
                                  weight: FontWeight.w500,
                                  color: colors.black,
                                ),
                                16.verticalSpace,
                                GenText(
                                  provider.description ??
                                      'No description available at the moment.',
                                  height: 22,
                                  color: colors.textColor.shade500,
                                ),

                                16.verticalSpace,

                                /// SCHEDULE
                                Row(
                                  children: [
                                    AppAssets.ASSETS_ICONS_CALENDER_SVG.svg,
                                    8.horizontalSpace,
                                    GenText(
                                      provider.workingDays.isNotEmpty
                                          ? '${provider.workingDays.first.capitalize} - ${provider.workingDays.last.capitalize}'
                                          : 'Days unavailable',
                                      size: 13,
                                      color: colors.black,
                                    ),
                                    20.horizontalSpace,
                                    AppAssets.ASSETS_ICONS_CLOCK_SVG.svg,
                                    8.horizontalSpace,
                                    Expanded(
                                      child: GenText(
                                        '${AppTextUtil.formatDateToStringNormal(provider.openingHours, 'hh:mmaa')} - ${AppTextUtil.formatDateToStringNormal(provider.closingHours, 'hh:mmaa')}',
                                        size: 13,
                                        color: colors.black,
                                      ),
                                    ),
                                  ],
                                ),

                                20.verticalSpace,

                                GenText(
                                  'Services',
                                  height: 20.5,
                                  weight: FontWeight.w700,
                                  color: colors.black,
                                ),
                                12.verticalSpace,

                                ...serviceGroups,

                                20.verticalSpace,

                                /// REVIEWS
                                UrbText(
                                  'Reviews',
                                  height: 20.5,
                                  weight: FontWeight.w700,
                                  color: colors.black,
                                ),
                                20.verticalSpace,
                                BlocBuilder<RatingsBloc, RatingsState>(
                                  builder: (context, ratingState) {
                                    if (ratingState is RatingsLoading) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    if (ratingState is RatingsError) {
                                      return GenText(
                                        ratingState.message,
                                        color: Colors.red,
                                      );
                                    }

                                    if (ratingState is ProviderRatingsLoaded) {
                                      final ratings = ratingState.ratings;
                                      final reviews = ratings.reviews ?? [];

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ReviewSummaryCard(
                                            averageRating:
                                                ratings.averageRatings
                                                    ?.toDouble() ??
                                                0,
                                            totalReviews:
                                                ratings.totalReviews ?? 0,
                                          ),

                                          16.verticalSpace,

                                          if (reviews.isEmpty)
                                            GenText(
                                              'No reviews yet',
                                              color: colors.textColor.shade400,
                                            ),

                                          ...reviews.map(
                                            (r) => UserReviewCard(
                                              data: {
                                                'name':
                                                    r.user?.fullName ??
                                                    'Unknown user',
                                                'avatar': r.user?.profileImage,
                                                'rating': r.overallRating ?? 0,
                                                'date': r.ratingDate ?? '',
                                                'comment': r.feedback ?? '',
                                                'service':
                                                    r
                                                        .serviceRequest
                                                        ?.serviceCategory
                                                        ?.name ??
                                                    '',
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    return const SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: pad(horizontal: 16, vertical: 10),
                      child: WideButton(
                        label: 'Book Now',
                        onPressed: () async {
                          await _createServiceRequest();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ServiceGroup extends StatelessWidget {
  const _ServiceGroup({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GenText(
          title,
          weight: FontWeight.w400,
          color: colors.textColor.shade400,
        ),
        6.verticalSpace,
        ...items.map(
          (e) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              children: [
                const Text('• ', style: TextStyle(fontSize: 14)),
                GenText(
                  e,
                  weight: FontWeight.w400,
                  color: colors.textColor.shade400,
                ),
              ],
            ),
          ),
        ),
        const ListDivider(verticalSpacing: 10),
      ],
    );
  }
}
