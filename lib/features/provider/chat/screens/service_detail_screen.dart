import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/chat/screens/payment_appeal.dialog.dart';
import 'package:resq360/features/customer/chat/screens/service_cancelled_screen.dart';
import 'package:resq360/features/customer/chat/screens/service_completed_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        title: UrbText(
          'Service Detail',
          color: appColors.black,
          weight: FontWeight.w700,
          size: 22,
          height: 32.5,
        ),
        forceMaterialTransparency: true,
        centerTitle: true,
        elevation: 0,
        backgroundColor: appColors.whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 50.h,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: pad(horizontal: 10, vertical: 20),
              decoration: BoxDecoration(
                color: appColors.whiteColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: appColors.textColor.shade100),
              ),
              child: Row(
                children: [
                  AppAssets.ASSETS_ICONS_SEVICE_CONFIRMED_SVG.svg,
                  12.horizontalSpace,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GenText(
                        'Service Confirmed',
                        weight: FontWeight.w500,
                        color: appColors.black,
                      ),
                      2.verticalSpace,
                      GenText(
                        'The driver is preparing to depart...',
                        color: appColors.textColor.shade400,
                        size: 12,
                        height: 20.5,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            16.verticalSpace,
            _ServiceCard(
              name: 'QuickTow Emergency',
              subtitle: 'Towing Service',
              rating: '4.9',
              reviewCount: '(347 reviews)',
              avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG.imageAsset(),
              showActions: true,
            ),
            12.verticalSpace,
            _ServiceCard(
              name: 'Jane Doe',
              subtitle: '1.0km away',
              rating: '4.8',
              reviewCount: '(50 reviews)',
              avatar: AppAssets.ASSETS_IMAGES_PROFILE_PIC_PNG.imageAsset(),
            ),
            16.verticalSpace,
            Container(
              width: double.infinity,
              padding: pad(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: appColors.textColor.shade100),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GenText(
                        'Invoice No.',
                        color: appColors.textColor.shade400,
                        size: 13,
                      ),
                      GenText(
                        'Total Cost',
                        color: appColors.textColor.shade400,
                        size: 13,
                      ),
                    ],
                  ),
                  2.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GenText(
                        '#INV-238777',
                        color: appColors.black,
                        weight: FontWeight.w500,
                      ),
                      GenText(
                        '₦15,000',
                        color: appColors.black,
                        weight: FontWeight.w500,
                      ),
                    ],
                  ),
                  12.verticalSpace,
                  GenText(
                    'Location Detail',
                    color: appColors.textColor.shade400,
                    size: 13,
                  ),
                  2.verticalSpace,
                  GenText(
                    'Gwarimpa highway - Olympia Street',
                    color: appColors.black,
                    weight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: WideButton(
                    label: 'Appeal',
                    backgroundColor: appColors.primary.shade50,
                    textColor: appColors.primary.shade500,
                    onPressed: () async {
                      await GeneralDialogs.showCustomDialog(
                        context,
                        body: const PaymentAppealDialog(),
                      );
                    },
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: WideButton(
                    label: 'Complete',
                    backgroundColor: appColors.primary.shade500,
                    textColor: appColors.whiteColor,
                    onPressed: () async {
                      await pushScreen(context, const ServiceCompletedScreen());
                    },
                  ),
                ),
              ],
            ),
            5.verticalSpace,
            WideButton(
              label: 'Cancel',
              backgroundColor: appColors.primary.shade50,
              textColor: appColors.primary.shade500,
              onPressed: () async {
                await pushScreen(context, const ServiceCancelledScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.reviewCount,
    required this.avatar,
    this.showActions = false,
  });

  final String name;
  final String subtitle;
  final String rating;
  final String reviewCount;
  final Widget avatar;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      padding: pad(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: appColors.textColor.shade100),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 24, child: avatar),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GenText(
                  name,
                  weight: FontWeight.w500,
                  color: appColors.black,
                ),
                2.verticalSpace,
                GenText(
                  subtitle,
                  color: appColors.textColor.shade400,
                  size: 12,
                  height: 20.5,
                ),
                2.verticalSpace,
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    4.horizontalSpace,
                    GenText(
                      rating,
                      size: 12,
                      color: appColors.textColor.shade400,
                    ),
                    GenText(
                      reviewCount,
                      size: 12,
                      color: appColors.neutral.shade300,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showActions) ...[
            8.horizontalSpace,

            SVGButton(path: AppAssets.ASSETS_ICONS_CHAT_ICON_SVG, onTap: () {}),
            8.horizontalSpace,
            SVGButton(
              path: AppAssets.ASSETS_ICONS_CALL_ICON_SVG,
              onTap: () {},
              color: appColors.primary.shade500,
            ),
          ],
        ],
      ),
    );
  }
}
