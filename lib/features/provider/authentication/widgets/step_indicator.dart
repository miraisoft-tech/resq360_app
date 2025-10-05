import 'package:resq360/__lib.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final step = index + 1;
        final isActive = step <= currentStep;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: pad(vertical: 3, horizontal: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? colors.primary.shade500 : colors.whiteColor,
                border: Border.all(color: colors.primary.shade500),
              ),
              child: GenText(
                '$step',
                size: 12,
                height: 20,
                weight: FontWeight.w400,
                color: isActive ? colors.whiteColor : colors.primary.shade500,
              ),
            ),
            if (step != totalSteps)
              Container(
                width: 80.w,
                height: 1,
                color: colors.lightGreyColor3,
              ),
          ],
        );
      }),
    );
  }
}
