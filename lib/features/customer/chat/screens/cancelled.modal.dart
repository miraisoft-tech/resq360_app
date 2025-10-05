import 'package:resq360/__lib.dart';

class CancelledModal extends ConsumerWidget {
  const CancelledModal({
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
          (MediaQuery.of(context).size.height * 0.5),
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
          AppAssets.ASSETS_IMAGES_CANCELLED_BOOKING_PNG.imageAsset(
            height: 110,
            width: 110,
          ),
          24.verticalSpace,
          GenText(
            'Cancelled!',
            color: appColors.black,
            size: 22,
            height: 32.5,
            weight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          GenText(
            'The balance will be added to your wallet',
            color: appColors.textColor.shade400,
            height: 20.5,
            weight: FontWeight.w500,
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
