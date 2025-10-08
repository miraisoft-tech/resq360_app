import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/screens/notification_screen.dart';
import 'package:resq360/features/provider/dashboard/screens/promote_service_screen.dart';
import 'package:resq360/features/provider/dashboard/screens/provider_wallet_screen.dart';
import 'package:resq360/features/provider/dashboard/widgets/provider_account_progress.dart';
import 'package:resq360/features/provider/dashboard/widgets/provider_ongoing_service.dart';
import 'package:resq360/features/provider/dashboard/widgets/provider_stats_card.dart';
import 'package:resq360/features/provider/dashboard/widgets/provider_todo.dart';
import 'package:resq360/features/provider/dashboard/widgets/service_requests.dart';
import 'package:resq360/features/widgets/promo_card_widget.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: colors.whiteColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(
                AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
              ),
            ),
            10.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GenText(
                  'Hello, David 👋',
                  size: 12,
                  color: colors.textColor.shade600,
                ),
                8.horizontalSpace,
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.success.shade50,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          GenText(
                            'Active',
                            size: 12,
                            color: colors.success.shade600,
                            weight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                    8.horizontalSpace,
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    GenText(
                      '4.9',
                      size: 12,
                      weight: FontWeight.w400,
                      color: colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: AppAssets.ASSETS_ICONS_WALLET_SVG.svg,
            onPressed: () async {
              await pushScreen(context, const ProviderWalletScreen());
            },
          ),
          IconButton(
            icon: AppAssets.ASSETS_ICONS_NOTIFICATION_SVG.svg,
            onPressed: () async {
              await pushScreen(context, const NotificationScreen());
            },
          ),
          10.horizontalSpace,
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(
          top: 20.h,
          left: 16.w,
          right: 16.w,
          bottom: 100.h,
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ProviderStatsCard(
                title: 'Engagement',
                value: '246',
                icon: AppAssets.ASSETS_ICONS_ENGAGEMENT_ICON_SVG,
              ),
              16.horizontalSpace,
              const ProviderStatsCard(
                title: 'Revenue',
                value: '₦12,000',
                icon: AppAssets.ASSETS_ICONS_REVENUE_ICON_SVG,
              ),
            ],
          ),
          20.verticalSpace,
          const PromoCardWidget(),
          30.verticalSpace,
          const ProviderAccountProgress(),
          30.verticalSpace,
          const ToDoSection(),
          30.verticalSpace,
          const ProviderOngoingService(),
          30.verticalSpace,
          Container(
            padding: pad(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: colors.error.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: UrbText(
              '⏳ Promotion ends in 6hrs-45mins',
              color: colors.black,
              weight: FontWeight.w700,
              size: 16,
            ),
          ),
          30.verticalSpace,
          const ServiceRequests(),
          20.verticalSpace,
          Container(
            padding: pad(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.error.shade50,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GenText(
                  'You can reach more clients if you promote your page, your page will be displayed to all clients for 24hrs.',
                  height: 24.5,
                  color: colors.black,
                ),
                10.verticalSpace,
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary.shade500,
                    padding: pad(horizontal: 14, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () async {
                    await pushScreen(context, const PromoteServiceScreen());

                    // await GeneralDialogs.showCustomDialog(
                    //   context,
                    //   body: const ServiceRequestNotification(),
                    // );
                  },
                  child: const GenText(
                    'Promote Page',
                    color: Colors.white,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          20.verticalSpace,
          Container(
            padding: pad(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: colors.primary.shade500),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GenText(
                    'Boost your visibility and attract more clients with our 10% off promotion package. Don’t miss this chance to grow your business',
                    size: 12,
                    height: 20.5,
                    color: colors.black,
                  ),
                ),
                8.horizontalSpace,
                AppAssets.ASSETS_IMAGES_SPEAKER_ICON_PNG.imageAsset(
                  width: 120.w,
                  height: 80.h,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
