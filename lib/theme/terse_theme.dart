import 'package:material_ui/material_ui.dart';
import 'package:terse/theme/theme.dart';

/// {@template terse_theme}
/// Terse theme.
/// {@endtemplate}
class TerseTheme {
  /// {@macro terse_theme}
  const new();

  /// [ThemeData] for Terse.
  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _textTheme,
      dividerTheme: _dividerTheme,
      cardTheme: _cardTheme,
      bottomSheetTheme: _bottomSheetTheme,
    );
  }

  /// Color roles, mapped from [TerseColors].
  ColorScheme get colorScheme {
    return const ColorScheme.light(
      primary: TerseColors.ember,
      // Map the color from Terse palette
      // ignore: avoid_redundant_argument_values
      onPrimary: TerseColors.white,
      primaryContainer: TerseColors.peach,
      onPrimaryContainer: TerseColors.rust,
      surface: TerseColors.paper,
      onSurface: TerseColors.ink,
      onSurfaceVariant: TerseColors.stone,
      surfaceContainer: TerseColors.white,
      surfaceContainerHighest: TerseColors.pebble,
      outline: TerseColors.sand,
      outlineVariant: TerseColors.linen,
      error: TerseColors.crimson,
      // Map the color from Terse palette
      // ignore: avoid_redundant_argument_values
      onError: TerseColors.white,
    );
  }

  TextTheme get _textTheme {
    const styles = TerseTextStyles.mobile;
    return TextTheme(
      displayLarge: styles.displayLarge,
      displayMedium: styles.displayMedium,
      titleLarge: styles.titleLarge,
      titleMedium: styles.titleMedium,
      titleSmall: styles.titleSmall,
      bodyLarge: styles.bodyLarge,
      bodyMedium: styles.bodyMedium,
      bodySmall: styles.bodySmall,
      labelLarge: styles.labelLarge,
      labelMedium: styles.labelMedium,
      labelSmall: styles.labelSmall,
    ).apply(displayColor: TerseColors.ink, bodyColor: TerseColors.ink);
  }

  DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      color: TerseColors.linen,
      thickness: 1,
      space: 1,
    );
  }

  CardThemeData get _cardTheme {
    return CardThemeData(
      color: TerseColors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: TerseColors.linen),
      ),
    );
  }

  BottomSheetThemeData get _bottomSheetTheme {
    return const BottomSheetThemeData(
      backgroundColor: TerseColors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
}
