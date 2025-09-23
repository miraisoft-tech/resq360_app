// ignore_for_file: document_ignores

import 'package:resq360/__lib.dart';

class SVGButton extends StatelessWidget {
  const SVGButton({
    required this.path,
    required this.onTap,
    this.width,
    this.color,
    this.height,
    super.key,
  });
  final String path;
  final void Function() onTap;
  final double? width;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      // ignore: deprecated_member_use
      child: SvgPicture.asset(path, height: height, width: width, color: color),
    );
  }
}

// class WideButton extends StatelessWidget {
//   const WideButton({
//     required this.label,
//     this.onPressed,
//     this.width,
//     this.heigth,
//     this.backgroundColor,
//     this.loading = false,
//     this.textColor,
//     super.key,
//   });
//   final void Function()? onPressed;
//   final String label;
//   final double? width;
//   final double? heigth;
//   final bool loading;
//   final Color? backgroundColor;
//   final Color? textColor;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.appColors;

//     return SizedBox(
//       width: width ?? double.infinity,
//       height: heigth ?? 48.h,
//       child: TextButton(
//         style: TextButton.styleFrom(
//           backgroundColor:
//               onPressed == null
//                   ? const Color(0xffD9D9D9)
//                   : (backgroundColor ?? colors.remisLite.shade500),
//           disabledBackgroundColor: colors.textColor.shade300,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.r),
//           ),
//           side: BorderSide(color: colors.remisLite.shade100, width: 2),
//         ),
//         onPressed: () {
//           loading ? log('Tapped while loading') : onPressed?.call();
//         },
//         child:
//             loading
//                 ? SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 3,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       textColor ?? colors.remis.shade500,
//                     ),
//                   ),
//                 )
//                 : GenText(
//                   label,
//                   color:
//                       onPressed == null
//                           ? colors.remis.shade200
//                           : (textColor ?? colors.remis.shade500),
//                   weight: FontWeight.w600,
//                   height: 16.5,
//                 ),
//       ),
//     );
//   }
// }

// class IWideButton extends StatelessWidget {
//   const IWideButton({
//     required this.label,
//     this.onPressed,
//     this.width,
//     this.heigth,
//     this.loading = false,
//     this.textColor,
//     super.key,
//   });
//   final void Function()? onPressed;
//   final String label;
//   final double? width;
//   final double? heigth;
//   final bool loading;
//   final Color? textColor;

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.appColors;

//     return SizedBox(
//       width: width ?? double.infinity,
//       height: heigth ?? 48,
//       child: TextButton(
//         style: TextButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           disabledBackgroundColor: colors.textColor.shade300,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           side: BorderSide(color: colors.remisLite.shade100),
//         ),
//         onPressed: () {
//           loading ? log('Tapped while loading') : onPressed?.call();
//         },
//         child:
//             loading
//                 ? SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 3,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       textColor ?? colors.remis.shade500,
//                     ),
//                   ),
//                 )
//                 : SFText(
//                   label,
//                   color:
//                       onPressed == null
//                           ? colors.textColor.shade100
//                           : (textColor ?? colors.whiteColor),
//                   weight: FontWeight.w500,
//                   height: 19.8,
//                   size: 16,
//                 ),
//       ),
//     );
//   }
// }
