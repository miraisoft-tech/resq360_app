import 'package:flutter/material.dart';
import 'package:resq360/core/theme/app_color_theme.dart';
import 'package:resq360/core/theme/app_text_theme.dart';

extension ThemeExtensions on BuildContext {
  AppColorPalette get appColors => Theme.of(this).extension<AppColorPalette>()!;
  AppTextTheme get appTextStyles => Theme.of(this).extension<AppTextTheme>()!;

  // Shorthand for common text styles
  TextStyle get headline => appTextStyles.headlineLarge;
  TextStyle get title => appTextStyles.titleLarge;
  TextStyle get body => appTextStyles.bodyMedium;
  TextStyle get caption => appTextStyles.bodySmall;
}
