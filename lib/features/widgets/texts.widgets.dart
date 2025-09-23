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
        fontFamily: 'mono_sans',
        fontWeight: weight ?? FontWeight.w400,
        fontSize: size.sp,
        color: color ?? context.appColors.textColor.shade500,
        decoration: decoration,
        height: height / size,
        fontStyle: fontStyle,
        decorationColor: color,
        letterSpacing: letterSpacing ?? 0,
      ),
    );
  }
}

class SFText extends ConsumerWidget {
  const SFText(
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontFamily: 'sfpro',
        fontWeight: weight ?? FontWeight.w400,
        fontSize: size.sp,
        color: color ?? context.appColors.remisLite.shade100,
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

// class MilText extends ConsumerWidget {
//   const MilText(
//     this.text, {
//     super.key,
//     this.weight,
//     this.height = 17.71,
//     this.size = 14,
//     this.color,
//     this.textAlign,
//     this.maxLines,
//     this.decoration,
//     this.fontStyle,
//   });
//   final String text;
//   final FontWeight? weight;
//   final double size;
//   final double height;
//   final Color? color;
//   final TextAlign? textAlign;
//   final int? maxLines;
//   final TextDecoration? decoration;
//   final FontStyle? fontStyle;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final appTheme = ref.watch(appThemeProvider);
//     return Text(
//       text,
//       maxLines: maxLines,
//       textAlign: textAlign,
//       overflow: maxLines != null ? TextOverflow.ellipsis : null,
//       style: TextStyle(
//         fontFamily: 'millik',
//         fontWeight: weight ?? FontWeight.w400,
//         fontSize: size.sp,
//         color: color ?? appTheme.neutral.c500,
//         decoration: decoration,
//         height: height / size,
//         fontStyle: fontStyle,
//         decorationColor: color,
//       ),
//     );
//   }
// }

// TextSpan satoshiSTDTextSpan(
//   String text, {
//   required double size,
//   required double height,
//   FontWeight? weight,
//   Color? color,
//   TextAlign? textAlign,
//   int? maxLines,
//   TextDecoration? decoration,
//   void Function()? onTap,
// }) {
//   return TextSpan(
//     text: text,
//     recognizer: TapGestureRecognizer()..onTap = onTap,
//     style: TextStyle(
//       fontFamily: 'satoshi',
//       fontWeight: weight ?? FontWeight.w400,
//       fontSize: size,
//       color: color,
//       decoration: decoration,
//       height: height / size,
//       decorationColor: color,
//     ),
//   );
// }

// TextSpan milTextSpan(
//   String text, {
//   FontWeight? weight,
//   double size = 14,
//   double? height,
//   Color? color,
//   TextAlign? textAlign,
//   int? maxLines,
//   TextDecoration? decoration,
//   void Function()? onTap,
// }) {
//   return TextSpan(
//     text: text,
//     recognizer: TapGestureRecognizer()..onTap = onTap,
//     style: TextStyle(
//       fontFamily: 'millik',
//       fontWeight: weight,
//       fontSize: size,
//       color: color,
//       decoration: decoration,
//       height: height?.toFigmaHeight(size),
//     ),
//   );
// }

// class ElevatedDecimalText extends StatelessWidget {
//   const ElevatedDecimalText({
//     required this.text,
//     required this.size,
//     this.fontFamily,
//     this.color = Colors.black,
//     super.key,
//   });

//   final String text;
//   final double size;
//   final Color color;
//   final String? fontFamily;

//   @override
//   Widget build(BuildContext context) {
//     final parts = text.split('.');
//     final wholePart = parts[0];
//     final decimalPart = parts.length > 1 ? parts[1] : '';

//     return RichText(
//       text: TextSpan(
//         style: TextStyle(color: color, fontSize: size),
//         children: [
//           milTextSpan(wholePart, size: size),
//           if (decimalPart.isNotEmpty)
//             WidgetSpan(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   MilText('.', size: size, height: size, color: color),
//                   Padding(
//                     padding: EdgeInsets.only(bottom: 10.h),
//                     child: MilText(
//                       decimalPart,
//                       size: size - 4,
//                       height: size - 10,
//                       color: color,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class ElevatedDecimalLiterText extends StatelessWidget {
//   const ElevatedDecimalLiterText({
//     required this.text,
//     required this.size,
//     this.color = Colors.black,
//     super.key,
//   });

//   final String text;
//   final double size;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     final parts = text.split('.');
//     final wholePart = parts[0];
//     final decimalPart = parts.length > 1 ? parts[1] : '';

//     return RichText(
//       text: TextSpan(
//         style: TextStyle(
//           color: color,
//           fontSize: size,
//           fontWeight: FontWeight.w700,
//         ),
//         children: [
//           satoshiSTDTextSpan(
//             wholePart,
//             size: size,
//             height: 16,
//             weight: FontWeight.w700,
//           ),
//           if (decimalPart.isNotEmpty)
//             WidgetSpan(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   GenText(
//                     '.',
//                     height: size - 10,
//                     color: color,
//                     weight: FontWeight.w700,
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(bottom: 10.h),
//                     child: GenText(
//                       decimalPart,
//                       size: size - 4,
//                       height: size - 4,
//                       color: color,
//                       weight: FontWeight.w700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class SFElevatedDecimalText extends StatelessWidget {
//   const SFElevatedDecimalText({
//     required this.text,
//     required this.size,
//     this.fontFamily,
//     this.color = Colors.black,
//     super.key,
//   });

//   final String text;
//   final double size;
//   final Color color;
//   final String? fontFamily;

//   @override
//   Widget build(BuildContext context) {
//     final parts = text.split('.');
//     final wholePart = parts[0];
//     final decimalPart = parts.length > 1 ? parts[1] : '';

//     return RichText(
//       text: TextSpan(
//         style: TextStyle(color: color, fontSize: size),
//         children: [
//           TextSpan(
//             text: wholePart,
//             style: TextStyle(
//               fontFamily: 'sfpro',
//               fontSize: size,
//               color: color,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           if (decimalPart.isNotEmpty)
//             WidgetSpan(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   SFText(
//                     '.',
//                     size: size,
//                     color: color,
//                     height: 16,
//                     weight: FontWeight.w600,
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(bottom: 10.h),
//                     child: SFText(
//                       decimalPart,
//                       size: size - 4,
//                       height: size - 5,
//                       color: color,
//                       weight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
