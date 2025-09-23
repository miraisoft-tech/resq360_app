// // ignore_for_file: deprecated_member_use, document_ignores

// import 'package:remis_b2c/__lib.dart';

// class GeneralContainer extends ConsumerWidget {
//   const GeneralContainer({
//     required this.backgroundColor,
//     required this.text,
//     required this.size,
//     required this.textColor,
//     this.weight,
//     this.height,
//     this.padding,
//     this.imgUrl,
//     this.radius,
//     this.onTap,
//     this.iconColor,
//     this.borderColor,
//     super.key,
//   });

//   final String text;
//   final Color textColor;
//   final double size;
//   final double? height;
//   final FontWeight? weight;
//   final Color backgroundColor;
//   final EdgeInsetsGeometry? padding;
//   final String? imgUrl;
//   final double? radius;
//   final void Function()? onTap;
//   final Color? iconColor;
//   final Color? borderColor;
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: padding ?? pad(horizontal: 14, vertical: 5),
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(radius ?? 4.r),
//           border: Border.all(color: borderColor ?? backgroundColor),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (imgUrl != null)
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   SvgPicture.asset(imgUrl!, color: iconColor),
//                   10.horizontalSpace,
//                 ],
//               ),
//             GenText(
//               text,
//               color: textColor,
//               size: size,
//               height: height ?? 18.5,
//               weight: weight ?? FontWeight.w600,
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class GeneralColContainer extends ConsumerWidget {
//   const GeneralColContainer({
//     required this.backgroundColor,
//     required this.text,
//     required this.size,
//     required this.textColor,
//     this.weight,
//     this.height,
//     this.padding,
//     this.imgUrl,
//     this.radius,
//     this.onTap,
//     this.iconColor,
//     this.borderColor,
//     super.key,
//   });

//   final String text;
//   final Color textColor;
//   final double size;
//   final double? height;
//   final FontWeight? weight;
//   final Color backgroundColor;
//   final EdgeInsetsGeometry? padding;
//   final String? imgUrl;
//   final double? radius;
//   final void Function()? onTap;
//   final Color? iconColor;
//   final Color? borderColor;
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: padding ?? pad(horizontal: 14, vertical: 5),
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(radius ?? 4.r),
//           border: Border.all(color: borderColor ?? backgroundColor),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             GenText(
//               text,
//               color: textColor,
//               size: size,
//               height: height ?? 18.5,
//               weight: weight ?? FontWeight.w600,
//               textAlign: TextAlign.center,
//             ),
//             if (imgUrl != null)
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   10.horizontalSpace,
//                   SvgPicture.asset(imgUrl!, color: iconColor),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
