import 'package:resq360/__lib.dart';

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    required this.total,
    required this.currentIndex,
    this.color,
    super.key,
  });
  final int total;
  final int currentIndex;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => AnimatedContainer(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          duration: const Duration(milliseconds: 400),
          height: 10.h,
          width: currentIndex == index ? 24.w : 10.w,
          decoration: BoxDecoration(
            color:
                currentIndex == index
                    ? (color ?? appTheme.primary.shade500)
                    : appTheme.neutral.shade300,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}

class SmallDotIndicator extends StatelessWidget {
  const SmallDotIndicator({
    required this.total,
    required this.currentIndex,
    this.color,
    super.key,
  });
  final int total;
  final int currentIndex;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => AnimatedContainer(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          duration: const Duration(milliseconds: 400),
          height: 6.h,
          width: currentIndex == index ? 14.w : 6.w,
          decoration: BoxDecoration(
            color:
                currentIndex == index
                    ? (color ?? appTheme.primary.shade500)
                    : appTheme.neutral.shade300,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}
