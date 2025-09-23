// import 'package:remis_b2c/__lib.dart';
// import 'package:remis_b2c/features/widgets/images.widgets.dart';

// class EmptyStateWidgetPng extends ConsumerWidget {
//   const EmptyStateWidgetPng({
//     required this.title,
//     required this.subTitle,
//     required this.imgUrl,
//     required this.spacing,
//     this.padding,
//     super.key,
//   });

//   final String title;
//   final String subTitle;
//   final String imgUrl;
//   final Widget spacing;
//   final EdgeInsets? padding;
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final appTheme = context.appColors;

//     return Padding(
//       padding: padding ?? pad(horizontal: 20),
//       child: Center(
//         child: Column(
//           children: [
//             spacing,
//             assetsImage(imgUrl: imgUrl, height: 170.h, width: 150.w),
//             40.verticalSpace,
//             GenText(
//               title,
//               color: appTheme.black,
//               size: 20,
//               height: 28.4,
//               weight: FontWeight.w700,
//               textAlign: TextAlign.center,
//             ),
//             12.verticalSpace,
//             GenText(
//               subTitle,
//               color: appTheme.greyColor,
//               height: 25.4,
//               weight: FontWeight.w400,
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
