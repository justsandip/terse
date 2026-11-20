import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/capture/capture.dart';

import '../../helpers/helpers.dart';

void main() {
  group(ScaleInput, () {
    MetricValue? changed;
    var cleared = 0;

    setUp(() {
      changed = null;
      cleared = 0;
    });

    Future<void> pumpInput(
      WidgetTester tester, {
      MetricDefinition metric = MetricCatalog.mood,
      MetricValue? value,
      MetricValue? suggestion,
    }) {
      return tester.pumpApp(
        Scaffold(
          body: Center(
            child: ScaleInput(
              metric: metric,
              value: value,
              suggestion: suggestion,
              onChanged: (next) => changed = next,
              onCleared: () => cleared++,
            ),
          ),
        ),
      );
    }

    Iterable<CaptureToken> tokens(WidgetTester tester, TokenState state) {
      return tester
          .widgetList<CaptureToken>(find.byType(CaptureToken))
          .where((token) => token.state == state);
    }

    testWidgets('shows a dot for each step of the scale', (tester) async {
      await pumpInput(tester);

      expect(find.byType(CaptureToken), findsNWidgets(5));
      expect(tokens(tester, TokenState.idle), hasLength(5));
    });

    testWidgets('uses 1 to 5 when the scale has no bounds', (tester) async {
      await pumpInput(
        tester,
        metric: const MetricDefinition(key: 'x', kind: MetricKind.scale),
      );

      expect(find.byType(CaptureToken), findsNWidgets(5));
    });

    testWidgets('follows the bounds of the scale', (tester) async {
      await pumpInput(
        tester,
        metric: const MetricDefinition(
          key: 'x',
          kind: MetricKind.scale,
          min: 1,
          max: 10,
        ),
      );

      expect(find.byType(CaptureToken), findsNWidgets(10));
    });

    testWidgets('sets the value that is tapped', (tester) async {
      await pumpInput(tester);

      await tester.tap(find.text('3'));

      expect(changed, equals(const NumberValue(3)));
      expect(cleared, isZero);
    });

    testWidgets('selects the dot of the value and clears it when tapped', (
      tester,
    ) async {
      await pumpInput(tester, value: const NumberValue(3));

      expect(tokens(tester, TokenState.selected).single.label, '3');

      await tester.tap(find.text('3'));

      expect(cleared, equals(1));
      expect(changed, isNull);
    });

    testWidgets('fades the suggested dot', (tester) async {
      await pumpInput(tester, suggestion: const NumberValue(4));

      expect(tokens(tester, TokenState.ghost).single.label, '4');

      await tester.tap(find.text('4'));

      expect(changed, equals(const NumberValue(4)));
    });

    testWidgets('shows no ghost once the user has set a value', (tester) async {
      await pumpInput(
        tester,
        value: const NumberValue(3),
        suggestion: const NumberValue(4),
      );

      expect(tokens(tester, TokenState.ghost), isEmpty);
    });

    testWidgets('ignores a value of another kind', (tester) async {
      await pumpInput(tester, value: const ChoiceValue('walk'));

      expect(tokens(tester, TokenState.idle), hasLength(5));
    });
  });
}
