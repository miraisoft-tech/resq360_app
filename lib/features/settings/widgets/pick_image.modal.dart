import 'package:resq360/__lib.dart';

class CameraModal extends StatelessWidget {
  const CameraModal({
    required this.onTapGallery,
    required this.onTapCamera,
    super.key,
  });
  final void Function() onTapGallery;
  final void Function() onTapCamera;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appColors;

    return Container(
      height: 330.h,
      padding: pad(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        color: appTheme.whiteColor,
      ),
      child: Col(
        children: [
          Center(
            child: Container(
              height: 5.h,
              width: 50.w,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(32),
                ),
                color: appTheme.neutral.shade300.withValues(alpha: 0.6),
              ),
            ),
          ),
          20.verticalSpace,
          Row(
            children: [
              GenText(
                'Profile Photo',
                color: appTheme.black,
                size: 20,
                height: 24,
                weight: FontWeight.w700,
              ),
              const Spacer(),
              SVGButton(
                path: AppAssets.ASSETS_ICONS_CLOSE_CIRCLE_SVG,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          30.verticalSpace,
          InkWell(
            onTap: onTapCamera,
            child: Row(
              children: [
                SvgPicture.asset(
                  AppAssets.ASSETS_ICONS_CAMERA_MODAL_SVG,
                  colorFilter: ColorFilter.mode(
                    appTheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                12.horizontalSpace,
                const GenText(
                  'Camera',
                  height: 20,
                  weight: FontWeight.w400,
                ),
              ],
            ),
          ),
          ListDivider(
            verticalSpacing: 25,
            color: appTheme.neutral.shade300,
            thickness: 0.5,
          ),
          InkWell(
            onTap: onTapGallery,
            child: Row(
              children: [
                SvgPicture.asset(
                  AppAssets.ASSETS_ICONS_GALLERY_MODAL_SVG,
                  colorFilter: ColorFilter.mode(
                    appTheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                12.horizontalSpace,
                const GenText(
                  'Gallery',
                  height: 20,
                  weight: FontWeight.w400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
