import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terse/theme/theme.dart';

typedef _Expected = (TextStyle, String, double, FontWeight);

void main() {
  group(TerseTextStyles, () {
    const styles = TerseTextStyles.mobile;

    final cases = <String, _Expected>{
      'displayLarge': (
        styles.displayLarge,
        'SpaceGrotesk',
        34,
        FontWeight.w700,
      ),
      'displayMedium': (
        styles.displayMedium,
        'SpaceGrotesk',
        30,
        FontWeight.w700,
      ),
      'titleLarge': (styles.titleLarge, 'Inter', 20, FontWeight.w600),
      'titleMedium': (styles.titleMedium, 'Inter', 18, FontWeight.w600),
      'titleSmall': (styles.titleSmall, 'Inter', 16, FontWeight.w600),
      'bodyLarge': (styles.bodyLarge, 'Inter', 18, FontWeight.w400),
      'bodyMedium': (styles.bodyMedium, 'Inter', 16, FontWeight.w400),
      'bodySmall': (styles.bodySmall, 'Inter', 13, FontWeight.w400),
      'labelLarge': (styles.labelLarge, 'Inter', 17, FontWeight.w600),
      'labelMedium': (styles.labelMedium, 'Inter', 14, FontWeight.w600),
      'labelSmall': (styles.labelSmall, 'Inter', 12, FontWeight.w600),
    };

    for (final entry in cases.entries) {
      test('${entry.key} has the expected font, size and weight', () {
        final (style, family, size, weight) = entry.value;

        expect(style.fontFamily, equals(family));
        expect(style.fontSize, equals(size));
        expect(style.fontWeight, equals(weight));
      });
    }

    test('labelSmall is letter-spaced for uppercase kickers', () {
      expect(styles.labelSmall.letterSpacing, equals(0.72));
    });

    test('display styles use a tight line height', () {
      expect(styles.displayLarge.height, equals(1.1));
      expect(styles.displayMedium.height, equals(1.1));
    });
  });
}
