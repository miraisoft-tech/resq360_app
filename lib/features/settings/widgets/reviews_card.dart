import 'package:resq360/__lib.dart';

class ReviewCardShared<T> extends StatelessWidget {
  const ReviewCardShared({
    required this.item,
    required this.getName,
    required this.getAvatar,
    required this.getCategory,
    required this.getDate,
    required this.getRating,
    required this.getFeedback,
    super.key,

  });

  final T item;

  final String Function(T) getName;
  final String Function(T) getAvatar;
  final String Function(T) getCategory;
  final String Function(T) getDate;
  final int Function(T) getRating;
  final String Function(T) getFeedback;

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
              CircleAvatar(
                radius: 25.r,
                backgroundImage: NetworkImage(getAvatar(item)),
              ),

              12.horizontalSpace,

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GenText(
                      getName(item),
                      size: 15,
                      weight: FontWeight.w600,
                    ),

                    5.verticalSpace,

                    GenText(
                      getCategory(item),
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
                          getDate(item),
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
                    color: i < getRating(item)
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
            getFeedback(item),
            size: 12,
            color: colors.textColor.shade400,
            height: 19,
          ),
        ],
      ),
    );
  }
}
