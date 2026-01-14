import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';

class RecommendedCard extends StatelessWidget {
  const RecommendedCard({required this.advertisement, super.key});

  final Advertisement advertisement;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final title = advertisement.title ?? 'Untitled';
    final description = advertisement.description ?? '';
    final image = advertisement.imageUrl;
    final serviceType = advertisement.serviceType ?? '';

    const rating = 4.8;
    const reviewCount = 127;
    const distance = '1.2km';

    return Column(
      children: [
        Container(
          padding: pad(horizontal: 5, vertical: 14),
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
            border: Border.all(color: colors.lightGreyColor2),
            borderRadius: BorderRadius.circular(12),
            color: colors.whiteColor,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PictureWidget(
                image: image,
              ),
              5.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: UrbText(
                            title,
                            height: 24.5,
                            weight: FontWeight.w500,
                            color: colors.black,
                            maxLines: 1,
                          ),
                        ),
                        20.horizontalSpace,

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

                    if (serviceType.isNotEmpty)
                      GenText(
                        serviceType,
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
                        GenText('$rating', size: 12, color: colors.black),
                        2.horizontalSpace,
                        GenText(
                          '($reviewCount)',
                          size: 12,
                          color: colors.neutral.shade300,
                        ),
                        10.horizontalSpace,
                        AppAssets.ASSETS_ICONS_LOCATION_SVG.svgColor(
                          color: colors.neutral.shade300,
                        ),
                        2.horizontalSpace,
                        GenText(
                          distance,
                          size: 12,
                          color: colors.neutral.shade300,
                        ),
                      ],
                    ),
                    8.verticalSpace,
                    if (description.isNotEmpty)
                      GenText(
                        description,
                        size: 12,
                        weight: FontWeight.w400,
                        color: colors.textColor.shade500,
                        maxLines: 3,
                      ),
                    20.verticalSpace,
                    if (advertisement.budget != null)
                      Container(
                        padding: pad(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.primary.shade500,
                          borderRadius: BorderRadius.circular(33.r),
                        ),
                        child: GenText(
                          '-${advertisement.budget}% Today',
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
      ],
    );
  }
}
