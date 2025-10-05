import 'package:resq360/__lib.dart';

class UserReviewCard extends StatelessWidget {
  const UserReviewCard({required this.data, super.key});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(data['avatar'] as String),
              ),
              10.horizontalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UrbText(
                    data['name'] as String,
                    weight: FontWeight.w600,
                    color: colors.black,
                  ),
                  Row(
                    children: List.generate(
                      data['rating'] as int,
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
                data['date'] as String,
                size: 12,
                color: colors.textColor.shade500,
              ),
            ],
          ),
          10.verticalSpace,
          GenText(
            data['comment'] as String,
            height: 20,
            weight: FontWeight.w400,
            color: colors.textColor.shade400,
          ),
        ],
      ),
    );
  }
}
