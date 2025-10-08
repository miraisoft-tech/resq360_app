import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/data/models/reviews_model.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    required this.item,
    super.key,
  });

  final ReviewModel item;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      padding: pad(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: appColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.textColor.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundImage: NetworkImage(item.avatar),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GenText(
                      item.name,
                      size: 15,
                      weight: FontWeight.w600,
                    ),
                    5.verticalSpace,
                    GenText(
                      item.category,
                      size: 12,
                      color: appColors.textColor.shade300,
                    ),
                    2.verticalSpace,
                    Row(
                      children: [
                        AppAssets.ASSETS_ICONS_CALENDER_SVG.svgColor(
                          color: appColors.textColor.shade300,
                        ),
                        5.horizontalSpace,
                        GenText(
                          item.date,
                          size: 12,
                          color: appColors.textColor.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    color:
                        i < item.rating
                            ? appColors.primary.shade500
                            : appColors.textColor.shade100,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          10.verticalSpace,
          GenText(
            item.review,
            size: 12,
            color: appColors.textColor.shade300,
            height: 20,
          ),
        ],
      ),
    );
  }
}
