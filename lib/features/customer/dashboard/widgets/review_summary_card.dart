import 'package:resq360/__lib.dart';

class ReviewSummaryCard extends StatelessWidget {
  const ReviewSummaryCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Col(
          children: [
            Padding(
              padding: pad(horizontal: 20),
              child: GenText(
                '4.9',
                size: 24,
                weight: FontWeight.w500,
                color: colors.black,
                textAlign: TextAlign.center,
              ),
            ),
            5.verticalSpace,
            Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: colors.primary.shade400,
                      size: 18,
                    ),
                    Icon(
                      Icons.star,
                      color: colors.primary.shade400,
                      size: 18,
                    ),
                    Icon(
                      Icons.star,
                      color: colors.primary.shade400,
                      size: 18,
                    ),
                    Icon(
                      Icons.star,
                      color: colors.primary.shade400,
                      size: 18,
                    ),
                    Icon(
                      Icons.star_half,
                      color: colors.primary.shade400,
                      size: 18,
                    ),
                  ],
                ),
                5.verticalSpace,
              ],
            ),
            Padding(
              padding: pad(horizontal: 25),
              child: GenText(
                '(347)',
                size: 13,
                color: colors.greyColor2,
              ),
            ),
          ],
        ),

        Expanded(
          child: Padding(
            padding: pad(horizontal: 20),
            child: Col(
              children: [
                LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(8.r),
                  value: 1,
                  backgroundColor: colors.lightGreyColor3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.primary.shade400,
                  ),
                  minHeight: 4,
                  semanticsLabel: '5 star',
                ),
                8.verticalSpace,
                LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(8.r),
                  value: 0.85,
                  backgroundColor: colors.lightGreyColor3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.primary.shade400,
                  ),
                  minHeight: 4,
                  semanticsLabel: '5 star',
                ),
                8.verticalSpace,
                LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(8.r),
                  value: 0.65,
                  backgroundColor: colors.lightGreyColor3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.primary.shade400,
                  ),
                  minHeight: 4,
                  semanticsLabel: '5 star',
                ),
                8.verticalSpace,
                LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(8.r),
                  value: 0.45,
                  backgroundColor: colors.lightGreyColor3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.primary.shade400,
                  ),
                  minHeight: 4,
                  semanticsLabel: '5 star',
                ),
                8.verticalSpace,
                LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(8.r),
                  value: 0.25,
                  backgroundColor: colors.lightGreyColor3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colors.primary.shade400,
                  ),
                  minHeight: 4,
                  semanticsLabel: '5 star',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
