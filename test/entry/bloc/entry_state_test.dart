import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/entry/entry.dart';

void main() {
  const sleep = MetricCatalog.sleepHours;
  const mood = MetricCatalog.mood;
  const metrics = [sleep, mood];

  final day = DateTime(2026, 11, 17);
  final entry = Entry(
    date: day,
    values: const {'mood': NumberValue(4)},
    note: 'Good run.',
  );

  EntryState loaded({EntryStatus status = EntryStatus.loaded}) {
    return EntryState(
      date: day,
      status: status,
      metrics: metrics,
      entry: entry,
    );
  }

  group(EntryState, () {
    test('starts loading, without an entry', () {
      final state = EntryState(date: day);

      expect(state.status, equals(EntryStatus.loading));
      expect(state.metrics, isEmpty);
      expect(state.entry, isNull);
      expect(state.trackedCount, isZero);
    });

    test('counts the metrics the entry has a value for', () {
      expect(loaded().trackedCount, equals(1));
    });

    test('does not count values of metrics that are not tracked any more', () {
      final state = EntryState(
        date: day,
        status: EntryStatus.loaded,
        metrics: const [sleep],
        entry: entry,
      );

      expect(state.trackedCount, isZero);
    });

    test('copyWith changes only what it is given', () {
      expect(loaded().copyWith(), equals(loaded()));
      expect(
        loaded().copyWith(status: EntryStatus.deleting),
        equals(loaded(status: EntryStatus.deleting)),
      );
    });
  });
}
