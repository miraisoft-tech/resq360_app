import 'package:resq360/__lib.dart';

class OngoingServiceCard extends StatelessWidget {
  const OngoingServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: pad(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colors.whiteColor,
        border: Border.all(color: colors.lightGreyColor2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(
                  AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GenText(
                          'QuickTow Emergency',
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
                            'Completed',
                            size: 10,
                            height: 20.5,
                            color: colors.success.shade700,
                          ),
                        ),
                      ],
                    ),
                    GenText(
                      'Towing Service',
                      size: 12,
                      height: 20.5,
                      weight: FontWeight.w500,
                      color: colors.neutral.shade400,
                    ),
                    Row(
                      children: [
                        AppAssets.ASSETS_ICONS_TOW_ICON_SVG.svg,
                        4.horizontalSpace,
                        GenText(
                          '₦15,000',
                          size: 12,
                          height: 20.5,
                          weight: FontWeight.w400,
                          color: colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          30.verticalSpace,
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: pad(horizontal: 14),
                    elevation: 0,
                    backgroundColor: colors.error.shade50,
                    foregroundColor: colors.primary.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () {},
                  child: GenText(
                    'Appeal',
                    height: 16.5,
                    color: colors.primary.shade500,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              20.horizontalSpace,
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary.shade500,
                    foregroundColor: colors.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: const Text('Complete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
