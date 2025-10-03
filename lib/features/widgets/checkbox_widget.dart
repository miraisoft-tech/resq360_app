// ignore_for_file: document_ignores, avoid_positional_boolean_parameters

import 'package:resq360/__lib.dart';

class CheckBoxWidget extends StatelessWidget {
  const CheckBoxWidget({
    required this.isChecked,
    this.onChanged,
    super.key,
  });

  final void Function(bool? value)? onChanged;
  final bool isChecked;
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return SizedBox(
      height: 16.h,
      width: 16.w,
      child: Checkbox(
        value: isChecked,
        onChanged: onChanged,
        activeColor: appColors.whiteColor,
        checkColor: appColors.primary.shade500,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color:
                isChecked
                    ? appColors.primary.shade500
                    : appColors.neutral.shade500,
          ),
        ),
      ),
    );
  }
}
