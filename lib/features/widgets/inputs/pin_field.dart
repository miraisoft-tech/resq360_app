import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:resq360/__lib.dart';

class NormalPinCodeField extends ConsumerWidget {
  const NormalPinCodeField({
    required this.onDone,
    this.onChange,
    this.controller,
    this.hideCharacter = false,
    this.height,
    this.width,
    super.key,
  });

  final void Function(String)? onDone;
  final void Function(String)? onChange;
  final bool hideCharacter;
  final TextEditingController? controller;
  final double? height;
  final double? width;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    return Center(
      child: PinCodeTextField(
        autofocus: true,
        hideCharacter: hideCharacter,
        pinBoxBorderWidth: 1,
        controller: controller,
        maxLength: 6,
        pinBoxDecoration: (
          Color borderColor,
          Color boxColor, {
          double? borderWidth,
          double? radius,
        }) {
          return BoxDecoration(
            color: boxColor,
            border: Border.all(color: colors.lightGreyColor2),
            borderRadius: BorderRadius.circular(8.r),
          );
        },
        pinBoxColor: colors.whiteColor,
        highlightPinBoxColor: colors.whiteColor,
        defaultBorderColor: Colors.transparent,
        hasTextBorderColor: colors.black,
        pinBoxRadius: 16.r,
        pinBoxWidth: width ?? 45.w,
        pinBoxHeight: height ?? 45.h,
        wrapAlignment: WrapAlignment.center,
        pinTextStyle: TextStyle(
          fontFamily: 'mono_sans',
          fontWeight: FontWeight.w600,
          fontSize: 15.sp,
          color: colors.black,
          height: 24.0.toFigmaHeight(24.sp),
        ),
        onTextChanged: onChange,
        onDone: onDone,
        pinTextAnimatedSwitcherTransition:
            ProvidedPinBoxTextAnimation.scalingTransition,
        pinTextAnimatedSwitcherDuration: const Duration(milliseconds: 300),
        highlightAnimationBeginColor: Colors.black,
        highlightAnimationEndColor: Colors.white12,
        pinBoxOuterPadding: const EdgeInsets.all(4.5),
      ),
    );
  }
}

class PinCodeField extends ConsumerWidget {
  const PinCodeField({
    required this.onDone,
    this.onChange,
    this.controller,
    this.hideCharacter = false,
    this.height,
    this.width,
    super.key,
  });

  final void Function(String)? onDone;
  final void Function(String)? onChange;
  final bool hideCharacter;
  final TextEditingController? controller;
  final double? height;
  final double? width;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    return PinCodeTextField(
      autofocus: true,
      hideCharacter: hideCharacter,
      pinBoxBorderWidth: 1,
      controller: controller,
      pinBoxDecoration: (
        Color borderColor,
        Color boxColor, {
        double? borderWidth,
        double? radius,
      }) {
        return BoxDecoration(
          color: boxColor,
          border: Border.all(color: colors.lightGreyColor2),
          borderRadius: BorderRadius.circular(8.r),
        );
      },
      pinBoxColor: colors.whiteColor,
      highlightPinBoxColor: colors.whiteColor,
      defaultBorderColor: Colors.transparent,
      hasTextBorderColor: colors.black,
      pinBoxRadius: 16.r,
      pinBoxWidth: width ?? 48.w,
      pinBoxHeight: height ?? 48.h,
      wrapAlignment: WrapAlignment.center,
      pinTextStyle: TextStyle(
        fontFamily: 'mono_sans',
        fontWeight: FontWeight.w600,
        fontSize: 15.sp,
        color: colors.black,
        height: 24.0.toFigmaHeight(24.sp),
      ),
      onTextChanged: onChange,
      onDone: onDone,
      pinTextAnimatedSwitcherTransition:
          ProvidedPinBoxTextAnimation.scalingTransition,
      pinTextAnimatedSwitcherDuration: const Duration(milliseconds: 300),
      highlightAnimationBeginColor: Colors.black,
      highlightAnimationEndColor: Colors.white12,
      pinBoxOuterPadding: const EdgeInsets.all(5),
    );
  }
}
