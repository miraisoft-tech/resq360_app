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

class WideButton extends StatelessWidget {
  const WideButton({
    required this.label,
    this.onPressed,
    this.width,
    this.heigth,
    this.backgroundColor,
    this.loading = false,
    this.textColor,
    super.key,
  });
  final void Function()? onPressed;
  final String label;
  final double? width;
  final double? heigth;
  final bool loading;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: width ?? double.infinity,
      height: heigth ?? 48.h,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor:
              onPressed == null
                  ? const Color(0xffF2C079)
                  : (backgroundColor ?? colors.primary.shade500),
          disabledBackgroundColor: colors.textColor.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          //  side: BorderSide(color: colors.primary.shade100, width: 2),
        ),
        onPressed: () {
          loading ? log('Tapped while loading') : onPressed?.call();
        },
        child:
            loading
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? colors.primary.shade500,
                    ),
                  ),
                )
                : UrbText(
                  label,
                  color:
                      onPressed == null
                          ? colors.neutral.shade400
                          : (textColor ?? colors.whiteColor),
                  weight: FontWeight.w700,
                  height: 20.5,
                ),
      ),
    );
  }
}

class IWideButton extends StatelessWidget {
  const IWideButton({
    required this.label,
    this.onPressed,
    this.width,
    this.heigth,
    this.loading = false,
    this.textColor,
    super.key,
  });
  final void Function()? onPressed;
  final String label;
  final double? width;
  final double? heigth;
  final bool loading;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: width ?? double.infinity,
      height: heigth ?? 48,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: colors.textColor.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          side: BorderSide(color: colors.primary.shade100),
        ),
        onPressed: () {
          loading ? log('Tapped while loading') : onPressed?.call();
        },
        child:
            loading
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? colors.primary.shade500,
                    ),
                  ),
                )
                : UrbText(
                  label,
                  color:
                      onPressed == null
                          ? colors.textColor.shade100
                          : (textColor ?? colors.whiteColor),
                  weight: FontWeight.w500,
                  height: 19.8,
                  size: 16,
                ),
      ),
    );
  }
}
