import 'package:resq360/__lib.dart';
import 'package:resq360/features/dashboard/widgets/chip_widget.dart';
import 'package:resq360/features/dashboard/widgets/review_summary_card.dart';
import 'package:resq360/features/dashboard/widgets/user_review_card.dart';

class ServiceProviderDetailsScreen extends StatefulWidget {
  const ServiceProviderDetailsScreen({super.key});

  @override
  State<ServiceProviderDetailsScreen> createState() =>
      _ServiceProviderDetailsScreenState();
}

class _ServiceProviderDetailsScreenState
    extends State<ServiceProviderDetailsScreen> {
  int currentIndex = 0;

  final List<String> gallery = [
    'https://images.pexels.com/photos/6065924/pexels-photo-6065924.jpeg',
    'https://images.pexels.com/photos/4488662/pexels-photo-4488662.jpeg',
    'https://images.pexels.com/photos/4489730/pexels-photo-4489730.jpeg',
  ];

  final List<Map<String, dynamic>> reviews = [
    {
      'name': 'Maria Okoro',
      'avatar': 'https://randomuser.me/api/portraits/women/47.jpg',
      'rating': 5,
      'date': '1 day ago',
      'comment':
          'QuickTow Emergency is simply the best, they arrived in time and towed my vehicle to my destination. I would recommend their service',
    },
    {
      'name': 'Maria Okoro',
      'avatar': 'https://randomuser.me/api/portraits/women/47.jpg',
      'rating': 5,
      'date': '1 day ago',
      'comment':
          'QuickTow Emergency is simply the best, they arrived in time and towed my vehicle to my destination. I would recommend their service',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 260,
                  forceMaterialTransparency: true,
                  elevation: 0,
                  backgroundColor: colors.whiteColor,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: colors.black),
                    onPressed: () => pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView.builder(
                          itemCount: gallery.length,
                          onPageChanged: (i) {
                            setState(() => currentIndex = i);
                          },
                          itemBuilder: (_, index) {
                            return Image.network(
                              gallery[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        ),
                        Positioned(
                          bottom: 12,
                          child: Container(
                            padding: pad(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: GenText(
                              '${currentIndex + 1}/${gallery.length}',
                              color: colors.whiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: pad(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: pad(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.success.shade50,
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: GenText(
                            'Online',
                            size: 12,
                            color: colors.success.shade800,
                          ),
                        ),
                        15.verticalSpace,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                'https://randomuser.me/api/portraits/men/32.jpg',
                              ),
                            ),
                            12.horizontalSpace,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      UrbText(
                                        'QuickTow Emergency',
                                        height: 24.5,
                                        weight: FontWeight.w700,
                                        color: colors.black,
                                      ),
                                    ],
                                  ),
                                  6.verticalSpace,
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.orange,
                                      ),
                                      4.horizontalSpace,
                                      GenText(
                                        '4.8',
                                        size: 12,
                                        color: colors.black,
                                      ),
                                      2.horizontalSpace,
                                      GenText(
                                        '(127)',
                                        size: 12,
                                        color: colors.neutral.shade300,
                                      ),
                                      10.horizontalSpace,
                                      AppAssets.ASSETS_ICONS_LOCATION_SVG
                                          .svgColor(
                                            color: colors.neutral.shade300,
                                          ),
                                      2.horizontalSpace,
                                      GenText(
                                        '1.2km',
                                        size: 12,
                                        color: colors.neutral.shade300,
                                      ),
                                    ],
                                  ),
                                  8.verticalSpace,
                                ],
                              ),
                            ),

                            SVGButton(
                              path: AppAssets.ASSETS_ICONS_CHAT_ICON_SVG,
                              onTap: () {},
                            ),
                            15.horizontalSpace,
                            SVGButton(
                              path: AppAssets.ASSETS_ICONS_CALL_ICON_SVG,
                              onTap: () {},
                            ),
                            10.horizontalSpace,
                          ],
                        ),
                        10.verticalSpace,
                        const Wrap(
                          spacing: 8,
                          children: [
                            ChipWidget(label: 'Towing'),
                            ChipWidget(label: 'Mechanic'),
                            ChipWidget(label: 'Locksmith'),
                          ],
                        ),
                        30.verticalSpace,
                        GenText(
                          'Overview',
                          height: 24,
                          weight: FontWeight.w500,
                          color: colors.black,
                        ),
                        16.verticalSpace,
                        GenText(
                          'We offer 24/7 roadside and vehicle support including towing, maintenance, and professional locksmith solutions for homes, cars, and businesses fast, reliable, and always available when you need us.',
                          height: 22,
                          color: colors.textColor.shade500,
                        ),
                        16.verticalSpace,
                        Row(
                          children: [
                            AppAssets.ASSETS_ICONS_CALENDER_SVG.svg,
                            8.horizontalSpace,
                            GenText(
                              'Monday - Friday',
                              size: 13,
                              color: colors.black,
                            ),
                            20.horizontalSpace,
                            AppAssets.ASSETS_ICONS_CLOCK_SVG.svg,
                            8.horizontalSpace,
                            GenText(
                              '9:00 am - 5:00 pm',
                              size: 13,
                              color: colors.black,
                            ),
                          ],
                        ),
                        20.verticalSpace,
                        GenText(
                          'Services',
                          height: 20.5,
                          weight: FontWeight.w700,
                          color: colors.black,
                        ),
                        12.verticalSpace,
                        const _ServiceGroup(
                          title: 'Towing',
                          items: ['Emergency Roadside Tow'],
                        ),
                        const ListDivider(
                          verticalSpacing: 10,
                        ),
                        12.verticalSpace,
                        const _ServiceGroup(
                          title: 'Mechanic',
                          items: ['Car Facelifting', 'Wheel Balancing'],
                        ),
                        const ListDivider(
                          verticalSpacing: 10,
                        ),
                        12.verticalSpace,
                        const _ServiceGroup(
                          title: 'Locksmith',
                          items: [
                            'Car Key Replacement',
                            'Lock Installation',
                            'Smart Lock Setup',
                          ],
                        ),
                        20.verticalSpace,
                        UrbText(
                          'Review',
                          height: 20.5,
                          weight: FontWeight.w700,
                          color: colors.black,
                        ),
                        20.verticalSpace,
                        const ReviewSummaryCard(),
                        16.verticalSpace,
                        ...reviews.map((r) => UserReviewCard(data: r)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: pad(horizontal: 16, vertical: 10),
              child: WideButton(
                label: 'Book Now',
                onPressed: () {
                  log('Book Now pressed');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- SERVICES ----------
class _ServiceGroup extends StatelessWidget {
  const _ServiceGroup({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GenText(
          title,
          weight: FontWeight.w400,
          color: colors.textColor.shade400,
        ),
        6.verticalSpace,
        ...items.map(
          (e) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: Row(
              children: [
                const Text('• ', style: TextStyle(fontSize: 14)),
                GenText(
                  e,
                  weight: FontWeight.w400,
                  color: colors.textColor.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
