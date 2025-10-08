import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/screens/notification_screen.dart';
import 'package:resq360/features/customer/dashboard/screens/wallet_screen.dart';
import 'package:resq360/features/customer/dashboard/widgets/ongoing_service_widget.dart';
import 'package:resq360/features/customer/dashboard/widgets/recommended_card_widget.dart';
import 'package:resq360/features/customer/dashboard/widgets/service_category_widget.dart';
import 'package:resq360/features/customer/services/screens/service_categories_screen.dart';
import 'package:resq360/features/customer/services/screens/service_providers_screen.dart';
import 'package:resq360/features/widgets/inputs/filter_search_field.dart';
import 'package:resq360/features/widgets/promo_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.whiteColor,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 19,
              backgroundImage: AssetImage(
                AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG,
              ),
            ),
            10.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GenText(
                  'Hello, Jane 👋',
                  size: 12,
                  height: 20,
                  weight: FontWeight.w400,
                  color: colors.neutral.shade500,
                ),

                Row(
                  children: [
                    AppAssets.ASSETS_ICONS_LOCATION_SVG.svg,
                    4.horizontalSpace,
                    GenText(
                      'No. 2 Olympia Street',
                      height: 24,
                      color: colors.black,
                      weight: FontWeight.w500,
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: colors.textColor.shade500,
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
              await pushScreen(context, const WalletScreen());
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
          left: 16.w,
          right: 16.w,
          top: 10.h,
          bottom: 50.h,
        ),
        children: [
          10.verticalSpace,
          FilterSearchFormField(
            controller: TextEditingController(),
            hintText: 'Search for services',
            onTapSuffix: () {},
            onChanged: (value) {},
            prefixIconPath: AppAssets.ASSETS_ICONS_SEARCH_SVG,
          ),
          20.verticalSpace,
          const PromoCardWidget(),
          20.verticalSpace,
          UrbText(
            'Ongoing Service',
            size: 18,
            height: 28.5,
            weight: FontWeight.w700,
            color: colors.black,
          ),
          12.verticalSpace,
          const OngoingServiceCard(),
          20.verticalSpace,
          Row(
            children: [
              UrbText(
                'What service do you need?',
                size: 18,
                height: 28.5,
                weight: FontWeight.w700,
                color: colors.black,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await pushScreen(context, const ServiceCategoryScreen());
                },
                child: UrbText(
                  'View All',
                  size: 12,
                  height: 20.5,
                  weight: FontWeight.w400,
                  color: colors.primary.shade500,
                ),
              ),
            ],
          ),
          20.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ServiceCategoryWidget(
                icon: Icon(
                  Icons.local_shipping_outlined,
                  size: 28,
                  color: colors.primary.shade500,
                ),
                label: 'Towing',
              ),
              ServiceCategoryWidget(
                icon: Icon(
                  Icons.medical_services_outlined,
                  size: 28,
                  color: colors.primary.shade500,
                ),
                label: 'Ambulance',
              ),
              ServiceCategoryWidget(
                icon: Icon(
                  Icons.plumbing_outlined,
                  size: 28,
                  color: colors.primary.shade500,
                ),
                label: 'Plumbing',
              ),
            ],
          ),
          30.verticalSpace,
          Row(
            children: [
              UrbText(
                'Recommended for You',
                size: 18,
                height: 28.5,
                weight: FontWeight.w700,
                color: colors.black,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await pushScreen(context, const ServiceProvidersScreen());
                },
                child: UrbText(
                  'View All',
                  size: 12,
                  height: 20.5,
                  weight: FontWeight.w400,
                  color: colors.primary.shade500,
                ),
              ),
            ],
          ),
          12.verticalSpace,
          const RecommendedCard(),
          30.verticalSpace,
        ],
      ),
    );
  }
}
