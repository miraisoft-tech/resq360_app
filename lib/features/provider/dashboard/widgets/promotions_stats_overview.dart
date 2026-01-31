import 'package:resq360/__lib.dart';
import 'package:resq360/core/utils/promotion_helper.dart';

class PromotionStatsOverview extends StatelessWidget {

  const PromotionStatsOverview({
    required this.stats,
    super.key,
  });
  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: pad(horizontal: 16, vertical: 16),
      padding: pad(both: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary.shade500, colors.primary.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: colors.whiteColor, size: 24),
              8.horizontalSpace,
              GenText(
                'Performance Overview',
                size: 16,
                weight: FontWeight.w700,
                color: colors.whiteColor,
              ),
            ],
          ),
          20.verticalSpace,
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Total Views',
                  value: PromotionFormatters.formatNumber(
                      stats['totalImpressions'] as int? ?? 0),
                  icon: Icons.visibility_outlined,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Total Clicks',
                  value: PromotionFormatters.formatNumber(
                      stats['totalClicks'] as int? ?? 0),
                  icon: Icons.touch_app_outlined,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Avg. CTR',
                  value: '${(stats['avgCTR'] as double).toStringAsFixed(1)}%',
                  icon: Icons.percent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Icon(icon, color: colors.whiteColor.withValues(alpha: 0.8), size: 20),
        8.verticalSpace,
        GenText(
          value,
          size: 20,
          weight: FontWeight.w700,
          color: colors.whiteColor,
        ),
        4.verticalSpace,
        GenText(
          label,
          size: 11,
          color: colors.whiteColor.withValues(alpha: 0.8),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
