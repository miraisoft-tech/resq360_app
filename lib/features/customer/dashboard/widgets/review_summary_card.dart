import 'package:resq360/__lib.dart';
import 'package:resq360/core/theme/app_color_theme.dart';

class ReviewSummaryCard extends StatelessWidget {
  const ReviewSummaryCard({
    required this.averageRating,
    required this.totalReviews,
    super.key,
    this.starCounts,
  });

  final double averageRating;

  final int totalReviews;

  final Map<int, int>? starCounts;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    //  final total = totalReviews == 0 ? 1 : totalReviews;
    // final starPercents = List<double>.generate(
    //   5,
    //   (i) {
    //     final star = 5 - i;
    //     final count = starCounts?[star] ?? 0;
    //     return count / total;
    //   },
    // );

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Col(
            children: [
              Padding(
                padding: pad(horizontal: 20),
                child: GenText(
                  averageRating.toStringAsFixed(1),
                  size: 24,
                  weight: FontWeight.w500,
                  color: colors.black,
                  textAlign: TextAlign.center,
                ),
              ),
              5.verticalSpace,

              Row(children: _buildStars(averageRating, colors)),
              5.verticalSpace,

              Padding(
                padding: pad(horizontal: 25),
                child: GenText(
                  '($totalReviews)',
                  size: 13,
                  color: colors.greyColor2,
                ),
              ),
            ],
          ),

          15.horizontalSpace,

          // Expanded(
          //   child: Column(
          //     children: starPercents
          //         .map((value) => _buildProgress(colors, value))
          //         .toList(),
          //   ),
          // )
        ],
      ),
    );
  }
}

List<Widget> _buildStars(double rating, AppColorPalette colors) {
  final icons = <Widget>[];

  for (var i = 1; i <= 5; i++) {
    if (rating >= i) {
      icons.add(Icon(Icons.star, color: colors.primary.shade400, size: 18));
    } else if (rating >= i - 0.5) {
      icons.add(
        Icon(Icons.star_half, color: colors.primary.shade400, size: 18),
      );
    } else {
      icons.add(
        Icon(Icons.star_border, color: colors.primary.shade400, size: 18),
      );
    }
  }

  return icons;
}

Widget buildProgress(AppColorPalette colors, double value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: LinearProgressIndicator(
      borderRadius: BorderRadius.circular(8.r),
      value: value,
      backgroundColor: colors.lightGreyColor3,
      valueColor: AlwaysStoppedAnimation<Color>(colors.primary.shade400),
      minHeight: 4,
    ),
  );
}
