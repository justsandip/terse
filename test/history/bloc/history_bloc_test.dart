import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/history/history.dart';

class _MockMetricsRepository extends Mock implements MetricsRepository;

class _MockEntriesRepository extends Mock implements EntriesRepository;

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

  HistoryState loading({DateTime? month}) {
    return HistoryState(today: today, month: month ?? november);
  }

  group(HistoryBloc, () {
    late MetricsRepository metricsRepository;
    late EntriesRepository entriesRepository;

    setUpAll(() {
      registerFallbackValue(DateTime(2026));
    });

    setUp(() {
      metricsRepository = _MockMetricsRepository();
      entriesRepository = _MockEntriesRepository();

      when(() => metricsRepository.fetchMetrics())
          .thenAnswer((_) async => metrics);
      when(
        () => entriesRepository.fetchEntries(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => []);
    });

    HistoryBloc buildBloc() => HistoryBloc(
      metricsRepository: metricsRepository,
      entriesRepository: entriesRepository,
      now: () => DateTime(2026, 11, 22, 12),
    );

    void stubMonth(DateTime from, DateTime to, List<Entry> entries) {
      when(() => entriesRepository.fetchEntries(from: from, to: to))
          .thenAnswer((_) async => entries);
    }

    test('starts loading', () {
      expect(buildBloc().state, equals(const HistoryState()));
    });

    group('HistoryStarted', () {
      blocTest<HistoryBloc, HistoryState>(
        'loads the current month',
        setUp: () =>
            stubMonth(november, DateTime(2026, 11, 30), [full, partial]),
        build: buildBloc,
        act: (bloc) => bloc.add(const HistoryStarted()),
        expect: () => [
          loading(),
          loaded(entries: [full, partial]),
        ],
      );

      blocTest<HistoryBloc, HistoryState>(
        'fails when the metrics cannot be read',
        setUp: () {
          when(() => metricsRepository.fetchMetrics())
              .thenThrow(const FetchMetricsFailure('boom'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const HistoryStarted()),
        expect: () => [
          loading(),
          HistoryState(
            status: HistoryStatus.failure,
            today: today,
            month: november,
          ),
        ],
        errors: () => [isA<FetchMetricsFailure>()],
      );

      blocTest<HistoryBloc, HistoryState>(
        'fails when the entries cannot be read',
        setUp: () {
          when(
            () => entriesRepository.fetchEntries(
              from: any(named: 'from'),
              to: any(named: 'to'),
            ),
          ).thenThrow(const FetchEntryFailure('boom'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const HistoryStarted()),
        expect: () => [
          loading(),
          HistoryState(
            status: HistoryStatus.failure,
            today: today,
            month: november,
          ),
        ],
        errors: () => [isA<FetchEntryFailure>()],
      );
    });

    group('HistoryMonthShifted', () {
      late Completer<List<Entry>> slowOctober;

      blocTest<HistoryBloc, HistoryState>(
        'goes back a month',
        setUp: () => stubMonth(october, DateTime(2026, 10, 31), [full]),
        build: buildBloc,
        seed: loaded,
        act: (bloc) => bloc.add(const HistoryMonthShifted(-1)),
        expect: () => [
          loading(month: october),
          loaded(month: october, entries: [full]),
        ],
      );

      blocTest<HistoryBloc, HistoryState>(
        'goes forward again',
        setUp: () => stubMonth(november, DateTime(2026, 11, 30), [partial]),
        build: buildBloc,
        seed: () => loaded(month: october),
        act: (bloc) => bloc.add(const HistoryMonthShifted(1)),
        expect: () => [
          loading(),
          loaded(entries: [partial]),
        ],
      );

      blocTest<HistoryBloc, HistoryState>(
        'crosses a year',
        setUp: () => stubMonth(DateTime(2025, 12), DateTime(2025, 12, 31), []),
        build: buildBloc,
        seed: () => loaded(month: DateTime(2026)),
        act: (bloc) => bloc.add(const HistoryMonthShifted(-1)),
        expect: () => [
          loading(month: DateTime(2025, 12)),
          loaded(month: DateTime(2025, 12)),
        ],
      );

      blocTest<HistoryBloc, HistoryState>(
        'does not go past the current month',
        build: buildBloc,
        seed: loaded,
        act: (bloc) => bloc.add(const HistoryMonthShifted(1)),
        expect: () => <HistoryState>[],
      );

      blocTest<HistoryBloc, HistoryState>(
        'is ignored before the first load',
        build: buildBloc,
        act: (bloc) => bloc.add(const HistoryMonthShifted(-1)),
        expect: () => <HistoryState>[],
      );

      blocTest<HistoryBloc, HistoryState>(
        'drops a slow month the user has already left',
        setUp: () {
          final slow = Completer<List<Entry>>();
          when(
            () => entriesRepository.fetchEntries(
              from: october,
              to: DateTime(2026, 10, 31),
            ),
          ).thenAnswer((_) => slow.future);
          stubMonth(DateTime(2026, 9), DateTime(2026, 9, 30), [partial]);
          slowOctober = slow;
        },
        build: buildBloc,
        seed: loaded,
        act: (bloc) async {
          bloc
            ..add(const HistoryMonthShifted(-1))
            ..add(const HistoryMonthShifted(-1));
          await pumpEventQueue();
          slowOctober.complete([full]);
          await pumpEventQueue();
        },
        expect: () => [
          loading(month: october),
          loading(month: DateTime(2026, 9)),
          loaded(month: DateTime(2026, 9), entries: [partial]),
        ],
      );

      blocTest<HistoryBloc, HistoryState>(
        'drops a failure of a month the user has already left',
        setUp: () {
          final slow = Completer<List<Entry>>();
          when(
            () => entriesRepository.fetchEntries(
              from: october,
              to: DateTime(2026, 10, 31),
            ),
          ).thenAnswer((_) => slow.future);
          stubMonth(DateTime(2026, 9), DateTime(2026, 9, 30), []);
          slowOctober = slow;
        },
        build: buildBloc,
        seed: loaded,
        act: (bloc) async {
          bloc
            ..add(const HistoryMonthShifted(-1))
            ..add(const HistoryMonthShifted(-1));
          await pumpEventQueue();
          slowOctober.completeError(const FetchEntryFailure('late'));
          await pumpEventQueue();
        },
        expect: () => [
          loading(month: october),
          loading(month: DateTime(2026, 9)),
          loaded(month: DateTime(2026, 9)),
        ],
        errors: () => [isA<FetchEntryFailure>()],
      );
    });

    group('HistoryRefreshed', () {
      blocTest<HistoryBloc, HistoryState>(
        'reads the shown month again without a loading state',
        setUp: () => stubMonth(november, DateTime(2026, 11, 30), [full]),
        build: buildBloc,
        seed: loaded,
        act: (bloc) => bloc.add(const HistoryRefreshed()),
        expect: () => [
          loaded(entries: [full]),
        ],
      );

      blocTest<HistoryBloc, HistoryState>(
        'is ignored before the first load',
        build: buildBloc,
        act: (bloc) => bloc.add(const HistoryRefreshed()),
        expect: () => <HistoryState>[],
      );
    });
  });
}
