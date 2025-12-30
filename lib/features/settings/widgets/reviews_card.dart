import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/data/models/provider_ratings.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    required this.item,
    super.key,
  });

  final Review item;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final user = item.user;
    final category = item.serviceRequest?.serviceCategory;
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
                backgroundImage: NetworkImage(user?.profileImage ?? 'https://randomuser.me/api/portraits/men/30.jpg'),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GenText(
                      user?.fullName ?? 'N/A',
                      size: 15,
                      weight: FontWeight.w600,
                    ),
                    5.verticalSpace,
                    GenText(
                      category?.name ?? 'General',
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
                          item.ratingDate ?? 'N/A',
                          size: 12,
                          color: appColors.textColor.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.overallRating != null) ...[
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      Icons.star,
                      color:
                          i < item.overallRating!
                              ? appColors.primary.shade500
                              : appColors.textColor.shade100,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
          10.verticalSpace,
          GenText(
            item.feedback ?? '',
            size: 12,
            color: appColors.textColor.shade300,
            height: 20,
          ),
        ],
      ),
    );
  }
}
