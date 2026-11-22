import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/history/history.dart';

import '../../helpers/helpers.dart';

void main() {
  group(MonthGrid, () {
    const metrics = [MetricCatalog.sleepHours, MetricCatalog.mood];
    final today = DateTime(2026, 11, 22);

    final full = Entry(
      date: DateTime(2026, 11, 16),
      values: const {'sleep_hours': NumberValue(6), 'mood': NumberValue(3)},
    );
    final partial = Entry(
      date: DateTime(2026, 11, 17),
      values: const {'mood': NumberValue(4)},
    );

    HistoryState stateFor({DateTime? month, List<Entry>? entries}) {
      return HistoryState(
        status: HistoryStatus.loaded,
        today: today,
        month: month ?? DateTime(2026, 11),
        metrics: metrics,
        entries: entries ?? [full, partial],
      );
    }

    Future<void> pumpGrid(
      WidgetTester tester,
      HistoryState state, {
      ValueChanged<DateTime>? onDayTap,
    }) {
      return tester.pumpApp(
        Scaffold(
          body: SingleChildScrollView(
            child: MonthGrid(state: state, onDayTap: onDayTap),
          ),
        ),
      );
    }

    testWidgets('shows the weekday initials and every day of the month', (
      tester,
    ) async {
      await pumpGrid(tester, stateFor());

      expect(find.text('S'), findsNWidgets(2));
      expect(find.text('M'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('31'), findsNothing);
    });

    testWidgets('has no extra day in a short month', (tester) async {
      await pumpGrid(tester, stateFor(month: DateTime(2026, 2), entries: []));

      expect(find.text('28'), findsOneWidget);
      expect(find.text('29'), findsNothing);
    });

    testWidgets('puts the first day under its weekday', (tester) async {
      // 1 November 2026 is a Sunday, 1 October 2026 is a Thursday.
      await pumpGrid(tester, stateFor());
      final sunday = tester.getCenter(find.text('1')).dx;

      await pumpGrid(tester, stateFor(month: DateTime(2026, 10), entries: []));
      final thursday = tester.getCenter(find.text('1')).dx;

      expect(thursday, greaterThan(sunday));
      expect(tester.getCenter(find.text('S').first).dx, closeTo(sunday, 1));
    });

    testWidgets('describes each day for a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpGrid(tester, stateFor());

      expect(
        find.bySemanticsLabel('November 16, Everything set'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('November 17, Some set'), findsOneWidget);
      expect(
        find.bySemanticsLabel('November 18, Nothing logged'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('November 22, Nothing logged, today'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('opens a day that has an entry', (tester) async {
      DateTime? tapped;
      await pumpGrid(tester, stateFor(), onDayTap: (day) => tapped = day);

      await tester.tap(find.text('17'));

      expect(tapped, equals(DateTime(2026, 11, 17)));
    });

    testWidgets('does not open a day with nothing logged', (tester) async {
      DateTime? tapped;
      await pumpGrid(tester, stateFor(), onDayTap: (day) => tapped = day);

      await tester.tap(find.text('18'));

      expect(tapped, isNull);
    });

    testWidgets('does not open a day in the future', (tester) async {
      DateTime? tapped;
      final future = Entry(date: DateTime(2026, 11, 25));
      await pumpGrid(
        tester,
        stateFor(entries: [future]),
        onDayTap: (day) => tapped = day,
      );

      await tester.tap(find.text('25'));

      expect(tapped, isNull);
    });

    testWidgets('opens nothing when there is no callback', (tester) async {
      await pumpGrid(tester, stateFor());

      await tester.tap(find.text('17'));

      expect(tester.takeException(), isNull);
    });
  });
}
