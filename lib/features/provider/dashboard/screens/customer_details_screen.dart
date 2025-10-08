import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/widgets/review_summary_card.dart';
import 'package:resq360/features/customer/dashboard/widgets/user_review_card.dart';
import 'package:resq360/features/provider/chat/screens/provider_chat_details_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({super.key});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
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
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        backgroundColor: appColors.whiteColor,
        forceMaterialTransparency: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => pop(context),
          icon: AppAssets.ASSETS_ICONS_BACK_ICON_SVG.svg,
        ),
        centerTitle: true,
        title: UrbText(
          'Client Profile',
          size: 22,
          height: 32.5,
          weight: FontWeight.w700,
          color: appColors.textColor.shade800,
        ),
        actions: const [SizedBox(width: 40)],
      ),
      body: SafeArea(
        child: Padding(
          padding: pad(horizontal: 16, vertical: 10),
          child: Col(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage(
                      AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
                    ),
                  ),
                  10.horizontalSpace,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GenText(
                        'Jane Doe',
                        weight: FontWeight.w500,
                        color: appColors.black,
                      ),
                      5.horizontalSpace,
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          4.horizontalSpace,
                          GenText(
                            '4.8',
                            size: 12,
                            color: appColors.textColor.shade400,
                          ),
                          GenText(
                            '(50)',
                            size: 12,
                            color: appColors.neutral.shade300,
                          ),
                          10.horizontalSpace,
                          AppAssets.ASSETS_ICONS_LOCATION_SVG.svgColor(
                            color: appColors.neutral.shade400,
                          ),
                          4.horizontalSpace,
                          GenText(
                            '1.0km away',
                            size: 12,
                            weight: FontWeight.w400,
                            color: appColors.neutral.shade400,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              30.verticalSpace,
              UrbText(
                'Review',
                height: 20.5,
                weight: FontWeight.w700,
                color: appColors.black,
              ),
              20.verticalSpace,
              const ReviewSummaryCard(),
              30.verticalSpace,
              ...reviews.map((r) => UserReviewCard(data: r)),
              const Spacer(),
              WideButton(
                label: 'Chat with Client',
                onPressed: () async {
                  await pushScreen(context, const ProviderChatDetailScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
