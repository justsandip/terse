import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/capture/capture.dart';

import '../../helpers/helpers.dart';

void main() {
  group(ChoiceInput, () {
    MetricValue? changed;
    var cleared = 0;

    setUp(() {
      changed = null;
      cleared = 0;
    });

    Future<void> pumpInput(
      WidgetTester tester, {
      MetricDefinition metric = MetricCatalog.exerciseType,
      MetricValue? value,
      MetricValue? suggestion,
    }) {
      return tester.pumpApp(
        Scaffold(
          body: Center(
            child: ChoiceInput(
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

    testWidgets('shows a pill for each option', (tester) async {
      await pumpInput(tester);

      for (final label in ['None', 'Walk', 'Gym', 'Run', 'Yoga', 'Other']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('picks the option that is tapped', (tester) async {
      await pumpInput(tester);

      await tester.tap(find.text('Gym'));

      expect(changed, equals(const ChoiceValue('gym')));
    });

    testWidgets('selects the chosen option and clears it when tapped', (
      tester,
    ) async {
      await pumpInput(tester, value: const ChoiceValue('gym'));

      expect(tokens(tester, TokenState.selected).single.label, 'Gym');

      await tester.tap(find.text('Gym'));

      expect(cleared, equals(1));
    });

    testWidgets('fades the suggested option and confirms it when tapped', (
      tester,
    ) async {
      await pumpInput(tester, suggestion: const ChoiceValue('walk'));

      expect(tokens(tester, TokenState.ghost).single.label, 'Walk');

      await tester.tap(find.text('Walk'));

      expect(changed, equals(const ChoiceValue('walk')));
    });

    testWidgets('shows an option that is not built in as written', (
      tester,
    ) async {
      await pumpInput(
        tester,
        metric: const MetricDefinition(
          key: 'c',
          kind: MetricKind.choice,
          choices: ['swim'],
        ),
        value: const NumberValue(1),
      );

      expect(find.text('swim'), findsOneWidget);
    });
  });
}
