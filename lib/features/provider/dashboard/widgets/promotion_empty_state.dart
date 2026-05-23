import 'package:resq360/__lib.dart';

class PromotionEmptyState extends StatelessWidget {
  const PromotionEmptyState({
    required this.activeOnly,
    required this.onCreatePromotion,
    super.key,
  });
  final bool activeOnly;
  final VoidCallback onCreatePromotion;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: pad(both: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: pad(both: 24),
              decoration: BoxDecoration(
                color: colors.neutral.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.campaign_outlined,
                size: 64,
                color: colors.neutral.shade400,
              ),
            ),
            24.verticalSpace,
            GenText(
              activeOnly ? 'No Active Promotions' : 'No Promotions Yet',
              size: 18,
              weight: FontWeight.w600,
              color: colors.black,
            ),
            12.verticalSpace,
            GenText(
              activeOnly
                  ? 'Create a promotion to reach more customers'
                  : 'Start promoting your services to increase visibility',
              color: colors.neutral.shade600,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            32.verticalSpace,
            WideButton(
              label: 'Create Promotion',
              backgroundColor: colors.primary.shade500,
              textColor: colors.whiteColor,
              onPressed: onCreatePromotion,
            ),
          ],
        ),
      ),
    );
  }
}
