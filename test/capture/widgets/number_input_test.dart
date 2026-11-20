import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/capture/capture.dart';

import '../../helpers/helpers.dart';

void main() {
  group(NumberInput, () {
    MetricValue? changed;
    var cleared = 0;

    setUp(() {
      changed = null;
      cleared = 0;
    });

    Future<void> pumpInput(
      WidgetTester tester, {
      MetricDefinition metric = MetricCatalog.sleepHours,
      MetricValue? value,
      MetricValue? suggestion,
    }) {
      return tester.pumpApp(
        Scaffold(
          body: Center(
            child: NumberInput(
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

    CaptureToken token(WidgetTester tester) {
      return tester.widget<CaptureToken>(find.byType(CaptureToken));
    }

    testWidgets('shows a value with its unit as confirmed', (tester) async {
      await pumpInput(tester, value: const NumberValue(6.5));

      expect(find.text('6.5 h'), findsOneWidget);
      expect(token(tester).state, equals(TokenState.confirmed));
    });

    testWidgets('steps up and down by the step of the metric', (tester) async {
      await pumpInput(tester, value: const NumberValue(6.5));

      await tester.tap(find.byTooltip('More Sleep hours'));
      expect(changed, equals(const NumberValue(7)));

      await tester.tap(find.byTooltip('Less Sleep hours'));
      expect(changed, equals(const NumberValue(6)));
    });

    testWidgets('clears a confirmed value when its pill is tapped', (
      tester,
    ) async {
      await pumpInput(tester, value: const NumberValue(6.5));

      await tester.tap(find.byType(CaptureToken));

      expect(cleared, equals(1));
      expect(changed, isNull);
    });

    testWidgets('shows a suggestion faded and confirms it when tapped', (
      tester,
    ) async {
      await pumpInput(tester, suggestion: const NumberValue(7));

      expect(find.text('7 h'), findsOneWidget);
      expect(token(tester).state, equals(TokenState.ghost));

      await tester.tap(find.byType(CaptureToken));

      expect(changed, equals(const NumberValue(7)));
    });

    testWidgets('starts from the suggestion when + or - is pressed', (
      tester,
    ) async {
      await pumpInput(tester, suggestion: const NumberValue(7));

      await tester.tap(find.byTooltip('More Sleep hours'));
      expect(changed, equals(const NumberValue(7.5)));

      await tester.tap(find.byTooltip('Less Sleep hours'));
      expect(changed, equals(const NumberValue(6.5)));
    });

    testWidgets('shows "Not set" when there is nothing, and starts at start', (
      tester,
    ) async {
      await pumpInput(tester);

      expect(find.text('Not set'), findsOneWidget);
      expect(token(tester).state, equals(TokenState.idle));

      await tester.tap(find.byType(CaptureToken));

      expect(changed, equals(const NumberValue(7)));
    });

    testWidgets('falls back to the minimum, then to zero', (tester) async {
      await pumpInput(
        tester,
        metric: const MetricDefinition(
          key: 'km',
          kind: MetricKind.number,
          unit: 'km',
          min: 2,
        ),
      );
      await tester.tap(find.byType(CaptureToken));
      expect(changed, equals(const NumberValue(2)));

      await pumpInput(
        tester,
        metric: const MetricDefinition(key: 'n', kind: MetricKind.number),
      );
      await tester.tap(find.byType(CaptureToken));
      expect(changed, equals(const NumberValue(0)));
    });

    testWidgets('stays inside the bounds', (tester) async {
      await pumpInput(tester, value: const NumberValue(16));
      await tester.tap(find.byTooltip('More Sleep hours'));
      expect(changed, equals(const NumberValue(16)));

      await pumpInput(tester, value: const NumberValue(0));
      await tester.tap(find.byTooltip('Less Sleep hours'));
      expect(changed, equals(const NumberValue(0)));
    });

    testWidgets('has no bounds when the metric has none', (tester) async {
      await pumpInput(
        tester,
        metric: const MetricDefinition(key: 'n', kind: MetricKind.number),
        value: const NumberValue(1),
      );

      await tester.tap(find.byTooltip('Less n'));

      expect(changed, equals(const NumberValue(0)));
    });

    testWidgets('does not leave rounding errors from small steps', (
      tester,
    ) async {
      await pumpInput(
        tester,
        metric: const MetricDefinition(
          key: 'x',
          kind: MetricKind.number,
          step: 0.1,
        ),
        value: const NumberValue(0.2),
      );

      await tester.tap(find.byTooltip('More x'));

      expect(changed, equals(const NumberValue(0.3)));
    });

    testWidgets('names the unit in the singular for one cup', (tester) async {
      await pumpInput(
        tester,
        metric: MetricCatalog.caffeine,
        value: const NumberValue(1),
      );

      expect(find.text('1 cup'), findsOneWidget);
    });

    testWidgets('ignores a value of another kind', (tester) async {
      await pumpInput(tester, value: const ChoiceValue('walk'));

      expect(find.text('Not set'), findsOneWidget);
    });
  });
}
