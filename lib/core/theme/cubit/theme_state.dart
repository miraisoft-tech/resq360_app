part of 'theme_cubit.dart';

class ThemeState {
  const ThemeState({
    required this.mode,
    required this.brightness,
    required this.colorPalette,
    required this.textTheme,
    required this.themeData,
  });

  factory ThemeState.initial() {
    final colors = AppColorPalette.light();
    final textTheme = AppTextTheme.light().withColors(colors);
    return ThemeState(
      mode: ThemeMode.system,
      brightness: Brightness.light,
      colorPalette: colors,
      textTheme: textTheme,
      themeData: ThemeData.light().copyWith(extensions: [colors, textTheme]),
    );
  }
  final ThemeMode mode;
  final Brightness brightness;
  final AppColorPalette colorPalette;
  final AppTextTheme textTheme;
  final ThemeData themeData;
}
