import 'package:resq360/__lib.dart';

class PromoCardWidget extends StatelessWidget {
  const PromoCardWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.primary.shade500,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              16.horizontalSpace,
              Expanded(
                child: Padding(
                  padding: pad(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UrbText(
                        'Help, Anytime. Anywhere',
                        size: 18,
                        height: 28.5,
                        weight: FontWeight.w700,
                        color: colors.whiteColor,
                      ),
                      GenText(
                        'Stuck? Tap now for fast roadside assistance',
                        size: 12,
                        height: 20.5,
                        color: colors.whiteColor,
                      ),
                      10.verticalSpace,
                      SizedBox(
                        height: 30.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: pad(horizontal: 14),
                            backgroundColor: colors.whiteColor,
                            foregroundColor: colors.primary.shade500,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          onPressed: () {},
                          child: GenText(
                            'Call Now',
                            height: 16.5,
                            color: colors.primary.shade500,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppAssets.ASSETS_IMAGES_HAPPY_MECHANIC_PNG.imageAsset(
                height: 140,
                width: 120,
                fit: BoxFit.contain,
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
