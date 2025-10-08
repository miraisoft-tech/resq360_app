import 'package:resq360/__lib.dart';
import 'package:resq360/features/provider/dashboard/screens/customer_details_screen.dart';

class ServiceRequests extends StatelessWidget {
  const ServiceRequests({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            UrbText(
              'Service Requests',
              size: 18,
              weight: FontWeight.w700,
              color: colors.black,
            ),
            4.horizontalSpace,
            Container(
              padding: pad(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.error.shade50,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: GenText(
                '4 new',
                size: 11,
                color: colors.error.shade500,
              ),
            ),
            const Spacer(),
            GenText(
              'View All',
              size: 13,
              color: colors.primary.shade500,
            ),
          ],
        ),
        20.verticalSpace,
        const _RequestTile(
          name: 'Jane Doe',
          service: 'Tow request',
          distance: '1.0 km Away',
        ),
        const _RequestTile(
          name: 'John Paul',
          service: 'Mechanic service',
          distance: '1.4 km Away',
        ),
      ],
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.name,
    required this.service,
    required this.distance,
  });

  final String name;
  final String service;
  final String distance;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: () async {
        await pushScreen(context, const CustomerDetailsScreen());
      },
      child: Container(
        padding: pad(horizontal: 12, vertical: 20),
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: colors.textColor.shade100),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
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
                Row(
                  children: [
                    GenText(name, weight: FontWeight.w400),
                    4.horizontalSpace,
                    GenText(
                      '($service)',
                      weight: FontWeight.w400,
                      color: colors.neutral.shade400,
                    ),
                  ],
                ),
                Row(
                  children: [
                    AppAssets.ASSETS_ICONS_LOCATION_SVG.svgColor(
                      color: colors.neutral.shade400,
                    ),
                    4.horizontalSpace,
                    GenText(
                      distance,
                      size: 12,
                      weight: FontWeight.w400,
                      color: colors.neutral.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
