import 'package:flutter_test/flutter_test.dart';
import 'package:terse/theme/theme.dart';

void main() {
  group(TerseSpacing, () {
    const scale = <double>[
      TerseSpacing.xxs,
      TerseSpacing.xs,
      TerseSpacing.sm,
      TerseSpacing.md,
      TerseSpacing.lg,
      TerseSpacing.xl,
      TerseSpacing.xxl,
    ];

    test('is strictly increasing', () {
      for (var i = 1; i < scale.length; i++) {
        expect(scale[i], greaterThan(scale[i - 1]));
      }
    });

    test('uses multiples of 4', () {
      for (final value in scale) {
        expect(value % 4, equals(0));
      }
    });
  });
}
