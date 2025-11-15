import 'package:flutter/gestures.dart';
import 'package:resq360/__lib.dart';

extension FigmaDimention on double {
  double toFigmaHeight(double fontSize) {
    return this / fontSize;
  }
}

class GenText extends StatelessWidget {
  const GenText(
    this.text, {
    super.key,
    this.weight,
    this.height = 17.71,
    this.size = 14,
    this.color,
    this.textAlign,
    this.maxLines,
    this.decoration,
    this.fontStyle,
    this.letterSpacing,
  });
  final String text;
  final FontWeight? weight;
  final double size;
  final double height;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextDecoration? decoration;
  final FontStyle? fontStyle;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontFamily: 'inter',
        fontWeight: weight ?? FontWeight.w400,
        fontSize: size.sp,
        color: color ?? context.appColors.black,
        decoration: decoration,
        height: height / size,
        fontStyle: fontStyle,
        decorationColor: color,
        letterSpacing: letterSpacing ?? 0,
      ),
    );
  }
}

class UrbText extends StatelessWidget {
  const UrbText(
    this.text, {
    super.key,
    this.weight,
    this.height = 17.71,
    this.size = 14,
    this.color,
    this.textAlign,
    this.maxLines,
    this.decoration,
    this.fontStyle,
  });
  final String text;
  final FontWeight? weight;
  final double size;
  final double height;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextDecoration? decoration;
  final FontStyle? fontStyle;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontFamily: 'urbanist',
        fontWeight: weight ?? FontWeight.w400,
        fontSize: size.sp,
        color: color ?? context.appColors.primary.shade100,
        decoration: decoration,
        height: height / size,
        fontStyle: fontStyle,
        decorationColor: color,
        letterSpacing: 0,
      ),
    );
  }
}

TextSpan circularSTDTextSpan(
  String text, {
  FontWeight? weight,
  double? size,
  Color? color,
  TextAlign? textAlign,
  int? maxLines,
  TextDecoration? decoration,
  void Function()? onTap,
}) {
  return TextSpan(
    text: text,
    recognizer: TapGestureRecognizer()..onTap = onTap,
    style: TextStyle(
      fontFamily: 'circular',
      fontWeight: weight,
      fontSize: size,
      color: color,
      overflow: TextOverflow.fade,
      decoration: decoration,
    ),
  );
}

TextSpan sfTextSpan(
  String text, {
  FontWeight? weight,
  double size = 14,
  double? height,
  Color? color,
  TextAlign? textAlign,
  int? maxLines,
  TextDecoration? decoration,
  void Function()? onTap,
}) {
  return TextSpan(
    text: text,
    recognizer: TapGestureRecognizer()..onTap = onTap,
    style: TextStyle(
      fontFamily: 'sfpro',
      fontWeight: weight,
      fontSize: size,
      color: color,
      decoration: decoration,
      height: height?.toFigmaHeight(size),
    ),
  );
}
