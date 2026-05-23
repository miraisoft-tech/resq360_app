import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/data/models/customer_ratings_model.dart';

class UserReviewCard extends StatelessWidget {
  const UserReviewCard({required this.data, super.key});
  final CustomerReview data;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final date = DateTime.parse(data.ratingDate!);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: pad(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: colors.whiteColor,
        border: Border.all(color: colors.lightGreyColor2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PictureWidget(image: data.provider?.profileImage),
              10.horizontalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UrbText(
                    data.provider?.fullName ?? '',
                    weight: FontWeight.w600,
                    color: colors.black,
                  ),
                  Row(
                    children: List.generate(
                      data.overallRating ?? 0,
                      (index) => const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GenText(
                date.formatDate,
                size: 12,
                color: colors.textColor.shade500,
              ),
            ],
          ),
          10.verticalSpace,
          GenText(
            data.feedback.toString(),
            height: 20,
            weight: FontWeight.w400,
            color: colors.textColor.shade400,
          ),
        ],
      ),
    );
  }
}
