// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/capture/capture.dart';

class _MockMetricsRepository extends Mock implements MetricsRepository;

class _MockEntriesRepository extends Mock implements EntriesRepository;

void main() {
  const sleep = MetricCatalog.sleepHours;
  const mood = MetricCatalog.mood;
  const exercise = MetricCatalog.exerciseType;
  const metrics = [sleep, mood, exercise];

  final today = DateTime(2026, 11, 19);
  final yesterday = DateTime(2026, 11, 18);
  final morning = DateTime(2026, 11, 19, 8);

  late MetricsRepository metricsRepository;
  late EntriesRepository entriesRepository;
  late DateTime clock;

  setUpAll(() {
    registerFallbackValue(Entry(date: DateTime(2026)));
  });

  setUp(() {
    metricsRepository = _MockMetricsRepository();
    entriesRepository = _MockEntriesRepository();
    clock = morning;

    when(() => metricsRepository.fetchMetrics())
        .thenAnswer((_) async => metrics);
    when(() => entriesRepository.fetchEntry(any()))
        .thenAnswer((_) async => null);
    when(() => entriesRepository.saveEntry(any())).thenAnswer((_) async {});
  });

  CaptureBloc buildBloc({DateTime? date}) => CaptureBloc(
    metricsRepository: metricsRepository,
    entriesRepository: entriesRepository,
    date: date,
    now: () => clock,
  );

  CaptureState ready({
    Map<String, MetricValue> suggestions = const {},
    Set<String> fromYesterday = const {},
    Map<String, MetricValue> confirmed = const {},
    String note = '',
    DateTime? startedAt,
    CaptureStatus status = CaptureStatus.ready,
  }) {
    return CaptureState(
      status: status,
      date: today,
      metrics: metrics,
      suggestions: suggestions,
      suggestedFromYesterday: fromYesterday,
      confirmed: confirmed,
      note: note,
      startedAt: startedAt,
    );
  }

  group(CaptureBloc, () {
    test('starts loading', () {
      expect(buildBloc().state, equals(const CaptureState()));
    });

    group('CaptureStarted', () {
      blocTest<CaptureBloc, CaptureState>(
        'suggests the start value of numbers when there is no history',
        build: buildBloc,
        act: (bloc) => bloc.add(const CaptureStarted()),
        expect: () => [
          CaptureState(),
          ready(suggestions: const {'sleep_hours': NumberValue(7)}),
        ],
      );

      blocTest<CaptureBloc, CaptureState>(
        "suggests yesterday's values over the start value",
        setUp: () {
          when(() => entriesRepository.fetchEntry(yesterday)).thenAnswer(
            (_) async => Entry(
              date: yesterday,
              values: const {
                'sleep_hours': NumberValue(6.5),
                'mood': NumberValue(4),
                'exercise_type': ChoiceValue('walk'),
              },
            ),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CaptureStarted()),
        expect: () => [
          CaptureState(),
          ready(
            suggestions: const {
              'sleep_hours': NumberValue(6.5),
              'mood': NumberValue(4),
              'exercise_type': ChoiceValue('walk'),
            },
            fromYesterday: const {'sleep_hours', 'mood', 'exercise_type'},
          ),
        ],
      );

      blocTest<CaptureBloc, CaptureState>(
        'keeps what today already has and suggests only the rest',
        setUp: () {
          when(() => entriesRepository.fetchEntry(today)).thenAnswer(
            (_) async => Entry(
              date: today,
              values: const {'sleep_hours': NumberValue(8)},
              note: 'slept well',
            ),
          );
          when(() => entriesRepository.fetchEntry(yesterday)).thenAnswer(
            (_) async => Entry(
              date: yesterday,
              values: const {
                'sleep_hours': NumberValue(6),
                'mood': NumberValue(2),
              },
            ),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CaptureStarted()),
        expect: () => [
          CaptureState(),
          ready(
            suggestions: const {'mood': NumberValue(2)},
            fromYesterday: const {'mood'},
            confirmed: const {'sleep_hours': NumberValue(8)},
            note: 'slept well',
          ),
        ],
      );

      blocTest<CaptureBloc, CaptureState>(
        'logs the given day, and suggests from the day before it',
        setUp: () {
          when(() => entriesRepository.fetchEntry(DateTime(2026, 11, 10)))
              .thenAnswer(
                (_) async => Entry(
                  date: DateTime(2026, 11, 10),
                  values: const {'mood': NumberValue(5)},
                  note: 'a long day',
                ),
              );
          when(() => entriesRepository.fetchEntry(DateTime(2026, 11, 9)))
              .thenAnswer(
                (_) async => Entry(
                  date: DateTime(2026, 11, 9),
                  values: const {'sleep_hours': NumberValue(6)},
                ),
              );
        },
        // Only the calendar day counts, not the time of day.
        build: () => buildBloc(date: DateTime(2026, 11, 10, 22, 30)),
        act: (bloc) => bloc.add(const CaptureStarted()),
        expect: () => [
          CaptureState(),
          CaptureState(
            status: CaptureStatus.ready,
            date: DateTime(2026, 11, 10),
            isToday: false,
            metrics: metrics,
            suggestions: const {'sleep_hours': NumberValue(6)},
            suggestedFromYesterday: const {'sleep_hours'},
            confirmed: const {'mood': NumberValue(5)},
            note: 'a long day',
          ),
        ],
        verify: (_) {
          verifyNever(() => entriesRepository.fetchEntry(today));
        },
      );

      blocTest<CaptureBloc, CaptureState>(
        'treats the given day as today when it is today',
        build: () => buildBloc(date: DateTime(2026, 11, 19, 23)),
        act: (bloc) => bloc.add(const CaptureStarted()),
        expect: () => [
          CaptureState(),
          ready(suggestions: const {'sleep_hours': NumberValue(7)}),
        ],
      );

      blocTest<CaptureBloc, CaptureState>(
        'fails when the metrics cannot be read',
        setUp: () {
          when(() => metricsRepository.fetchMetrics())
              .thenThrow(const FetchMetricsFailure('boom'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CaptureStarted()),
        expect: () => [
          CaptureState(),
          const CaptureState(status: CaptureStatus.loadFailure),
        ],
        errors: () => [isA<FetchMetricsFailure>()],
      );

      blocTest<CaptureBloc, CaptureState>(
        'fails when an entry cannot be read',
        setUp: () {
          when(() => entriesRepository.fetchEntry(any()))
              .thenThrow(const FetchEntryFailure('boom'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CaptureStarted()),
        expect: () => [
          CaptureState(),
          const CaptureState(status: CaptureStatus.loadFailure),
        ],
        errors: () => [isA<FetchEntryFailure>()],
      );
    });

    group('CaptureValueSet', () {
      blocTest<CaptureBloc, CaptureState>(
        'confirms a value and starts the clock once',
        build: buildBloc,
        seed: ready,
        act: (bloc) async {
          bloc.add(const CaptureValueSet('mood', NumberValue(3)));
          await Future<void>.delayed(Duration.zero);
          clock = morning.add(const Duration(seconds: 5));
          bloc.add(const CaptureValueSet('sleep_hours', NumberValue(7)));
        },
        expect: () => [
          ready(confirmed: const {'mood': NumberValue(3)}, startedAt: morning),
          ready(
            confirmed: const {
              'mood': NumberValue(3),
              'sleep_hours': NumberValue(7),
            },
            startedAt: morning,
          ),
        ],
      );

      blocTest<CaptureBloc, CaptureState>(
        'is ignored while loading',
        build: buildBloc,
        act: (bloc) => bloc.add(const CaptureValueSet('mood', NumberValue(3))),
        expect: () => <CaptureState>[],
      );
    });

    group('CaptureValueCleared', () {
      blocTest<CaptureBloc, CaptureState>(
        'takes a value back',
        build: buildBloc,
        seed: () => ready(
          confirmed: const {
            'mood': NumberValue(3),
            'sleep_hours': NumberValue(7),
          },
        ),
        act: (bloc) => bloc.add(const CaptureValueCleared('mood')),
        expect: () => [
          ready(
            confirmed: const {'sleep_hours': NumberValue(7)},
            startedAt: morning,
          ),
        ],
      );

      blocTest<CaptureBloc, CaptureState>(
        'is ignored while saving',
        build: buildBloc,
        seed: () => ready(
          confirmed: const {'mood': NumberValue(3)},
          status: CaptureStatus.saving,
        ),
        act: (bloc) => bloc.add(const CaptureValueCleared('mood')),
        expect: () => <CaptureState>[],
      );
    });

    group('CaptureHabitsConfirmed', () {
      blocTest<CaptureBloc, CaptureState>(
        'confirms suggested habits but not scales or set values',
        build: buildBloc,
        seed: () => ready(
          suggestions: const {
            'sleep_hours': NumberValue(7),
            'mood': NumberValue(4),
            'exercise_type': ChoiceValue('walk'),
          },
          confirmed: const {'exercise_type': ChoiceValue('gym')},
        ),
        act: (bloc) => bloc.add(const CaptureHabitsConfirmed()),
        expect: () => [
          ready(
            suggestions: const {
              'sleep_hours': NumberValue(7),
              'mood': NumberValue(4),
              'exercise_type': ChoiceValue('walk'),
            },
            confirmed: const {
              'exercise_type': ChoiceValue('gym'),
              'sleep_hours': NumberValue(7),
            },
            startedAt: morning,
          ),
        ],
      );

      blocTest<CaptureBloc, CaptureState>(
        'does nothing when there is nothing to confirm',
        build: buildBloc,
        seed: () => ready(suggestions: const {'mood': NumberValue(4)}),
        act: (bloc) => bloc.add(const CaptureHabitsConfirmed()),
        expect: () => <CaptureState>[],
      );

      blocTest<CaptureBloc, CaptureState>(
        'does nothing while saving',
        build: buildBloc,
        seed: () => ready(
          suggestions: const {'sleep_hours': NumberValue(7)},
          status: CaptureStatus.saving,
        ),
        act: (bloc) => bloc.add(const CaptureHabitsConfirmed()),
        expect: () => <CaptureState>[],
      );
    });

    group('CaptureNoteChanged', () {
      blocTest<CaptureBloc, CaptureState>(
        'keeps the note',
        build: buildBloc,
        seed: ready,
        act: (bloc) => bloc.add(const CaptureNoteChanged('tired')),
        expect: () => [ready(note: 'tired', startedAt: morning)],
      );

      blocTest<CaptureBloc, CaptureState>(
        'is ignored while loading',
        build: buildBloc,
        act: (bloc) => bloc.add(const CaptureNoteChanged('tired')),
        expect: () => <CaptureState>[],
      );
    });

    group('CaptureEditRequested', () {
      blocTest<CaptureBloc, CaptureState>(
        'reopens a saved day',
        build: buildBloc,
        seed: () => ready(status: CaptureStatus.saved),
        act: (bloc) => bloc.add(const CaptureEditRequested()),
        expect: () => [ready()],
      );

      blocTest<CaptureBloc, CaptureState>(
        'is ignored when the day is not saved',
        build: buildBloc,
        seed: ready,
        act: (bloc) => bloc.add(const CaptureEditRequested()),
        expect: () => <CaptureState>[],
      );
    });

    group('CaptureSubmitted', () {
      blocTest<CaptureBloc, CaptureState>(
        'saves a day that is not today under its own date, without a time',
        build: buildBloc,
        seed: () => CaptureState(
          status: CaptureStatus.ready,
          date: yesterday,
          isToday: false,
          metrics: metrics,
          confirmed: const {'mood': NumberValue(3)},
          startedAt: morning,
        ),
        act: (bloc) {
          clock = morning.add(const Duration(seconds: 14));
          bloc.add(const CaptureSubmitted());
        },
        expect: () => [
          isA<CaptureState>().having(
            (state) => state.status,
            'status',
            CaptureStatus.saving,
          ),
          isA<CaptureState>()
              .having((state) => state.status, 'status', CaptureStatus.saved)
              .having((state) => state.elapsed, 'elapsed', isNull),
        ],
        verify: (_) {
          verify(
            () => entriesRepository.saveEntry(
              Entry(
                date: yesterday,
                values: const {'mood': NumberValue(3)},
                note: '',
              ),
            ),
          ).called(1);
        },
      );

      blocTest<CaptureBloc, CaptureState>(
        'saves only the confirmed values and times the logging',
        build: buildBloc,
        seed: () => ready(
          suggestions: const {'sleep_hours': NumberValue(7)},
          confirmed: const {'mood': NumberValue(3)},
          note: 'ok',
          startedAt: morning,
        ),
        act: (bloc) {
          clock = morning.add(const Duration(seconds: 14));
          bloc.add(const CaptureSubmitted());
        },
        expect: () => [
          ready(
            suggestions: const {'sleep_hours': NumberValue(7)},
            confirmed: const {'mood': NumberValue(3)},
            note: 'ok',
            startedAt: morning,
            status: CaptureStatus.saving,
          ),
          CaptureState(
            status: CaptureStatus.saved,
            date: today,
            metrics: metrics,
            suggestions: const {'sleep_hours': NumberValue(7)},
            confirmed: const {'mood': NumberValue(3)},
            note: 'ok',
            startedAt: morning,
            elapsed: const Duration(seconds: 14),
          ),
        ],
        verify: (_) {
          verify(
            () => entriesRepository.saveEntry(
              Entry(
                date: today,
                values: const {'mood': NumberValue(3)},
                note: 'ok',
              ),
            ),
          ).called(1);
        },
      );

      blocTest<CaptureBloc, CaptureState>(
        'has no time when the user changed nothing',
        build: buildBloc,
        seed: () => ready(confirmed: const {'mood': NumberValue(3)}),
        act: (bloc) => bloc.add(const CaptureSubmitted()),
        expect: () => [
          ready(
            confirmed: const {'mood': NumberValue(3)},
            status: CaptureStatus.saving,
          ),
          ready(
            confirmed: const {'mood': NumberValue(3)},
            status: CaptureStatus.saved,
          ),
        ],
      );

      blocTest<CaptureBloc, CaptureState>(
        'does nothing when there is nothing to save',
        build: buildBloc,
        seed: ready,
        act: (bloc) => bloc.add(const CaptureSubmitted()),
        expect: () => <CaptureState>[],
        verify: (_) {
          verifyNever(() => entriesRepository.saveEntry(any()));
        },
      );

      blocTest<CaptureBloc, CaptureState>(
        'keeps the values when saving fails',
        setUp: () {
          when(() => entriesRepository.saveEntry(any()))
              .thenThrow(const SaveEntryFailure('boom'));
        },
        build: buildBloc,
        seed: () => ready(confirmed: const {'mood': NumberValue(3)}),
        act: (bloc) => bloc.add(const CaptureSubmitted()),
        expect: () => [
          ready(
            confirmed: const {'mood': NumberValue(3)},
            status: CaptureStatus.saving,
          ),
          ready(
            confirmed: const {'mood': NumberValue(3)},
            status: CaptureStatus.saveFailure,
          ),
        ],
        errors: () => [isA<SaveEntryFailure>()],
      );
    });
  });
}
