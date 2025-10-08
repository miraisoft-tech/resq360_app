import 'package:resq360/__lib.dart';

class CustomSwitchWidget extends StatefulWidget {
  const CustomSwitchWidget({
    required this.onChanged,
    required this.value,
    this.activeThumbColor,
    this.disabledThumbColor,
    this.tapColor,
    super.key,
  });

  final void Function({required bool value})? onChanged;
  final bool value;
  final Color? activeThumbColor;
  final Color? disabledThumbColor;
  final Color? tapColor;
  @override
  State<CustomSwitchWidget> createState() => _CustomSwitchWidgetState();
}

class _CustomSwitchWidgetState extends State<CustomSwitchWidget> {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return SizedBox(
      height: 20.h,
      child: Switch.adaptive(
        // focusColor: Colors.blue,
        trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return widget.activeThumbColor ?? appColors.black;
          }
          return widget.disabledThumbColor ??
              const Color.fromRGBO(223, 223, 223, 1);
        }),
        overlayColor: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.red;
          }
          return Colors.white.withValues(alpha: 0.1);
        }),

        thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return const Color.fromRGBO(241, 252, 243, 1);
          }
          return widget.tapColor ?? const Color.fromRGBO(250, 250, 250, 1);
        }),
        splashRadius: 24,

        value: widget.value,
        onChanged:
            widget.onChanged != null
                ? (value) => widget.onChanged!(value: value)
                : null,
      ),
    );
  }
}
