import 'package:bloc_test/bloc_test.dart';
import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/entry/entry.dart';

class _MockMetricsRepository extends Mock implements MetricsRepository;

class _MockEntriesRepository extends Mock implements EntriesRepository;

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

  late MetricsRepository metricsRepository;
  late EntriesRepository entriesRepository;

  setUp(() {
    metricsRepository = _MockMetricsRepository();
    entriesRepository = _MockEntriesRepository();

    when(() => metricsRepository.fetchMetrics())
        .thenAnswer((_) async => metrics);
    when(() => entriesRepository.fetchEntry(day))
        .thenAnswer((_) async => entry);
    when(() => entriesRepository.deleteEntry(day)).thenAnswer((_) async {});
  });

  EntryBloc buildBloc() => EntryBloc(
    metricsRepository: metricsRepository,
    entriesRepository: entriesRepository,
    // Only the calendar day counts, not the time of day.
    date: DateTime(2026, 11, 17, 21, 30),
  );

  EntryState loaded({EntryStatus status = EntryStatus.loaded}) {
    return EntryState(
      date: day,
      status: status,
      metrics: metrics,
      entry: entry,
    );
  }

  group(EntryBloc, () {
    test('starts loading on the day, without the time', () {
      expect(buildBloc().state, equals(EntryState(date: day)));
    });

    group('EntryStarted', () {
      blocTest<EntryBloc, EntryState>(
        'loads the entry of the day',
        build: buildBloc,
        act: (bloc) => bloc.add(const EntryStarted()),
        expect: () => [EntryState(date: day), loaded()],
      );

      blocTest<EntryBloc, EntryState>(
        'says so when the day has no entry',
        setUp: () {
          when(() => entriesRepository.fetchEntry(day))
              .thenAnswer((_) async => null);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const EntryStarted()),
        expect: () => [
          EntryState(date: day),
          EntryState(date: day, status: EntryStatus.notFound, metrics: metrics),
        ],
      );

      blocTest<EntryBloc, EntryState>(
        'fails when the metrics cannot be read',
        setUp: () {
          when(() => metricsRepository.fetchMetrics())
              .thenThrow(const FetchMetricsFailure('boom'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const EntryStarted()),
        expect: () => [
          EntryState(date: day),
          EntryState(date: day, status: EntryStatus.failure),
        ],
        errors: () => [isA<FetchMetricsFailure>()],
      );

      blocTest<EntryBloc, EntryState>(
        'fails when the entry cannot be read',
        setUp: () {
          when(() => entriesRepository.fetchEntry(day))
              .thenThrow(const FetchEntryFailure('boom'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const EntryStarted()),
        expect: () => [
          EntryState(date: day),
          EntryState(date: day, status: EntryStatus.failure),
        ],
        errors: () => [isA<FetchEntryFailure>()],
      );

      blocTest<EntryBloc, EntryState>(
        'shows the loading state again when retried',
        build: buildBloc,
        seed: () => EntryState(date: day, status: EntryStatus.failure),
        act: (bloc) => bloc.add(const EntryStarted()),
        expect: () => [EntryState(date: day), loaded()],
      );
    });

    group('EntryRefreshed', () {
      blocTest<EntryBloc, EntryState>(
        'reads the entry again without the loading state',
        setUp: () {
          when(() => entriesRepository.fetchEntry(day)).thenAnswer(
            (_) async =>
                Entry(date: day, values: const {'mood': NumberValue(2)}),
          );
        },
        build: buildBloc,
        seed: loaded,
        act: (bloc) => bloc.add(const EntryRefreshed()),
        expect: () => [
          EntryState(
            date: day,
            status: EntryStatus.loaded,
            metrics: metrics,
            entry: Entry(date: day, values: const {'mood': NumberValue(2)}),
          ),
        ],
      );
    });

    group('EntryDeleted', () {
      blocTest<EntryBloc, EntryState>(
        'deletes the entry',
        build: buildBloc,
        seed: loaded,
        act: (bloc) => bloc.add(const EntryDeleted()),
        expect: () => [
          loaded(status: EntryStatus.deleting),
          loaded(status: EntryStatus.deleted),
        ],
        verify: (_) {
          verify(() => entriesRepository.deleteEntry(day)).called(1);
        },
      );

      blocTest<EntryBloc, EntryState>(
        'keeps the entry when deleting fails',
        setUp: () {
          when(() => entriesRepository.deleteEntry(day))
              .thenThrow(const DeleteEntryFailure('boom'));
        },
        build: buildBloc,
        seed: loaded,
        act: (bloc) => bloc.add(const EntryDeleted()),
        expect: () => [
          loaded(status: EntryStatus.deleting),
          loaded(status: EntryStatus.deleteFailure),
        ],
        errors: () => [isA<DeleteEntryFailure>()],
      );

      blocTest<EntryBloc, EntryState>(
        'can be tried again after a failure',
        build: buildBloc,
        seed: () => loaded(status: EntryStatus.deleteFailure),
        act: (bloc) => bloc.add(const EntryDeleted()),
        expect: () => [
          loaded(status: EntryStatus.deleting),
          loaded(status: EntryStatus.deleted),
        ],
      );

      blocTest<EntryBloc, EntryState>(
        'is ignored when there is no entry shown',
        build: buildBloc,
        act: (bloc) => bloc.add(const EntryDeleted()),
        expect: () => <EntryState>[],
        verify: (_) {
          verifyNever(() => entriesRepository.deleteEntry(any()));
        },
      );
    });
  });
}
