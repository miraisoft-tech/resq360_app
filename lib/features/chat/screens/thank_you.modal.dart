import 'package:resq360/__lib.dart';

class ThankYouModal extends ConsumerWidget {
  const ThankYouModal({
    required this.onContinuePressed,

    super.key,
  });

  final void Function() onContinuePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = context.appColors;

    return Container(
      width: double.infinity,
      height:
          MediaQuery.of(context).viewInsets.bottom +
          (MediaQuery.of(context).size.height * 0.55),
      decoration: BoxDecoration(
        color: appColors.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      padding: pad(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onContinuePressed,
              icon: Icon(Icons.close, color: appColors.black),
            ),
          ),
          AppAssets.ASSETS_IMAGES_THANK_YOU_PNG.imageAsset(
            height: 172,
            width: 172,
          ),
          24.verticalSpace,
          GenText(
            'Thank You For Your Patronage',
            color: appColors.black,
            size: 22,
            height: 32.5,
            weight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),

          50.verticalSpace,
          WideButton(
            label: 'Back to Home',
            onPressed: onContinuePressed,
          ),
        ],
      ),
    );
  }
}
