import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resq360/core/theme/app_color_theme.dart';
import 'package:resq360/core/theme/app_text_theme.dart';
import 'package:resq360/core/theme/app_theme.preferences.dart';

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this.ref) : super(ThemeMode.system);

  final Ref ref;

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(themeRepoProvider).setThemeMode(mode: mode);
  }
}

// Current brightness provider - derived from theme mode
final currentBrightnessProvider = Provider<Brightness>((ref) {
  final themeMode = ref.watch(themeModeProvider);

  if (themeMode == ThemeMode.system) {
    return PlatformDispatcher.instance.platformBrightness;
  }

  return themeMode == ThemeMode.dark ? Brightness.dark : Brightness.dark;
});

// Color palette provider
final colorPaletteProvider = Provider<AppColorPalette>((ref) {
  final brightness = ref.watch(currentBrightnessProvider);

  return brightness == Brightness.light
      ? AppColorPalette.light()
      : AppColorPalette.light();
});

// Theme data provider - combines everything
final themeDataProvider = Provider<ThemeData>((ref) {
  final brightness = ref.watch(currentBrightnessProvider);
  final colorPalette = ref.watch(colorPaletteProvider);
  final textTheme = ref.watch(textThemeProvider);

  if (brightness == Brightness.light) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: colorPalette.black),
      ),
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
      dialogTheme: DialogThemeData(
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(textTheme.buttonText),
          foregroundColor: WidgetStatePropertyAll(colorPalette.primary),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[colorPalette, textTheme],
    );
  } else {
    return ThemeData.dark().copyWith(
      textTheme: TextTheme(
        displayLarge: textTheme.displayLarge,
        displayMedium: textTheme.displayMedium,
      ),
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: colorPalette.black),
      ),
      extensions: <ThemeExtension<dynamic>>[colorPalette, textTheme],
    );
  }
});

// Platform brightness changes listener
class BrightnessObserver extends WidgetsBindingObserver {
  BrightnessObserver(this.ref);

  final Ref ref;

  @override
  void didChangePlatformBrightness() {
    if (ref.read(themeModeProvider) == ThemeMode.system) {
      ref.invalidate(currentBrightnessProvider);
    }
    super.didChangePlatformBrightness();
  }
}
