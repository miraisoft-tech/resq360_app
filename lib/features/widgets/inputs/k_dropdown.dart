import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resq360/__lib.dart';

class KDropDown extends ConsumerStatefulWidget {
  const KDropDown({
    required this.hintText,
    required this.value,
    required this.dropdownItems,
    required this.onChanged,
    required this.label,
    this.selectedItemBuilder,
    this.icon,
    this.itemHeight,
    this.padding,
    this.validator,
    this.hintUrl,
    this.dropdownKey,
    this.showPrefix = true,
    super.key,
  });
  final String hintText;
  final String? value;
  final List<String> dropdownItems;
  final ValueChanged<String?>? onChanged;
  final DropdownButtonBuilder? selectedItemBuilder;
  final String? Function(String?)? validator;
  final Widget? icon;
  final double? itemHeight;
  final EdgeInsetsGeometry? padding;
  final String label;
  final String? hintUrl;
  final Key? dropdownKey;
  final bool showPrefix;

  @override
  ConsumerState<KDropDown> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends ConsumerState<KDropDown> {
  List<DropdownMenuItem<String>> addDividersAfterItems(List<String> items) {
    final menuItems = <DropdownMenuItem<String>>[];
    for (final item in items) {
      menuItems.addAll([
        DropdownMenuItem<String>(
          value: item,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GenText(
                item,
                weight: FontWeight.w700,
                height: 14.7,
                color: Colors.black,
                textAlign: TextAlign.start,
                maxLines: 1,
              ),
            ],
          ),
        ),
        if (item != items.last)
          const DropdownMenuItem<String>(
            enabled: false,
            child: Divider(color: Color.fromRGBO(214, 214, 214, 1), height: 2),
          ),
      ]);
    }
    return menuItems;
  }

  List<double> _getCustomItemsHeights() {
    final itemsHeights = <double>[];
    for (var i = 0; i < (widget.dropdownItems.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(50);
      }
      if (i.isOdd) {
        itemsHeights.add(10);
      }
    }

    return itemsHeights;
  }

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appColors;

    return Col(
      children: [
        if (widget.label != '')
          GenText(
            widget.label,
            size: 16,
            height: 18.2,
            weight: FontWeight.w500,
            color: _focusNode.hasFocus ? appTheme.black : appTheme.black,
          ),
        6.verticalSpace,
        SizedBox(
          height: 52.h,
          child: DropdownButtonFormField2<String>(
            key: widget.dropdownKey,
            value: widget.value,
            focusNode: _focusNode,
            isExpanded: true,
            style: GoogleFonts.mulish(
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              color: appTheme.black,
              height: 18.8 / 14,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  widget.value != null
                      ? appTheme.darkGreyColor
                      : appTheme.greyColor,
              contentPadding:
                  widget.padding ??
                  EdgeInsets.symmetric(horizontal: 0.w, vertical: 16.h),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      widget.value != null
                          ? appTheme.darkGreyColor
                          : appTheme.whiteColor,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: appTheme.neutral.shade600),
                borderRadius: BorderRadius.circular(10),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      _focusNode.hasFocus
                          ? appTheme.remis.shade500
                          : appTheme.neutral.shade400,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: appTheme.error.shade200),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: appTheme.error.shade200),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            hint:
                _focusNode.hasFocus
                    ? const SizedBox.shrink()
                    : GenText(
                      widget.hintText,
                      weight: FontWeight.w400,
                      size: 14.sp,
                      color: const Color.fromRGBO(107, 107, 107, 1),
                      height: 14.5,
                    ),
            items: addDividersAfterItems(widget.dropdownItems),
            validator: widget.validator,
            onChanged: widget.onChanged,
            onSaved: (value) {},
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(right: 8),
            ),
            iconStyleData: IconStyleData(
              icon: SvgPicture.asset(
                'AppAssets.ASSETS_ICONS_ARROW_DOWN_SVG',
                height: 24.h,
                width: 24.w,
                colorFilter: ColorFilter.mode(appTheme.black, BlendMode.srcIn),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(-2, 2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    color: appTheme.lightGreyColor,
                  ),
                ],
              ),
              offset: const Offset(0, -25),
            ),
            menuItemStyleData: MenuItemStyleData(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              customHeights: _getCustomItemsHeights(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}

class ObjectKDropDown<T> extends ConsumerStatefulWidget {
  const ObjectKDropDown({
    required this.hintText,
    required this.value,
    required this.dropdownItems,
    required this.onChanged,
    required this.label,
    required this.displayStringForOption,
    this.selectedItemBuilder,
    this.icon,
    this.itemHeight,
    this.padding,
    this.validator,
    this.hintUrl,
    this.dropdownKey,
    this.showPrefix = true,
    super.key,
  });

  final String hintText;
  final T? value;
  final List<T> dropdownItems;
  final ValueChanged<T?>? onChanged;
  final DropdownButtonBuilder? selectedItemBuilder;
  final String? Function(T?)? validator;
  final Widget? icon;
  final double? itemHeight;
  final EdgeInsetsGeometry? padding;
  final String label;
  final String? hintUrl;
  final Key? dropdownKey;
  final bool showPrefix;
  // Function to get the display string from the generic type
  final String Function(T) displayStringForOption;

  @override
  ConsumerState<ObjectKDropDown<T>> createState() => _ObjectKDropDownState<T>();
}

class _ObjectKDropDownState<T> extends ConsumerState<ObjectKDropDown<T>> {
  List<DropdownMenuItem<T>> addDividersAfterItems(List<T> items) {
    final menuItems = <DropdownMenuItem<T>>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      menuItems.add(
        DropdownMenuItem<T>(
          value: item,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GenText(
                widget.displayStringForOption(item),
                weight: FontWeight.w700,
                height: 14.7,
                color: Colors.black,
                textAlign: TextAlign.start,
                maxLines: 1,
              ),
            ],
          ),
        ),
      );

      // Add a divider item unless it's the last item
      if (i != items.length - 1) {
        menuItems.add(
          DropdownMenuItem<T>(
            enabled: false,
            child: const Divider(
              color: Color.fromRGBO(214, 214, 214, 1),
              height: 2,
            ),
          ),
        );
      }
    }
    return menuItems;
  }

  List<double> _getCustomItemsHeights() {
    final itemsHeights = <double>[];

    for (var i = 0; i < widget.dropdownItems.length; i++) {
      // Add height for the item itself
      itemsHeights.add(50);

      // Add height for the divider if it's not the last item
      if (i != widget.dropdownItems.length - 1) {
        itemsHeights.add(10);
      }
    }

    return itemsHeights;
  }

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Col(
      children: [
        if (widget.label != '')
          GenText(
            widget.label,
            height: 18.2,
            weight: FontWeight.w500,
            color:
                _focusNode.hasFocus ? colors.black : colors.textColor.shade900,
          ),

        6.verticalSpace,
        SizedBox(
          height: 48.h,
          child: DropdownButtonFormField2<T>(
            key: widget.dropdownKey,
            value: widget.value,
            focusNode: _focusNode,
            isExpanded: true,
            style: TextStyle(
              fontFamily: 'sfpro',
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
              color: colors.textColor.shade300,
              height: 15.5 / 12,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.whiteColor,
              contentPadding:
                  widget.padding ??
                  EdgeInsets.symmetric(horizontal: 0.w, vertical: 16.h),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: colors.lightGreyColor3,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: colors.darkGreyColor, width: 0.5),
                borderRadius: BorderRadius.circular(10.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colors.black),
                borderRadius: BorderRadius.circular(10.r),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      _focusNode.hasFocus
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
            hint:
                _focusNode.hasFocus
                    ? const SizedBox.shrink()
                    : GenText(
                      widget.hintText,
                      weight: FontWeight.w400,
                      size: 12,
                      color: colors.textColor.shade300,
                      height: 15.5,
                    ),
            items: addDividersAfterItems(widget.dropdownItems),
            validator: widget.validator,
            onChanged: widget.onChanged,
            onSaved: (value) {},
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(right: 8),
            ),
            iconStyleData: IconStyleData(
              icon: SvgPicture.asset(
                'AppAssets.ASSETS_ICONS_ARROW_DOWN_SVG',
                height: 24.h,
                width: 24.w,
                colorFilter: ColorFilter.mode(colors.black, BlendMode.srcIn),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(-2, 2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    color: colors.lightGreyColor,
                  ),
                ],
              ),
              offset: const Offset(0, -25),
            ),
            menuItemStyleData: MenuItemStyleData(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              customHeights: _getCustomItemsHeights(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
