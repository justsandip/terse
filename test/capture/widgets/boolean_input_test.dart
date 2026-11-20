import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/capture/capture.dart';

import '../../helpers/helpers.dart';

void main() {
  group(BooleanInput, () {
    MetricValue? changed;
    var cleared = 0;

    setUp(() {
      changed = null;
      cleared = 0;
    });

    Future<void> pumpInput(
      WidgetTester tester, {
      MetricValue? value,
      MetricValue? suggestion,
    }) {
      return tester.pumpApp(
        Scaffold(
          body: Center(
            child: BooleanInput(
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

    testWidgets('answers yes or no', (tester) async {
      await pumpInput(tester);

      await tester.tap(find.text('Yes'));
      expect(changed, equals(const BooleanValue(true)));

      await tester.tap(find.text('No'));
      expect(changed, equals(const BooleanValue(false)));
    });

    testWidgets('selects the answer and clears it when tapped', (tester) async {
      await pumpInput(tester, value: const BooleanValue(true));

      expect(tokens(tester, TokenState.selected).single.label, 'Yes');

      await tester.tap(find.text('Yes'));

      expect(cleared, equals(1));
    });

    testWidgets('fades the suggested answer, even when it is no', (
      tester,
    ) async {
      await pumpInput(tester, suggestion: const BooleanValue(false));

      expect(tokens(tester, TokenState.ghost).single.label, 'No');

      await tester.tap(find.text('No'));

      expect(changed, equals(const BooleanValue(false)));
    });
  });
}
