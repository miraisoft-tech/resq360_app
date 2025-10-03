import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resq360/__lib.dart';

class FilterSearchFormField extends ConsumerStatefulWidget {
  const FilterSearchFormField({
    required this.prefixIconPath,
    required this.controller,
    required this.hintText,
    this.inputFormatters,
    this.hintWidget,
    this.onTapSuffix,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.showSuffix = true,
    this.fillColor,
    this.type = InputType.primary,
    this.enabled = true,
    super.key,
  });
  final InputType type;
  final String prefixIconPath;
  final String? hintText;
  final Widget? hintWidget;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final void Function()? onTapSuffix;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool showSuffix;
  final Color? fillColor;

  final bool enabled;

  @override
  ConsumerState<FilterSearchFormField> createState() =>
      _FilterSearchFormFieldState();
}

class _FilterSearchFormFieldState extends ConsumerState<FilterSearchFormField> {
  late FocusNode _focusNode;
  late ValueNotifier<bool> _obscureNotier;

  String errorMessage = '';
  @override
  void initState() {
    super.initState();
    _obscureNotier = ValueNotifier(widget.type == InputType.password);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appColors;

    return ValueListenableBuilder(
      valueListenable: _obscureNotier,
      builder: (_, obscure, _) {
        return SizedBox(
          child: TextFormField(
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            inputFormatters: widget.inputFormatters,
            controller: widget.controller,
            focusNode: _focusNode,
            cursorColor: appTheme.black,
            obscureText: obscure,
            cursorWidth: 1,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w500,
              color: appTheme.black,
              fontSize: 15.sp,
              height: 17.71.toFigmaHeight(14.sp),
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              isDense: true,
              filled: true,
              fillColor: widget.fillColor ?? appTheme.whiteColor,
              contentPadding: pad(horizontal: 12, vertical: 12),
              hintText:
                  (_focusNode.hasFocus || widget.hintWidget != null)
                      ? ''
                      : widget.hintText,
              hintStyle: TextStyle(
                fontFamily: 'inter',
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: appTheme.neutral.shade300,
                height: 20 / 12,
              ),
              prefixIcon: Transform.scale(
                scale: 0.4,
                child: SvgPicture.asset(widget.prefixIconPath),
              ),
              suffixIcon:
                  _focusNode.hasFocus || widget.controller.text.isNotEmpty
                      ? GestureDetector(
                        onTap: widget.onTapSuffix,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Transform.scale(
                            scale: 0.5,
                            child: Icon(
                              Icons.close,
                              color: appTheme.textColor.shade300,
                            ),
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xffD9D9D9),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xffD9D9D9),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color:
                      _focusNode.hasFocus || widget.controller.text.isNotEmpty
                          ? appTheme.primary.shade500
                          : appTheme.whiteColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _obscureNotier.dispose();
    super.dispose();
  }
}
