import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/gallery_item_model.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/chat/screens/chat_details_screen.dart';
import 'package:resq360/features/customer/authentication/screens/login_screen.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/providers_bloc/provider_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/bloc/service_request_bloc.dart/service_request_bloc.dart';
import 'package:resq360/features/customer/dashboard/data/models/service_models/service_request.model.dart';
import 'package:resq360/features/customer/dashboard/widgets/chip_widget.dart';
import 'package:resq360/features/customer/dashboard/widgets/provider_review_card.dart';
import 'package:resq360/features/customer/dashboard/widgets/review_summary_card.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/settings/data/bloc/ratings_bloc/ratings_bloc.dart';
import 'package:resq360/features/widgets/gallery_image_viewer.dart';

class ServiceProviderDetailsScreen extends StatefulWidget {
  const ServiceProviderDetailsScreen({
    this.provider,
    this.providerId,
    this.serviceCategoryId,
    super.key,
  }) : assert(
         provider != null || providerId != null,
         'Either provider or providerId must be provided',
       );

  final ServiceProvider? provider;
  final int? providerId;
  final int? serviceCategoryId;

  @override
  State<ServiceProviderDetailsScreen> createState() =>
      _ServiceProviderDetailsScreenState();
}

class _ServiceProviderDetailsScreenState
    extends State<ServiceProviderDetailsScreen> {
  int currentIndex = 0;
  ServiceProvider? _provider;
  bool _isGuest = false;
  int? _selectedProviderServiceId;

  @override
  void initState() {
    super.initState();

    unawaited(_loadGuestMode());

    if (widget.provider != null || widget.providerId != null) {
      _provider = widget.provider;
      _loadRatings();

      if (widget.provider?.id != null || widget.providerId != null) {
        context.read<ProviderBloc>().add(
          FetchAServiceProvider(
            providerId: widget.provider?.id ?? widget.providerId ?? 0,
          ),
        );
      }
    }
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

  void _loadRatings() {
    if (_provider != null) {
      context.read<RatingsBloc>().add(
        FetchProviderRatingsById(providerId: _provider!.id),
      );
    }
  }

  Future<void> _createServiceRequest({int? overrideServiceId}) async {
    if (_provider == null || _provider!.providerServices.isEmpty) return;

    final targetId = overrideServiceId ?? widget.serviceCategoryId;

    final matchedService = _provider!.providerServices.firstWhere(
      (service) => service.serviceId == targetId,
      orElse: () => throw Exception('Service not found'),
    );

    _selectedProviderServiceId = matchedService.id;

    context.read<ServiceRequestBloc>().add(
      BookServiceRequest(providerServiceId: matchedService.id),
    );
  }

  Future<void> _openImagesFullScreen(int indexOfImage) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (context) => GalleryImageViewWrapper(
              backgroundColor: Colors.black,
              initialIndex: indexOfImage,
              galleryItems:
                  _provider!.images
                      .asMap()
                      .entries
                      .map(
                        (e) => GalleryItemModel(
                          id: e.key.toString(),
                          imageUrl: e.value,
                          index: e.key,
                        ),
                      )
                      .toList(),
              titleGallery: null,
              loadingWidget: Center(
                child: CircularProgressIndicator(
                  color: context.appColors.primary.shade500,
                ),
              ),
              errorWidget: const Center(
                child: Icon(Icons.broken_image, size: 50),
              ),
              minScale: 0.5,
              maxScale: 4,
              radius: 0,
              reverse: false,
              showListInGalley: true,
              showAppBar: true,
              closeWhenSwipeUp: true,
              closeWhenSwipeDown: true,
            ),
      ),
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
                forceMaterialTransparency: true,
                backgroundColor: colors.whiteColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.black),
                  onPressed: () => pop(context),
                ),
              ),
              body: Center(
                child: CircularProgressIndicator(
                  color: colors.primary.shade500,
                ),
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
                showLoadingDialog(context);
              }

              if (state is ServiceRequestCreated) {
                await pop(context);

                await pushScreen(
                  context,
                  ChatDetailScreen(
                    chatId: state.request.id!,
                    userType: UserType.customer,
                    providerServiceId: _selectedProviderServiceId,
                  ),
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
                                    return GestureDetector(
                                      onTap: () => _openImagesFullScreen(index),
                                      child: Image.network(
                                        serviceGallery[index],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder:
                                            (_, _, _) =>
                                                const Icon(Icons.broken_image),
                                      ),
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
                                    PictureWidget(image: provider.profileImage),
                                    12.horizontalSpace,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          UrbText(
                                            provider.fullName?.capitalize ??
                                                'N/A',
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
                                                      is RatingsLoaded) {
                                                    return Row(
                                                      children: [
                                                        UrbText(
                                                          '(${provider.companyName})',
                                                          size: 12,
                                                          height: 14.5,
                                                          weight:
                                                              FontWeight.w400,
                                                          color: colors.black,
                                                        ),
                                                        4.horizontalSpace,
                                                        const Icon(
                                                          Icons.star,
                                                          size: 16,
                                                          color: Colors.orange,
                                                        ),
                                                        4.horizontalSpace,
                                                        GenText(
                                                          provider.averageRating
                                                                  ?.toStringAsFixed(
                                                                    1,
                                                                  ) ??
                                                              '0.0',
                                                          color: colors.black,
                                                        ),

                                                        6.horizontalSpace,
                                                        GenText(
                                                          '(${provider.totalReviews})',
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
                                                '${provider.distanceKM} km',
                                                size: 12,
                                                color: colors.neutral.shade300,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
                                  'Reviews (${provider.totalReviews ?? 0})',
                                  height: 20.5,
                                  weight: FontWeight.w700,
                                  color: colors.black,
                                ),
                                20.verticalSpace,
                                BlocBuilder<RatingsBloc, RatingsState>(
                                  builder: (context, ratingState) {
                                    if (ratingState is RatingsLoading) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: colors.primary.shade500,
                                        ),
                                      );
                                    }

                                    if (ratingState is RatingsError) {
                                      return GenText(
                                        ratingState.message,
                                        color: Colors.red,
                                      );
                                    }

                                    if (ratingState is RatingsLoaded) {
                                      final ratings =
                                          ratingState.providerRatings;
                                      final reviews = ratings?.reviews ?? [];

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ReviewSummaryCard(
                                            averageRating:
                                                ratings?.averageRatings
                                                    ?.toDouble() ??
                                                0,
                                            totalReviews:
                                                ratings?.totalReviews ?? 0,
                                          ),

                                          16.verticalSpace,

                                          if (reviews.isEmpty)
                                            GenText(
                                              'No reviews yet',
                                              color: colors.textColor.shade400,
                                            ),

                                          ...reviews.map(
                                            (r) => ProviderReviewCard(data: r),
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
                          if (_isGuest) {
                            await _requireLogin();
                            return;
                          }
                          if (widget.serviceCategoryId == null) {
                            final picked = await _pickProviderService(context);
                            log('Picked service ID: $picked');
                            if (picked == null) return;
                            await _createServiceRequest(
                              overrideServiceId: picked,
                            );
                          } else {
                            await _createServiceRequest();
                          }
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

  Future<int?> _pickProviderService(BuildContext context) async {
    final provider = _provider;
    if (provider == null) return null;

    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: context.appColors.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final colors = ctx.appColors;
        return Padding(
          padding: pad(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UrbText(
                'Select a Service',
                size: 18,
                weight: FontWeight.w700,
                color: colors.black,
              ),
              16.verticalSpace,
              ...provider.providerServices.map(
                (ps) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: GenText(ps.name, color: colors.black),
                  subtitle: GenText(
                    ps.service.name,
                    size: 12,
                    color: colors.textColor.shade400,
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colors.neutral.shade300,
                  ),
                  onTap: () => Navigator.pop(ctx, ps.serviceId),
                ),
              ),
              16.verticalSpace,
            ],
          ),
        );
      },
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
