import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/settings/data/models/reviews_model.dart';
import 'package:resq360/features/customer/settings/widgets/reviews_card.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final reviews = [
      ReviewModel(
        name: 'QuickTow Emergency',
        category: 'Towing Service',
        date: 'Aug 12, 2025',
        rating: 5,
        review:
            'Jane Doe was an easy client, we had no back and forth and she trusted me to do the job right.',
        avatar: 'https://randomuser.me/api/portraits/men/30.jpg',
      ),
      ReviewModel(
        name: 'Homify',
        category: 'Cleaning Service',
        date: 'Aug 12, 2025',
        rating: 3,
        review:
            'An easy going client, no arguments whatsoever, I had a smooth working experience.',
        avatar: 'https://randomuser.me/api/portraits/men/30.jpg',
      ),
      ReviewModel(
        name: 'The Johnson’s',
        category: 'Locksmith',
        date: 'Aug 12, 2025',
        rating: 3,
        review:
            'An easy going client, no arguments whatsoever, I had a smooth working experience.',
        avatar: 'https://randomuser.me/api/portraits/men/30.jpg',
      ),
    ];

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        backgroundColor: appColors.whiteColor,
        forceMaterialTransparency: true,
        title: const GenText(
          'Rating',
          size: 18,
          weight: FontWeight.w700,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        foregroundColor: appColors.black,
      ),
      body: Padding(
        padding: pad(horizontal: 20, vertical: 16),
        child: ListView(
          children: [
            const _RatingSummary(),
            20.verticalSpace,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (_, _) => 14.verticalSpace,
              itemBuilder: (context, index) {
                final item = reviews[index];
                return ReviewCard(item: item);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary();

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    final ratings = {
      5: 4,
      4: 2,
      3: 1,
      2: 0,
      1: 0,
    };

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: appColors.primary.shade500, size: 15),
            2.horizontalSpace,
            GenText(
              '4.4',
              size: 20,
              weight: FontWeight.w700,
              color: appColors.black,
            ),
          ],
        ),
        4.verticalSpace,
        GenText(
          'Based on 7 reviews',
          color: appColors.textColor.shade300,
          size: 12,
        ),
        20.verticalSpace,
        Column(
          children:
              ratings.entries.map((e) {
                final percentage = e.value / 4;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 20),
                  child: Row(
                    children: [
                      GenText('${e.key}', color: appColors.black, size: 13),
                      4.horizontalSpace,
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      6.horizontalSpace,
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: appColors.textColor.shade100,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percentage,
                              child: Container(
                                height: 6.h,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      6.horizontalSpace,
                      GenText('${e.value}', size: 13),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
