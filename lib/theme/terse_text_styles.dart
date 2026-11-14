import 'package:flutter/painting.dart';

const _displayFamily = 'SpaceGrotesk';
const _bodyFamily = 'Inter';

/// Text styles of the Terse UI.
abstract class TerseTextStyles {
  const new _();

  /// Text styles for mobile devices.
  static const mobile = _TextStylesMobile._();

  /// Main screen titles, e.g. "How was today?".
  TextStyle get displayLarge;

  /// Titles of secondary screens, e.g. "What to track?".
  TextStyle get displayMedium;

  /// Large values, e.g. a metric average on the trends screen.
  TextStyle get titleLarge;

  /// Field values, e.g. "6 hours" on the confirm screen.
  TextStyle get titleMedium;

  /// Row titles in lists and settings.
  TextStyle get titleSmall;

  /// The journal entry text.
  TextStyle get bodyLarge;

  /// Screen subtitles and descriptions.
  TextStyle get bodyMedium;

  /// Supporting lines and hints.
  TextStyle get bodySmall;

  /// Primary button labels.
  TextStyle get labelLarge;

  /// Secondary buttons, tabs and chips.
  TextStyle get labelMedium;

  /// Kicker labels above sections. Uppercase.
  TextStyle get labelSmall;
}

class _TextStylesMobile extends TerseTextStyles {
  const new _() : super._();

  @override
  TextStyle get displayLarge => const TextStyle(
    fontFamily: _displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: 34,
    height: 1.1,
  );

  @override
  TextStyle get displayMedium => const TextStyle(
    fontFamily: _displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: 30,
    height: 1.1,
  );

  @override
  TextStyle get titleLarge => const TextStyle(
    fontFamily: _bodyFamily,
    fontWeight: FontWeight.w600,
    fontSize: 20,
  );

  @override
  TextStyle get titleMedium => const TextStyle(
    fontFamily: _bodyFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18,
  );

  @override
  TextStyle get titleSmall => const TextStyle(
    fontFamily: _bodyFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  @override
  TextStyle get bodyLarge => const TextStyle(
    fontFamily: _bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 18,
    height: 1.5,
  );

  @override
  TextStyle get bodyMedium => const TextStyle(
    fontFamily: _bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.4,
  );

  @override
  TextStyle get bodySmall => const TextStyle(
    fontFamily: _bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13,
  );

  @override
  TextStyle get labelLarge => const TextStyle(
    fontFamily: _bodyFamily,
    fontWeight: FontWeight.w600,
    fontSize: 17,
  );

  @override
  TextStyle get labelMedium => const TextStyle(
    fontFamily: _bodyFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  @override
  TextStyle get labelSmall => const TextStyle(
    fontFamily: _bodyFamily,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    letterSpacing: 0.72,
  );
}
