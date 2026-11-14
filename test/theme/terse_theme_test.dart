import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/theme/theme.dart';

void main() {
  group(TerseTheme, () {
    final themeData = const TerseTheme().themeData;
    const noStates = <WidgetState>{};

    test('uses Material 3', () {
      expect(themeData.useMaterial3, isTrue);
    });

    test('maps colors to roles', () {
      final scheme = themeData.colorScheme;

      expect(scheme.primary, equals(TerseColors.ember));
      expect(scheme.onPrimary, equals(TerseColors.white));
      expect(scheme.secondary, equals(TerseColors.ember));
      expect(scheme.secondaryContainer, equals(TerseColors.peach));
      expect(scheme.onSecondaryContainer, equals(TerseColors.rust));
      expect(scheme.surface, equals(TerseColors.paper));
      expect(scheme.onSurface, equals(TerseColors.ink));
      expect(scheme.onSurfaceVariant, equals(TerseColors.stone));
      expect(scheme.outline, equals(TerseColors.sand));
      expect(scheme.error, equals(TerseColors.crimson));
      expect(themeData.scaffoldBackgroundColor, equals(TerseColors.paper));
    });

    test('uses the Terse fonts and the ink text color', () {
      final textTheme = themeData.textTheme;

      expect(textTheme.displayLarge?.fontFamily, equals('SpaceGrotesk'));
      expect(textTheme.bodyMedium?.fontFamily, equals('Inter'));
      expect(textTheme.displayLarge?.color, equals(TerseColors.ink));
      expect(textTheme.bodyMedium?.color, equals(TerseColors.ink));
    });

    test('styles dividers', () {
      expect(themeData.dividerTheme.color, equals(TerseColors.linen));
      expect(themeData.dividerTheme.thickness, equals(1));
      expect(themeData.dividerTheme.space, equals(1));
    });

    test('styles cards', () {
      final cardTheme = themeData.cardTheme;
      final shape = cardTheme.shape! as RoundedRectangleBorder;

      expect(cardTheme.color, equals(TerseColors.white));
      expect(cardTheme.elevation, equals(0));
      expect(cardTheme.margin, equals(EdgeInsets.zero));
      expect(shape.borderRadius, equals(BorderRadius.circular(20)));
      expect(shape.side.color, equals(TerseColors.linen));
    });

    test('styles bottom sheets', () {
      final sheetTheme = themeData.bottomSheetTheme;

      expect(sheetTheme.backgroundColor, equals(TerseColors.white));
      expect(sheetTheme.showDragHandle, isTrue);
    });

    test('styles filled buttons', () {
      final style = themeData.filledButtonTheme.style!;

      expect(style.backgroundColor?.resolve(noStates), TerseColors.ember);
      expect(
        style.backgroundColor?.resolve({WidgetState.disabled}),
        equals(TerseColors.pebble),
      );
      expect(style.foregroundColor?.resolve(noStates), TerseColors.white);
      expect(
        style.foregroundColor?.resolve({WidgetState.disabled}),
        equals(TerseColors.stone),
      );
      expect(style.minimumSize?.resolve(noStates), equals(const Size(64, 56)));
      expect(style.shape?.resolve(noStates), isA<StadiumBorder>());
      expect(style.textStyle?.resolve(noStates)?.fontSize, equals(17));
    });

    test('styles chips', () {
      final chipTheme = themeData.chipTheme;

      expect(chipTheme.side?.color, equals(TerseColors.sand));
      expect(chipTheme.shape, isA<StadiumBorder>());
      expect(chipTheme.labelStyle?.fontSize, equals(14));
    });

    test('colors chip labels by state', () {
      final color = themeData.chipTheme.labelStyle!.color!;

      Color resolve(Set<WidgetState> states) {
        return WidgetStateProperty.resolveAs<Color>(color, states);
      }

      expect(resolve(noStates), equals(TerseColors.charcoal));
      expect(resolve({WidgetState.selected}), equals(TerseColors.rust));
      expect(
        resolve({WidgetState.disabled}),
        equals(TerseColors.stone.withValues(alpha: 0.5)),
      );
    });
  });
}
