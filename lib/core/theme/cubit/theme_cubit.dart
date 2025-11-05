import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/core/theme/app_color_theme.dart';
import 'package:resq360/core/theme/app_text_theme.dart';
import 'package:resq360/core/theme/app_theme.preferences.dart';

part 'theme_state.dart';




class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._preferences) : super(ThemeState.initial());

  final ThemePreferences _preferences;

  Future<void> loadTheme() async {
    final mode = await _preferences.getTheme();
    emit(_buildState(mode));
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    await _preferences.setThemeMode(mode: mode);
    emit(_buildState(mode));
  }

  ThemeState _buildState(ThemeMode mode) {
    final brightness = mode == ThemeMode.system
        ? PlatformDispatcher.instance.platformBrightness
        : (mode == ThemeMode.dark ? Brightness.dark : Brightness.light);

    final colors = brightness == Brightness.light
        ? AppColorPalette.light()
        : AppColorPalette.dark();

    final textTheme = brightness == Brightness.light
        ? AppTextTheme.light().withColors(colors)
        : AppTextTheme.dark().withColors(colors);

    final themeData = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      appBarTheme: AppBarTheme(iconTheme: IconThemeData(color: colors.black)),
      textTheme: TextTheme(
        displayLarge: textTheme.displayLarge,
        displayMedium: textTheme.displayMedium,
        displaySmall: textTheme.displaySmall,
        headlineLarge: textTheme.headlineLarge,
        headlineMedium: textTheme.headlineMedium,
        headlineSmall: textTheme.headlineSmall,
        titleLarge: textTheme.titleLarge,
        titleMedium: textTheme.titleMedium,
        titleSmall: textTheme.titleSmall,
        bodyLarge: textTheme.bodyLarge,
        bodyMedium: textTheme.bodyMedium,
        bodySmall: textTheme.bodySmall,
        labelLarge: textTheme.labelLarge,
        labelMedium: textTheme.labelMedium,
        labelSmall: textTheme.labelSmall,
      ),
      extensions: <ThemeExtension<dynamic>>[colors, textTheme],
    );

    return ThemeState(
      mode: mode,
      brightness: brightness,
      colorPalette: colors,
      textTheme: textTheme,
      themeData: themeData,
    );
  }
}
