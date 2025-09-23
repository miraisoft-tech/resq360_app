import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resq360/core/theme/app_color_theme.dart';
import 'package:resq360/core/theme/app_theme.providers.dart';

// Text theme provider
final textThemeProvider = Provider<AppTextTheme>((ref) {
  final brightness = ref.watch(currentBrightnessProvider);
  final colorPalette = ref.watch(colorPaletteProvider);

  final baseTextTheme =
      brightness == Brightness.light
          ? AppTextTheme.light()
          : AppTextTheme.dark();

  return baseTextTheme.withColors(colorPalette);
});

class AppTextTheme extends ThemeExtension<AppTextTheme> {
  const AppTextTheme({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.captionBold,
    required this.navigationLabel,
    required this.buttonText,
    required this.errorText,
  });
  // Named constructor for light theme text styles
  AppTextTheme.light()
    : displayLarge = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 36,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 32,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      headlineSmall = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      titleLarge = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      titleMedium = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      captionBold = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
      navigationLabel = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      buttonText = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.25,
      ),
      errorText = const TextStyle(
        fontFamily: 'mona_sans',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: Colors.red,
      );

  factory AppTextTheme.dark() {
    final base = AppTextTheme.light();

    return base.copyWith(
      displayLarge: base.displayLarge.copyWith(color: Colors.white),
      displayMedium: base.displayMedium.copyWith(color: Colors.white),
      displaySmall: base.displaySmall.copyWith(color: Colors.white),
      headlineLarge: base.headlineLarge.copyWith(color: Colors.white),
      headlineMedium: base.headlineMedium.copyWith(color: Colors.white),
      headlineSmall: base.headlineSmall.copyWith(color: Colors.white),
      titleLarge: base.titleLarge.copyWith(color: Colors.white),
      titleMedium: base.titleMedium.copyWith(color: Colors.white),
      titleSmall: base.titleSmall.copyWith(color: Colors.white),
      bodyLarge: base.bodyLarge.copyWith(color: Colors.white),
      bodyMedium: base.bodyMedium.copyWith(color: Colors.white),
      bodySmall: base.bodySmall.copyWith(color: Colors.white),
      labelLarge: base.labelLarge.copyWith(color: Colors.white),
      labelMedium: base.labelMedium.copyWith(color: Colors.white),
      labelSmall: base.labelSmall.copyWith(color: Colors.white),
      captionBold: base.captionBold.copyWith(color: Colors.white),
      navigationLabel: base.navigationLabel.copyWith(color: Colors.white),
      buttonText: base.buttonText.copyWith(color: Colors.white),
      errorText: base.errorText.copyWith(color: Colors.white),
    );
  }
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  // Adding custom text styles
  final TextStyle captionBold;
  final TextStyle navigationLabel;
  final TextStyle buttonText;
  final TextStyle errorText;

  // Applying text styles with colors from color palette
  AppTextTheme withColors(AppColorPalette colors) {
    return copyWith(
      displayLarge: displayLarge.copyWith(color: colors.textColor.shade600),
      headlineLarge: headlineLarge.copyWith(color: colors.textColor.shade700),
      titleLarge: titleLarge.copyWith(color: colors.textColor.shade800),
      bodyLarge: bodyLarge.copyWith(color: colors.greyColor4),
    );
  }

  @override
  AppTextTheme copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
    TextStyle? captionBold,
    TextStyle? navigationLabel,
    TextStyle? buttonText,
    TextStyle? errorText,
  }) {
    return AppTextTheme(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
      captionBold: captionBold ?? this.captionBold,
      navigationLabel: navigationLabel ?? this.navigationLabel,
      buttonText: buttonText ?? this.buttonText,
      errorText: errorText ?? this.errorText,
    );
  }

  @override
  AppTextTheme lerp(covariant ThemeExtension<AppTextTheme>? other, double t) {
    if (other is! AppTextTheme) {
      return this;
    }

    return AppTextTheme(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      captionBold: TextStyle.lerp(captionBold, other.captionBold, t)!,
      navigationLabel:
          TextStyle.lerp(navigationLabel, other.navigationLabel, t)!,
      buttonText: TextStyle.lerp(buttonText, other.buttonText, t)!,
      errorText: TextStyle.lerp(errorText, other.errorText, t)!,
    );
  }
}
