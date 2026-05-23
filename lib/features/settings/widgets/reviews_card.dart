import 'package:resq360/__lib.dart';

class ReviewCardShared extends StatelessWidget {
  const ReviewCardShared({
    required this.name,
    required this.avatar,
    required this.category,
    required this.date,
    required this.rating,
    required this.feedback,
    super.key,
  });

  final String name;
  final String avatar;
  final String category;
  final String date;
  final int rating;
  final String feedback;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: pad(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.textColor.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 25.r, backgroundImage: NetworkImage(avatar)),

              12.horizontalSpace,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GenText(name, size: 15, weight: FontWeight.w600),

                    5.verticalSpace,

                    GenText(
                      category,
                      size: 12,
                      color: colors.textColor.shade300,
                    ),

                    5.verticalSpace,

                    Row(
                      children: [
                        AppAssets.ASSETS_ICONS_CALENDER_SVG.svgColor(
                          color: colors.textColor.shade300,
                        ),
                        5.horizontalSpace,
                        GenText(
                          date,
                          size: 12,
                          color: colors.textColor.shade400,
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
                        i < rating
                            ? colors.primary.shade500
                            : colors.textColor.shade100,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),

          12.verticalSpace,

          GenText(
            feedback,
            size: 12,
            color: colors.textColor.shade400,
            height: 19,
          ),
        ],
      ),
    );
  }
}
