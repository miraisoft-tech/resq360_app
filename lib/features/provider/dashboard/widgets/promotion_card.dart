import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/promotion_helper.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';
import 'package:resq360/features/provider/dashboard/widgets/promotion_metric_column.dart';
import 'package:resq360/features/provider/dashboard/widgets/promotion_status_bar.dart';


class PromotionCard extends StatelessWidget {

  const PromotionCard({
    required this.promotion,
    required this.onViewDetails,
    required this.onShowOptions,
    super.key,

  });
  final Advertisement promotion;
  final VoidCallback onViewDetails;
  final VoidCallback onShowOptions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final promotionImpressionCount = promotion.impressionCount ?? 0;
    final clickCount = promotion.clickCount ?? 0;
    final ctr = promotionImpressionCount > 0
        ? (clickCount / promotionImpressionCount * 100)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.neutral.shade200),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (promotion.imageUrl != null)
            _PromotionImage(imageUrl: promotion.imageUrl!),
          Padding(
            padding: pad(both: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PromotionHeader(promotion: promotion),
                if (promotion.description != null) ...[
                  12.verticalSpace,
                  GenText(
                    promotion.description!,
                    size: 13,
                    color: colors.neutral.shade600,
                    maxLines: 2,
                  ),
                ],
                16.verticalSpace,
                if (promotion.budget != null)
                  _DiscountBadge(discount: promotion.budget!),
                16.verticalSpace,
                _PromotionMetrics(
                  impressions: promotionImpressionCount,
                  clicks: clickCount,
                  ctr: ctr,
                ),
                16.verticalSpace,
                if (promotion.startDate != null && promotion.endDate != null)
                  _DateRange(
                    startDate: promotion.startDate.toString(),
                    endDate: promotion.endDate.toString(),
                  ),
                16.verticalSpace,
                _PromotionActions(
                  onViewDetails: onViewDetails,
                  onShowOptions: onShowOptions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromotionImage extends StatelessWidget {

  const _PromotionImage({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 160.h,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: double.infinity,
          height: 160.h,
          color: colors.neutral.shade100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.campaign,
                size: 48,
                color: colors.neutral.shade400,
              ),
              8.verticalSpace,
              GenText(
                'Promotion Image',
                size: 12,
                color: colors.neutral.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromotionHeader extends StatelessWidget {

  const _PromotionHeader({required this.promotion});
  final Advertisement promotion;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Expanded(
          child: GenText(
            promotion.title ?? promotion.description ?? 'Promotion',
            size: 16,
            weight: FontWeight.w700,
            color: colors.black,
            maxLines: 2,
          ),
        ),
        8.horizontalSpace,
        PromotionStatusBadge(
          status: promotion.status ?? 'PENDING',
          isActive: promotion.isActive ?? false,
        ),
      ],
    );
  }
}

class _DiscountBadge extends StatelessWidget {

  const _DiscountBadge({required this.discount});
  final int discount;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: pad(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.success.shade50,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer,
            size: 16,
            color: colors.success.shade700,
          ),
          6.horizontalSpace,
          GenText(
            '$discount% OFF',
            size: 13,
            weight: FontWeight.w700,
            color: colors.success.shade700,
          ),
        ],
      ),
    );
  }
}

class _PromotionMetrics extends StatelessWidget {

  const _PromotionMetrics({
    required this.impressions,
    required this.clicks,
    required this.ctr,
  });
  final int impressions;
  final int clicks;
  final double ctr;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: pad(both: 12),
      decoration: BoxDecoration(
        color: colors.neutral.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: PromotionMetricColumn(
              icon: Icons.visibility_outlined,
              label: 'Views',
              value: PromotionFormatters.formatNumber(impressions),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: colors.neutral.shade200,
          ),
          Expanded(
            child: PromotionMetricColumn(
              icon: Icons.touch_app_outlined,
              label: 'Clicks',
              value: PromotionFormatters.formatNumber(clicks),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: colors.neutral.shade200,
          ),
          Expanded(
            child: PromotionMetricColumn(
              icon: Icons.trending_up,
              label: 'CTR',
              value: '${ctr.toStringAsFixed(1)}%',
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRange extends StatelessWidget {

  const _DateRange({
    required this.startDate,
    required this.endDate,
  });
  final String startDate;
  final String endDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 14,
          color: colors.neutral.shade500,
        ),
        6.horizontalSpace,
        GenText(
          PromotionFormatters.formatDateRange(startDate, endDate),
          size: 12,
          color: colors.neutral.shade600,
        ),
      ],
    );
  }
}

class _PromotionActions extends StatelessWidget {

  const _PromotionActions({
    required this.onViewDetails,
    required this.onShowOptions,
  });
  final VoidCallback onViewDetails;
  final VoidCallback onShowOptions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onViewDetails,
            icon: const Icon(Icons.analytics_outlined, size: 18),
            label: const Text('View Details'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary.shade500,
              side: BorderSide(color: colors.primary.shade500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        12.horizontalSpace,
        IconButton(
          onPressed: onShowOptions,
          icon: Icon(
            Icons.more_vert,
            color: colors.neutral.shade600,
          ),
          style: IconButton.styleFrom(
            backgroundColor: colors.neutral.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
      ],
    );
  }
}
