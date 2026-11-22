import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/history/history.dart';

void main() {
  const metrics = [MetricCatalog.sleepHours, MetricCatalog.mood];

  final today = DateTime(2026, 11, 22);
  final november = DateTime(2026, 11);
  final october = DateTime(2026, 10);

  final full = Entry(
    date: DateTime(2026, 11, 16),
    values: const {'sleep_hours': NumberValue(6), 'mood': NumberValue(3)},
  );
  final partial = Entry(
    date: DateTime(2026, 11, 17),
    values: const {'mood': NumberValue(4)},
  );

  HistoryState loaded({
    DateTime? month,
    List<Entry> entries = const [],
    DateTime? now,
  }) {
    return HistoryState(
      status: HistoryStatus.loaded,
      today: now ?? today,
      month: month ?? november,
      metrics: metrics,
      entries: entries,
    );
  }

  group(HistoryState, () {
    test('starts loading, with nothing shown', () {
      const state = HistoryState();

      expect(state.status, equals(HistoryStatus.loading));
      expect(state.isCurrentMonth, isFalse);
      expect(state.canShowNext, isFalse);
      expect(state.daysSoFar, isZero);
      expect(state.loggedDays, isZero);
      expect(state.recent, isEmpty);
    });

    test('knows whether it shows the current month', () {
      expect(loaded().isCurrentMonth, isTrue);
      expect(loaded(month: october).isCurrentMonth, isFalse);
    });

    test('can go forward only from a past month', () {
      expect(loaded().canShowNext, isFalse);
      expect(loaded(month: october).canShowNext, isTrue);
    });

    test('counts the days so far, today included', () {
      expect(loaded().daysSoFar, equals(22));
      expect(loaded(month: october).daysSoFar, equals(31));
      expect(loaded(month: DateTime(2026, 2)).daysSoFar, equals(28));
    });

    test('counts logged days and lists them newest first', () {
      final state = loaded(entries: [full, partial]);

      expect(state.loggedDays, equals(2));
      expect(state.recent, equals([partial, full]));
    });

    test('finds the entry of a day, ignoring the time', () {
      final state = loaded(entries: [full, partial]);

      expect(state.entryOn(DateTime(2026, 11, 17, 23, 59)), equals(partial));
      expect(state.entryOn(DateTime(2026, 11, 18)), isNull);
      expect(state.entryOn(DateTime(2026, 10, 17)), isNull);
      expect(state.entryOn(DateTime(2025, 11, 17)), isNull);
    });

    test('tells how much of a day was logged', () {
      final state = loaded(entries: [full, partial]);

      expect(state.coverageOf(DateTime(2026, 11, 16)), DayCoverage.all);
      expect(state.coverageOf(DateTime(2026, 11, 17)), DayCoverage.some);
      expect(state.coverageOf(DateTime(2026, 11, 18)), DayCoverage.none);
    });

    test('never calls a day complete when no metric is tracked', () {
      final state = HistoryState(
        status: HistoryStatus.loaded,
        today: today,
        month: november,
        entries: [full],
      );

      expect(state.coverageOf(DateTime(2026, 11, 16)), DayCoverage.some);
    });

    test('counts only the metrics tracked now', () {
      final onlyOldValue = Entry(
        date: DateTime(2026, 11, 18),
        values: const {'reading': NumberValue(30)},
      );
      final state = loaded(entries: [onlyOldValue]);

      expect(state.coverageOf(DateTime(2026, 11, 18)), DayCoverage.some);
    });
  });
}
