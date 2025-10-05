import 'package:resq360/__lib.dart';

class RecommendedCard extends StatelessWidget {
  const RecommendedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Container(
          padding: pad(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: colors.lightGreyColor2),
            borderRadius: BorderRadius.circular(12),
            color: colors.whiteColor,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(
                  AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UrbText(
                          'Plumbing Pro',
                          height: 24.5,
                          weight: FontWeight.w500,
                          color: colors.black,
                        ),
                        const Spacer(),
                        Container(
                          padding: pad(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.success.shade50,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: GenText(
                            'Sponsored',
                            size: 10,
                            height: 20.5,
                            color: colors.success.shade700,
                          ),
                        ),
                      ],
                    ),
                    GenText(
                      'Emergency Plumbing',
                      size: 12,
                      height: 20.5,
                      weight: FontWeight.w400,
                      color: colors.textColor.shade500,
                    ),
                    4.verticalSpace,
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.orange),
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
                    8.verticalSpace,
                    GenText(
                      'With over 5 years experience we provide prompt and professional plumbing service.',
                      size: 12,
                      weight: FontWeight.w400,
                      color: colors.textColor.shade500,
                    ),
                    20.verticalSpace,
                    Container(
                      padding: pad(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.primary.shade500,
                        borderRadius: BorderRadius.circular(33.r),
                      ),
                      child: GenText(
                        '-30% Today',
                        size: 13,
                        weight: FontWeight.w600,
                        color: colors.whiteColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        10.verticalSpace,
        const SmallDotIndicator(total: 3, currentIndex: 0),
      ],
    );
  }
}
