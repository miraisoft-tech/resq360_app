import 'package:resq360/__lib.dart';

class EmptyScreenWidget extends StatelessWidget {
  const EmptyScreenWidget({
    required this.imagePath,
    required this.message,
    required this.subMessage,
    this.height = 100,
    super.key,
  });

  final String imagePath;
  final String message;
  final String subMessage;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: height.h),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imagePath.imageAsset(),
            2.verticalSpace,
            GenText(
              message,
              color: context.appColors.black,
              weight: FontWeight.w500,
              textAlign: TextAlign.center,
            ),
            8.verticalSpace,
            GenText(
              subMessage,
              size: 12,
              height: 16.5,
              textAlign: TextAlign.center,
              weight: FontWeight.w400,
              color: context.appColors.textColor.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
