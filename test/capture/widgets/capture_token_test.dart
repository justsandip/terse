import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/capture/capture.dart';

import '../../helpers/helpers.dart';

void main() {
  Widget host(Widget child) => Scaffold(body: Center(child: child));

  group(CaptureToken, () {
    testWidgets('shows its label and reports taps', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        host(
          CaptureToken(
            label: '7 h',
            state: TokenState.idle,
            onTap: () => taps++,
          ),
        ),
      );

      expect(find.text('7 h'), findsOneWidget);
      await tester.tap(find.byType(CaptureToken));
      expect(taps, equals(1));
    });

    testWidgets('draws a dashed outline only when it is a ghost', (
      tester,
    ) async {
      bool isDashed(Widget widget) =>
          widget is CustomPaint &&
          widget.foregroundPainter is DashedBorderPainter;

      await tester.pumpApp(
        host(CaptureToken(label: '7 h', state: TokenState.ghost, onTap: () {})),
      );
      expect(find.byWidgetPredicate(isDashed), findsOneWidget);

      await tester.pumpApp(
        host(CaptureToken(label: '7 h', state: TokenState.idle, onTap: () {})),
      );
      expect(find.byWidgetPredicate(isDashed), findsNothing);
    });

    testWidgets('renders every state as a pill and as a circle', (
      tester,
    ) async {
      for (final state in TokenState.values) {
        for (final circle in [false, true]) {
          await tester.pumpApp(
            host(
              CaptureToken(
                label: '3',
                state: state,
                circle: circle,
                onTap: () {},
              ),
            ),
          );

          final size = tester.getSize(find.byType(CaptureToken));
          expect(size.height, greaterThanOrEqualTo(44));
          expect(size.width, greaterThanOrEqualTo(44));
          if (circle) expect(size, equals(const Size(44, 44)));
        }
      }
    });

    testWidgets('tells a screen reader what it means', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        host(
          CaptureToken(
            label: '3',
            state: TokenState.selected,
            semanticsLabel: 'Mood 3',
            onTap: () {},
          ),
        ),
      );

      expect(find.bySemanticsLabel('Mood 3'), findsOneWidget);
      handle.dispose();
    });
  });

  group(DashedBorderPainter, () {
    test('repaints only when its color changes', () {
      const painter = DashedBorderPainter(color: Color(0xFF000000));

      expect(
        painter.shouldRepaint(
          const DashedBorderPainter(color: Color(0xFFFFFFFF)),
        ),
        isTrue,
      );
      expect(
        painter.shouldRepaint(
          const DashedBorderPainter(color: Color(0xFF000000)),
        ),
        isFalse,
      );
    });
  });
}
