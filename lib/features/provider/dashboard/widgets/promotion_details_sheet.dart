import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/promotion_helper.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';

class PromotionDetailsSheet extends StatelessWidget {

  const PromotionDetailsSheet({
    required this.promotion,
    super.key,

  });
  final Advertisement promotion;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final promotionImpressionCount = promotion.impressionCount ?? 0;
    final clickCount = promotion.clickCount ?? 0;
    final ctr = promotionImpressionCount > 0
        ? (clickCount / promotionImpressionCount * 100)
        : 0.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          _SheetHandle(),
          16.verticalSpace,
          _SheetHeader(),
          Divider(color: colors.neutral.shade200),
          Expanded(
            child: SingleChildScrollView(
              padding: pad(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PerformanceSection(
                    impressions: promotionImpressionCount,
                    clicks: clickCount,
                    ctr: ctr,
                    budget: promotion.budget ?? 0,
                  ),
                  24.verticalSpace,
                  _CampaignSection(promotion: promotion),
                  24.verticalSpace,
                  if (promotion.description != null)
                    _DescriptionSection(description: promotion.description!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: EdgeInsets.only(top: 12.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: colors.neutral.shade300,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: pad(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GenText(
              'Promotion Details',
              size: 20,
              weight: FontWeight.w700,
              color: colors.black,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _PerformanceSection extends StatelessWidget {

  const _PerformanceSection({
    required this.impressions,
    required this.clicks,
    required this.ctr,
    required this.budget,
  });
  final int impressions;
  final int clicks;
  final double ctr;
  final int budget;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GenText(
          'Performance Metrics',
          size: 16,
          weight: FontWeight.w700,
          color: colors.black,
        ),
        16.verticalSpace,
        Container(
          padding: pad(both: 16),
          decoration: BoxDecoration(
            color: colors.neutral.shade50,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              _DetailRow(
                label: 'Total Impressions',
                value: PromotionFormatters.formatNumber(impressions),
              ),
              Divider(height: 24.h),
              _DetailRow(
                label: 'Total Clicks',
                value: PromotionFormatters.formatNumber(clicks),
              ),
              Divider(height: 24.h),
              _DetailRow(
                label: 'Click-Through Rate',
                value: '${ctr.toStringAsFixed(2)}%',
              ),
              Divider(height: 24.h),
              _DetailRow(
                label: 'Discount Offered',
                value: '$budget%',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CampaignSection extends StatelessWidget {

  const _CampaignSection({required this.promotion});
  final Advertisement promotion;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GenText(
          'Campaign Information',
          size: 16,
          weight: FontWeight.w700,
          color: colors.black,
        ),
        16.verticalSpace,
        Container(
          padding: pad(both: 16),
          decoration: BoxDecoration(
            color: colors.neutral.shade50,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              _DetailRow(
                label: 'Status',
                value: promotion.status ?? 'Unknown',
              ),
              Divider(height: 24.h),
              _DetailRow(
                label: 'Type',
                value: promotion.adType ?? 'Standard',
              ),
              if (promotion.serviceType != null) ...[
                Divider(height: 24.h),
                _DetailRow(
                  label: 'Service Type',
                  value: promotion.serviceType!,
                ),
              ],
              Divider(height: 24.h),
              _DetailRow(
                label: 'Active',
                value: promotion.isActive ?? false ? 'Yes' : 'No',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DescriptionSection extends StatelessWidget {

  const _DescriptionSection({required this.description});
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GenText(
          'Description',
          size: 16,
          weight: FontWeight.w700,
          color: colors.black,
        ),
        12.verticalSpace,
        Container(
          width: double.infinity,
          padding: pad(both: 16),
          decoration: BoxDecoration(
            color: colors.neutral.shade50,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: GenText(
            description,
            color: colors.neutral.shade700,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {

  const _DetailRow({
    required this.label,
    required this.value,
  });
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GenText(
          label,
          color: colors.neutral.shade600,
        ),
        GenText(
          value,
          weight: FontWeight.w600,
          color: colors.black,
        ),
      ],
    );
  }
}
