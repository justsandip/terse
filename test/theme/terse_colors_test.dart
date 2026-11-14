import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:terse/theme/theme.dart';

void main() {
  group(TerseColors, () {
    const colors = <Color>[
      TerseColors.paper,
      TerseColors.white,
      TerseColors.linen,
      TerseColors.sand,
      TerseColors.pebble,
      TerseColors.stone,
      TerseColors.charcoal,
      TerseColors.ink,
      TerseColors.ember,
      TerseColors.peach,
      TerseColors.rust,
      TerseColors.crimson,
    ];

    test('are fully opaque', () {
      for (final color in colors) {
        expect(color.a, equals(1));
      }
    });

    test('are all different', () {
      expect(colors.toSet(), hasLength(colors.length));
    });
  });
}
