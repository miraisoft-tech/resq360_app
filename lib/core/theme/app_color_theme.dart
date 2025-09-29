import 'package:flutter/material.dart';

class AppColorPalette extends ThemeExtension<AppColorPalette> {
  const AppColorPalette({
    required this.textColor,
    required this.primary,
    required this.secondary,
    required this.neutral,
    required this.warning,
    required this.error,
    required this.success,
    required this.whiteColor,
    required this.lightGreyColor,
    required this.lightGreyColor2,
    required this.lightGreyColor3,
    required this.greyColor,
    required this.greyColor2,
    required this.greyColor3,
    required this.greyColor4,
    required this.darkGreyColor,
    required this.scaffoldBackgroundColor,
    required this.black,
  });
  AppColorPalette.light()
    : textColor = const MaterialColor(0xFF656983, {
        50: Color(0xFFedeeef),
        100: Color(0xFFe4e6e8),
        200: Color(0xFFc7cacf),
        300: Color(0xFF4b5563),
        400: Color(0xFF444d59),
        500: Color(0xFF3c444f),
        600: Color(0xFF38404a),
        700: Color(0xFF2d333b),
        800: Color(0xFF22262d),
        900: Color(0xFF1a1e23),
      }),
      primary = const MaterialColor(0xFFE8683B, {
        50: Color(0xFFFDF4F0),
        100: Color(0xFFFAE7DC),
        200: Color(0xFFF5CFB9),
        300: Color(0xFFF0B796),
        400: Color(0xFFEC9F73),
        500: Color(0xFFE8683B),
        550: Color(0xFFE55D2E),
        600: Color(0xFFD24A1F),
        700: Color(0xFFB73D17),
        800: Color(0xFF9C300F),
        900: Color(0xFF812307),
        950: Color(0xFF4A1504),
      }),

      secondary = const MaterialColor(0xFFE41A3C, {
        50: Color(0xFFFCE8EB),
        100: Color(0xFFFAD1D8),
        200: Color(0xFFF5A3B1),
        300: Color(0xFFEF768A),
        400: Color(0xFFEA4863),
        500: Color(0xFFE41A3C),
        550: Color(0xFFE4193C),
        600: Color(0xFFB71530),
        700: Color(0xFF891024),
        800: Color(0xFF5C0A18),
        900: Color(0xFF2E050C),
        950: Color(0xFF170306),
      }),
      neutral = const MaterialColor(0xFF58585F, {
        50: Color(0xFFF2F2F3),
        100: Color(0xFFE5E5E6),
        200: Color(0xFFCACACE),
        300: Color(0xFFB0B0B5),
        400: Color(0xFF95959D),
        450: Color(0xFF98959D),
        500: Color(0xFF58585F),
        600: Color(0xFF62626A),
        700: Color(0xFF4A4A4F),
        800: Color(0xFF313135),
        900: Color(0xFF19191A),
        950: Color(0xFF0C0C0D),
      }),
      warning = const MaterialColor(0xFFF9A410, {
        50: Color(0xFFFEF5E6),
        100: Color(0xFFFEECCD),
        200: Color(0xFFFDD99B),
        300: Color(0xFFFBC66A),
        400: Color(0xFFFAB338),
        500: Color(0xFFF9A410),
        600: Color(0xFFC78005),
        700: Color(0xFF956004),
        800: Color(0xFF644002),
        900: Color(0xFF322001),
        950: Color(0xFF191001),
      }),
      error = const MaterialColor(0xFFE83B3B, {
        50: Color(0xFFFCE8E8),
        100: Color(0xFFFAD1D1),
        200: Color(0xFFF4A4A4),
        300: Color(0xFFEF7676),
        400: Color(0xFFEA4848),
        500: Color(0xFFE83B3B),
        600: Color(0xFFB71515),
        700: Color(0xFF891010),
        800: Color(0xFF5B0B0B),
        900: Color(0xFF2E0505),
        950: Color(0xFF170303),
      }),
      success = const MaterialColor(0xFF74DA2F, {
        50: Color(0xFFF0FBE9),
        100: Color(0xFFE2F7D4),
        200: Color(0xFFC5F0A8),
        300: Color(0xFFA8E87D),
        400: Color(0xFF8BE052),
        500: Color(0xFF74DA2F),
        600: Color(0xFF58AD1F),
        700: Color(0xFF428217),
        800: Color(0xFF2C570F),
        900: Color(0xFF162B08),
        950: Color(0xFF0B1604),
      }),
      whiteColor = Colors.white,
      lightGreyColor = const Color(0xFFF2F2F3),
      lightGreyColor2 = const Color(0xFFE5E5E6),
      lightGreyColor3 = const Color(0xFFCACACE),
      greyColor = const Color(0xFFB0B0B5),
      greyColor2 = const Color(0xFF95959D),
      greyColor3 = const Color(0xFF98959D),
      greyColor4 = const Color(0xFF58585F),
      scaffoldBackgroundColor = const Color(0xffF6F4F0),
      darkGreyColor = const Color(0xFF19191A),
      black = const Color(0xff000000);

  AppColorPalette.dark()
    : primary = const MaterialColor(0xFFE8683B, {
        50: Color(0xFFFDF4F0),
        100: Color(0xFFFAE7DC),
        200: Color(0xFFF5CFB9),
        300: Color(0xFFF0B796),
        400: Color(0xFFEC9F73),
        500: Color(0xFFE8683B),
        550: Color(0xFFE55D2E),
        600: Color(0xFFD24A1F),
        700: Color(0xFFB73D17),
        800: Color(0xFF9C300F),
        900: Color(0xFF812307),
        950: Color(0xFF4A1504),
      }),

      secondary = const MaterialColor(0xFFE41A3C, {
        50: Color(0xFFFCE8EB),
        100: Color(0xFFFAD1D8),
        200: Color(0xFFF5A3B1),
        300: Color(0xFFEF768A),
        400: Color(0xFFEA4863),
        500: Color(0xFFE41A3C),
        550: Color(0xFFE4193C),
        600: Color(0xFFB71530),
        700: Color(0xFF891024),
        800: Color(0xFF5C0A18),
        900: Color(0xFF2E050C),
        950: Color(0xFF170306),
      }),
      neutral = const MaterialColor(0xFF58585F, {
        50: Color(0xFFF2F2F3),
        100: Color(0xFFE5E5E6),
        200: Color(0xFFCACACE),
        300: Color(0xFFB0B0B5),
        400: Color(0xFF95959D),
        450: Color(0xFF98959D),
        500: Color(0xFF58585F),
        600: Color(0xFF62626A),
        700: Color(0xFF4A4A4F),
        800: Color(0xFF313135),
        900: Color(0xFF19191A),
        950: Color(0xFF0C0C0D),
      }),
      warning = const MaterialColor(0xFFF9A410, {
        50: Color(0xFFFEF5E6),
        100: Color(0xFFFEECCD),
        200: Color(0xFFFDD99B),
        300: Color(0xFFFBC66A),
        400: Color(0xFFFAB338),
        500: Color(0xFFF9A410),
        600: Color(0xFFC78005),
        700: Color(0xFF956004),
        800: Color(0xFF644002),
        900: Color(0xFF322001),
        950: Color(0xFF191001),
      }),
      error = const MaterialColor(0xFFE83B3B, {
        50: Color(0xFFFCE8E8),
        100: Color(0xFFFAD1D1),
        200: Color(0xFFF4A4A4),
        300: Color(0xFFEF7676),
        400: Color(0xFFEA4848),
        500: Color(0xFFE83B3B),
        600: Color(0xFFB71515),
        700: Color(0xFF891010),
        800: Color(0xFF5B0B0B),
        900: Color(0xFF2E0505),
        950: Color(0xFF170303),
      }),
      success = const MaterialColor(0xFF74DA2F, {
        50: Color(0xFFF0FBE9),
        100: Color(0xFFE2F7D4),
        200: Color(0xFFC5F0A8),
        300: Color(0xFFA8E87D),
        400: Color(0xFF8BE052),
        500: Color(0xFF74DA2F),
        600: Color(0xFF58AD1F),
        700: Color(0xFF428217),
        800: Color(0xFF2C570F),
        900: Color(0xFF162B08),
        950: Color(0xFF0B1604),
      }),
      scaffoldBackgroundColor = const Color(0xffF6F4F0),
      black = const Color(0xff000000),
      whiteColor = const Color(0xffFFFFFF),
      lightGreyColor = const Color(0xFFF2F2F3),
      lightGreyColor2 = const Color(0xFFE5E5E6),
      lightGreyColor3 = const Color(0xFFCACACE),
      greyColor = const Color(0xFFB0B0B5),
      greyColor2 = const Color(0xFF95959D),
      greyColor3 = const Color(0xFF98959D),
      greyColor4 = const Color(0xFF58585F),
      darkGreyColor = const Color(0xFF19191A),
      textColor = const MaterialColor(0xFF656983, {});

  final MaterialColor textColor;
  final MaterialColor primary;
  final MaterialColor secondary;
  final MaterialColor neutral;
  final MaterialColor warning;
  final MaterialColor error;
  final MaterialColor success;
  // Additional derived colors
  final Color whiteColor;
  final Color lightGreyColor;
  final Color lightGreyColor2;
  final Color lightGreyColor3;
  final Color greyColor;
  final Color greyColor2;
  final Color greyColor3;
  final Color greyColor4;
  final Color darkGreyColor;
  final Color scaffoldBackgroundColor;
  final Color black;

  @override
  AppColorPalette copyWith({
    MaterialColor? remis,
    MaterialColor? remisLite,
    MaterialColor? textColor,
    MaterialColor? primary,
    MaterialColor? secondary,
    MaterialColor? neutral,
    MaterialColor? warning,
    MaterialColor? error,
    MaterialColor? success,
    Color? whiteColor,
    Color? justrightBlueColor,
    Color? hecklrRedColor,
    Color? lightGreyColor,
    Color? lightGreyColor2,
    Color? lightGreyColor3,
    Color? greyColor,
    Color? greyColor2,
    Color? greyColor3,
    Color? greyColor4,
    Color? darkGreyColor,
    Color? scaffoldBackgroundColor,
    Color? black,
  }) {
    return AppColorPalette(
      textColor: textColor ?? this.textColor,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      neutral: neutral ?? this.neutral,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      success: success ?? this.success,
      whiteColor: whiteColor ?? this.whiteColor,
      lightGreyColor: lightGreyColor ?? this.lightGreyColor,
      lightGreyColor2: lightGreyColor2 ?? this.lightGreyColor2,
      lightGreyColor3: lightGreyColor3 ?? this.lightGreyColor3,
      greyColor: greyColor ?? this.greyColor,
      greyColor2: greyColor2 ?? this.greyColor2,
      greyColor3: greyColor3 ?? this.greyColor3,
      greyColor4: greyColor4 ?? this.greyColor4,
      darkGreyColor: darkGreyColor ?? this.darkGreyColor,
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      black: black ?? this.black,
    );
  }

  @override
  AppColorPalette lerp(
    covariant ThemeExtension<AppColorPalette>? other,
    double t,
  ) {
    if (other is! AppColorPalette) {
      return this;
    }

    return AppColorPalette(
      textColor: textColor,
      primary: primary,
      secondary: secondary,
      neutral: neutral,
      warning: warning,
      error: error,
      success: success,
      whiteColor: whiteColor,
      lightGreyColor: lightGreyColor,
      lightGreyColor2: lightGreyColor2,
      lightGreyColor3: lightGreyColor3,
      greyColor: greyColor,
      greyColor2: greyColor2,
      greyColor3: greyColor3,
      greyColor4: greyColor4,
      darkGreyColor: darkGreyColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      black: black,
    );
  }
}
