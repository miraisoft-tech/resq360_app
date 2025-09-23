import 'package:flutter/material.dart';

class AppColorPalette extends ThemeExtension<AppColorPalette> {
  const AppColorPalette({
    required this.remis,
    required this.remisLite,
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
    : remis = const MaterialColor(0xFF006D55, {
        50: Color(0xFFe6eded), // rgb(230, 237, 237)
        100: Color(0xFFb0c7c8), // rgb(176, 199, 200)
        200: Color(0xFF8aacad), // rgb(138, 172, 173)
        300: Color(0xFF548688), // rgb(84, 134, 136)
        400: Color(0xFF336f71), // rgb(51, 111, 113)
        500: Color(0xFF004b4d), // rgb(0, 75, 77)
        600: Color(0xFF004446), // rgb(0, 68, 70)
        700: Color(0xFF003537), // rgb(0, 53, 55)
        800: Color(0xFF00292a), // rgb(0, 41, 42)
        900: Color(0xFF002020), // rgb(0, 32, 32)
      }),

      remisLite = const MaterialColor(0xFF00635C, {
        50: Color(0xFFE0EFED), // rgb(248, 252, 252)
        100: Color(0xFFe8f4f4), // rgb(232, 244, 244)
        200: Color(0xFFddefef), // rgb(221, 239, 239)
        300: Color(0xFFcde8e8), // rgb(205, 232, 232)
        400: Color(0xFFc3e3e4), // rgb(195, 227, 228)
        500: Color(0xFFb4dcdd), // rgb(180, 220, 221)
        600: Color(0xFFa4c8c9), // rgb(164, 200, 201)
        700: Color(0xFF809c9d), // rgb(128, 156, 157)
        800: Color(0xFF63797a), // rgb(99, 121, 122)
        900: Color(0xFF4c5c5d), // rgb(76, 92, 93)
      }),
      textColor = const MaterialColor(0xFF656983, {
        // Light variants
        50: Color(0xFFedeeef), // White (Light)
        100: Color(0xFFe4e6e8), // Light :hover
        200: Color(0xFFc7cacf), // Light :active
        // Normal variants
        300: Color(0xFF4b5563), // Normal
        400: Color(0xFF444d59), // Normal :hover
        500: Color(0xFF3c444f), // Normal :active
        // Dark variants
        600: Color(0xFF38404a), // Dark
        700: Color(0xFF2d333b), // Dark :hover
        800: Color(0xFF22262d), // Dark :active
        // Darker
        900: Color(0xFF1a1e23), // Darker
      }),
      primary = const MaterialColor(0xFF000D3B, {
        50: Color(0xFFE5EBFF),
        100: Color(0xFFCCD7FF),
        200: Color(0xFF99AFFF),
        300: Color(0xFF6687FF),
        400: Color(0xFF335FFF),
        500: Color(0xFF000D3B),
        550: Color(0xFF061341),
        600: Color(0xFF002CCC),
        700: Color(0xFF002199),
        800: Color(0xFF001666),
        900: Color(0xFF000B33),
        950: Color(0xFF00061A),
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
    : primary = const MaterialColor(0xFF000D3B, {
        50: Color(0xFFE5EBFF),
        100: Color(0xFFCCD7FF),
        200: Color(0xFF99AFFF),
        300: Color(0xFF6687FF),
        400: Color(0xFF335FFF),
        500: Color(0xFF000D3B),
        550: Color(0xFF061341),
        600: Color(0xFF002CCC),
        700: Color(0xFF002199),
        800: Color(0xFF001666),
        900: Color(0xFF000B33),
        950: Color(0xFF00061A),
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
      whiteColor = Colors.white,
      lightGreyColor = const Color(0xFFF2F2F3),
      lightGreyColor2 = const Color(0xFFE5E5E6),
      lightGreyColor3 = const Color(0xFFCACACE),
      greyColor = const Color(0xFFB0B0B5),
      greyColor2 = const Color(0xFF95959D),
      greyColor3 = const Color(0xFF98959D),
      greyColor4 = const Color(0xFF58585F),
      darkGreyColor = const Color(0xFF19191A),
      remis = const MaterialColor(0xFF006D55, {
        // Dark theme values
      }),
      remisLite = const MaterialColor(0xFF00635C, {
        // Dark theme values
      }),
      textColor = const MaterialColor(0xFF656983, {
        // Dark theme values
      });

  final MaterialColor remis;
  final MaterialColor remisLite;
  final MaterialColor textColor;
  //
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
      remis: remis ?? this.remis,
      remisLite: remisLite ?? this.remisLite,
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
      remis: remis,
      remisLite: remisLite,
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
