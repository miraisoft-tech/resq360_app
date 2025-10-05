import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resq360/__lib.dart';

class KFormField extends ConsumerStatefulWidget {
  const KFormField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.inputFormatters,
    this.hintWidget,
    this.onTapSuffix,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.button = false,
    this.formKey,
    this.fillColor,
    this.onEditingComplete,
    this.type = InputType.primary,
    super.key,
  });
  final bool button;
  final InputType type;
  final String label;
  final String? hintText;
  final Widget? hintWidget;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final void Function()? onTapSuffix;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final int minLines;
  final FocusNode? focusNode;
  final String? suffixIcon;
  final String? prefixIcon;
  final Key? formKey;
  final Color? fillColor;
  final void Function()? onEditingComplete;

  @override
  ConsumerState<KFormField> createState() => _KFormFieldState();
}

class _KFormFieldState extends ConsumerState<KFormField> {
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
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Col(
            children: [
              Row(
                children: [
                  GenText(
                    widget.label,
                    size: 12,
                    height: 16.5,
                    weight: FontWeight.w400,
                    color:
                        _focusNode.hasFocus || widget.controller.text.isNotEmpty
                            ? colors.black
                            : colors.textColor.shade900,
                  ),
                  SizedBox(child: widget.hintWidget),
                ],
              ),
              5.verticalSpace,
            ],
          ),
        ValueListenableBuilder(
          valueListenable: _obscureNotier,
          builder: (_, obscure, _) {
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: TextFormField(
                key: widget.formKey,
                enabled: !widget.button,
                onTap: widget.type == InputType.dob ? widget.onTapSuffix : null,
                readOnly:
                    widget.type == InputType.dob ||
                    widget.type == InputType.upload,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                keyboardType: widget.keyboardType,
                validator: widget.validator,
                onChanged: widget.onChanged,
                onEditingComplete: widget.onEditingComplete,
                inputFormatters: widget.inputFormatters,
                controller: widget.controller,
                focusNode: widget.focusNode ?? _focusNode,
                cursorColor: colors.primary.shade500,
                obscureText: obscure,
                cursorWidth: 1,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  color: colors.black,
                  height: 15.5 / 14,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  isDense: true,
                  filled: true,
                  fillColor: colors.whiteColor,
                  errorStyle: TextStyle(
                    fontFamily: 'sfpro',
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: colors.error.shade500,
                    height: 15.5 / 12,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 11.h,
                  ),
                  hintText: (_focusNode.hasFocus) ? '' : widget.hintText,
                  hintStyle: TextStyle(
                    fontFamily: 'inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: colors.neutral.shade300,
                    height: 24.5 / 14,
                  ),
                  prefixIcon:
                      (widget.prefixIcon != null)
                          ? Transform.scale(
                            scale: 0.5,
                            child: SvgPicture.asset(widget.prefixIcon!),
                          )
                          : null,
                  suffixIcon:
                      (obscure || widget.type == InputType.password)
                          ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: IconButton(
                              onPressed: () {
                                _obscureNotier.value = !obscure;
                              },
                              padding: EdgeInsets.zero,
                              icon: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child:
                                    obscure
                                        ? SvgPicture.asset(
                                          AppAssets.ASSETS_ICONS_EYE_SLASH_SVG,
                                        )
                                        : SvgPicture.asset(
                                          AppAssets.ASSETS_ICONS_EYE_SVG,
                                        ),
                              ),
                            ),
                          )
                          : widget.suffixIcon != null
                          ? Transform.scale(
                            scale: 0.5,
                            child: SVGButton(
                              path: widget.suffixIcon!,
                              onTap: () {
                                widget.onTapSuffix?.call();
                              },
                            ),
                          )
                          : null,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colors.lightGreyColor3,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colors.darkGreyColor,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colors.primary.shade500),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          widget.focusNode?.hasFocus ?? _focusNode.hasFocus
                              ? colors.whiteColor
                              : colors.whiteColor,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colors.error.shade500),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colors.error.shade500),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _obscureNotier.dispose();
    super.dispose();
  }
}
