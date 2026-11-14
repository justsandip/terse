import 'dart:ui' show Color;

/// Color palette of the Terse UI.
abstract class TerseColors {
  /// Warm off-white base. App background.
  static const paper = Color(0xFFF5F4F1);

  /// Pure white. Card and sheet surface.
  static const white = Color(0xFFFFFFFF);

  /// Light borders and dividers.
  static const linen = Color(0xFFE5E2DC);

  /// Stronger borders: chips and outlined buttons.
  static const sand = Color(0xFFD6D2CA);

  /// Neutral fills: segmented control track and small badges.
  static const pebble = Color(0xFFE7E5E4);

  /// Muted text: hints and supporting lines.
  static const stone = Color(0xFF57534E);

  /// Secondary text.
  static const charcoal = Color(0xFF44403C);

  /// Primary text.
  static const ink = Color(0xFF1C1917);

  /// Accent: primary actions and active states.
  static const ember = Color(0xFFC2410C);

  /// Accent tint: badge and highlight fills.
  static const peach = Color(0xFFFFEDD5);

  /// Text on [peach].
  static const rust = Color(0xFF9A3412);

  /// Errors and destructive actions.
  static const crimson = Color(0xFFB42318);
}
