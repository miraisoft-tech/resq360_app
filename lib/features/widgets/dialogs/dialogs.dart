import 'package:resq360/__lib.dart';

class GeneralDialogs {
  static Future<Object?> showCustomDialog(
    BuildContext context, {
    required Widget body,
    void Function()? onTapYes,
    void Function()? onTapNo,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) async {
    return showGeneralDialog(
      barrierDismissible: barrierDismissible,
      barrierLabel: '',
      context: context,
      barrierColor: barrierColor ?? Colors.black54,
      //
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, a1, a2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: a1,
            curve: Curves.elasticOut,
            reverseCurve: Curves.easeOutCubic,
          ),
          child: body,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
    );
  }

  static Future<Object?> showCustomBottomSheet(
    BuildContext context, {
    required Widget body,
    Color? backgroundColor,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: isDismissible,
      backgroundColor: backgroundColor ?? Colors.white,
      builder: (BuildContext context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.bounceInOut,
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).canvasColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
          ),
          child: body,
        );
      },
    );
  }
}
