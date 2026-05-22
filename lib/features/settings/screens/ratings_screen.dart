import 'dart:async';

import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/app_text.util.dart';
import 'package:resq360/features/settings/data/bloc/ratings_bloc/ratings_bloc.dart';
import 'package:resq360/features/settings/data/models/customer_ratings_model.dart';
import 'package:resq360/features/settings/data/models/provider_ratings.dart';
import 'package:resq360/features/settings/widgets/reviews_card.dart';
import 'package:resq360/features/widgets/empty_screen_widget.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({required this.isProvider, super.key});

  final bool isProvider;
  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_refreshRatings());
  }

  Future<void> _refreshRatings() async {
    if (widget.isProvider) {
      context.read<RatingsBloc>().add(FetchProviderRatings());
    } else {
      context.read<RatingsBloc>().add(FetchCustomerRatings());
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        backgroundColor: appColors.whiteColor,
        forceMaterialTransparency: true,
        title: const GenText('Rating', size: 18, weight: FontWeight.w700),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        foregroundColor: appColors.black,
      ),

      body: BlocConsumer<RatingsBloc, RatingsState>(
        builder: (context, state) {
          if (state is RatingsLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: appColors.primary.shade500,
              ),
            );
          }

          if (state is RatingsLoaded) {
            if (widget.isProvider) {
              final reviews = state.providerRatings?.reviews ?? [];

              if (reviews.isEmpty) {
                return EmptyScreenWidget(
                  image: AppAssets.ASSETS_ICONS_EMPTY_STATE_SVG.svg,
                  message: 'You do not have any review',
                  subMessage: '',
                );
              }

              return Padding(
                padding: pad(horizontal: 20, vertical: 16),
                child: ListView(
                  children: [
                    RatingSummaryWidget<ProviderReview>(
                      average: state.providerRatings?.averageRatings ?? 0,
                      totalReviews: state.providerRatings?.totalReviews ?? 0,
                      reviews: state.providerRatings?.reviews ?? [],
                      extractRating: (review) => review.overallRating ?? 0,
                    ),

                    20.verticalSpace,
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      separatorBuilder: (_, _) => 14.verticalSpace,
                      itemBuilder: (context, index) {
                        final r = reviews[index];
                        return ReviewCardShared(
                          name: r.user?.fullName ?? 'N/A',
                          avatar: r.user?.profileImage ?? '',
                          category:
                              r.serviceRequest?.serviceCategory?.name ??
                              'General',
                          date: AppTextUtil.formatDateToStringNormal(
                            DateTime.tryParse(r.ratingDate ?? '').toString(),
                          ),
                          rating: r.overallRating ?? 0,
                          feedback: r.feedback ?? '',
                        );
                      },
                    ),
                  ],
                ),
              );
            } else {
              final reviews = state.customerRatings?.reviews ?? [];

              if (reviews.isEmpty) {
                return EmptyScreenWidget(
                  image: AppAssets.ASSETS_ICONS_EMPTY_STATE_SVG.svg,
                  message: 'You do not have any review',
                  subMessage: '',
                );
              }

              return Padding(
                padding: pad(horizontal: 20, vertical: 16),
                child: ListView(
                  children: [
                    RatingSummaryWidget<CustomerReview>(
                      average: state.customerRatings?.averageRatings ?? 0,
                      totalReviews: state.customerRatings?.totalReviews ?? 0,
                      reviews: state.customerRatings?.reviews ?? [],
                      extractRating: (review) => review.overallRating ?? 0,
                    ),

                    20.verticalSpace,
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      separatorBuilder: (_, _) => 14.verticalSpace,
                      itemBuilder: (context, index) {
                        final r = reviews[index];
                        return ReviewCardShared(
                          name: r.provider?.fullName ?? 'N/A',
                          avatar: r.provider?.profileImage ?? '',
                          category:
                              r.serviceRequest?.serviceCategory?.name ??
                              'General',
                          date: AppTextUtil.formatDateToStringNormal(
                            DateTime.tryParse(r.ratingDate ?? '').toString(),
                          ),
                          rating: r.overallRating ?? 0,
                          feedback: r.feedback ?? '',
                        );
                      },
                    ),
                  ],
                ),
              );
            }
          }

          return const SizedBox.shrink();
        },

        listener: (context, state) {
          if (state is RatingsError) {
            unawaited(showErrorSnackbar(context, state.message));
          }
        },
      ),
    );
  }
}

class RatingSummaryWidget<T> extends StatelessWidget {
  const RatingSummaryWidget({
    required this.average,
    required this.totalReviews,
    required this.reviews,
    required this.extractRating,
    super.key,
  });

  final num average;
  final int totalReviews;
  final List<T> reviews;

  final int Function(T review) extractRating;

  Map<int, int> _buildStarMap() {
    final map = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (final r in reviews) {
      final rating = extractRating(r);

      if (map.containsKey(rating)) {
        map[rating] = map[rating]! + 1;
      }
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final starMap = _buildStarMap();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: colors.primary.shade500, size: 18),
            4.horizontalSpace,
            GenText(
              average.toStringAsFixed(1),
              size: 22,
              weight: FontWeight.w700,
            ),
          ],
        ),

        6.verticalSpace,

        GenText(
          'Based on $totalReviews reviews',
          size: 12,
          color: colors.textColor.shade300,
        ),

        20.verticalSpace,

        Column(
          children:
              starMap.entries.map((entry) {
                final star = entry.key;
                final count = entry.value;

                final percentage =
                    totalReviews == 0 ? 0.0 : count / totalReviews;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 20,
                  ),
                  child: Row(
                    children: [
                      GenText('$star', size: 13, color: colors.black),
                      4.horizontalSpace,
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      6.horizontalSpace,

                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: colors.textColor.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percentage,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      8.horizontalSpace,
                      GenText('$count', size: 12),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
