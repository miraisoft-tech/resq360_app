import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/screens/settings_screen.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    required this.name,
    required this.address,
    required this.onTapAddress,
    this.profileImage,
    super.key,
  });

  final String name;
  final String address;
  final void Function() onTapAddress;
  final String? profileImage;
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            await pushScreen(context, const SettingsScreen());
          },
          child: PictureWidget(
            image: profileImage,
          ),
        ),
        10.horizontalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GenText(
              'Hello, $name 👋',
              size: 12,
              height: 20,
              weight: FontWeight.w400,
              color: colors.neutral.shade500,
            ),
            GestureDetector(
              onTap: onTapAddress,
              child: Row(
                children: [
                  AppAssets.ASSETS_ICONS_LOCATION_SVG.svg,
                  4.horizontalSpace,
                  SizedBox(
                    width: address.length > 10 ? 140.w : 30.w,
                    child: GenText(
                      address,
                      height: 24,
                      color: colors.black,
                      weight: FontWeight.w500,
                      maxLines: 1,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 14,
                    color: colors.textColor.shade500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
