// import 'package:go_router/go_router.dart';
// import 'package:remis_b2c/__lib.dart';

// class LogoutConfirmationDialog extends StatefulWidget {
//   const LogoutConfirmationDialog({required this.onTap, super.key});

//   final void Function() onTap;
//   @override
//   State<LogoutConfirmationDialog> createState() =>
//       _LogoutConfirmationDialogState();
// }

// class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog> {
//   @override
//   Widget build(BuildContext context) {
//     final appColors = context.appColors;

//     return Padding(
//       padding: EdgeInsets.only(top: 320.h, bottom: 320.h),
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           width: double.infinity,
//           margin: pad(horizontal: 20),
//           padding: pad(horizontal: 20, vertical: 20),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: appColors.whiteColor,
//           ),
//           child: Column(
//             children: [
//               GenText(
//                 'Are you sure you want to logout?',
//                 color: appColors.remis.shade500,
//                 height: 20.4,
//                 weight: FontWeight.w600,
//                 textAlign: TextAlign.center,
//               ),
//               42.verticalSpace,
//               Row(
//                 children: [
//                   Expanded(
//                     child: WideButton(label: 'Yes', onPressed: widget.onTap),
//                   ),
//                   11.horizontalSpace,
//                   Expanded(
//                     child: WideButton(
//                       backgroundColor: appColors.remis.shade500,
//                       textColor: appColors.whiteColor,
//                       label: 'No, Cancel',
//                       onPressed: () {
//                         context.pop();
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
