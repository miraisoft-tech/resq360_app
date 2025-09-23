// import 'package:remis_b2c/__lib.dart';

// class FilterWidget extends ConsumerWidget {
//   const FilterWidget({required this.onTap, this.title = 'Filter', super.key});

//   final void Function() onTap;
//   final String title;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final appTheme = context.appColors;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: pad(horizontal: 8, vertical: 6),
//         decoration: BoxDecoration(
//           color: appTheme.whiteColor,
//           borderRadius: BorderRadius.circular(10.r),
//           border: Border.all(color: const Color(0xffD9D9D9), width: 0.5),
//         ),
//         child: Row(
//           children: [
//             SvgPicture.asset(
//               AppAssets.ASSETS_ICONS_CALENDAR_SVG,
//               colorFilter: ColorFilter.mode(appTheme.black, BlendMode.srcIn),
//             ),
//             8.horizontalSpace,
//             GenText(
//               title,
//               color: const Color.fromRGBO(107, 107, 107, 1),
//               size: 12,
//               height: 20.4,
//               weight: FontWeight.w500,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
