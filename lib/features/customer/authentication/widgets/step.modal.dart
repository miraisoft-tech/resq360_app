import 'package:resq360/__lib.dart';

class StepModal extends ConsumerWidget {
  const StepModal({
    required this.onContinuePressed,
    required this.title,
    required this.description,
    required this.icon,
    this.buttonText = 'Continue',
    super.key,
  });

  final String title;
  final String description;
  final String icon;
  final String buttonText;
  final void Function() onContinuePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = context.appColors;

    return Container(
      width: double.infinity,
      height:
          MediaQuery.of(context).viewInsets.bottom +
          (MediaQuery.of(context).size.height * 0.52),
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
          icon.imageAsset(),
          24.verticalSpace,
          GenText(
            title,
            color: appColors.black,
            size: 22,
            height: 32.5,
            weight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          5.verticalSpace,
          GenText(
            description,
            color: appColors.textColor.shade300,
            height: 24.5,
            weight: FontWeight.w400,
            textAlign: TextAlign.center,
          ),
          50.verticalSpace,
          WideButton(
            label: buttonText,
            onPressed: onContinuePressed,
          ),
        ],
      ),
    );
  }
}
