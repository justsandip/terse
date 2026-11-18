import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/setup/setup.dart';

class _MockMetricsRepository extends Mock implements MetricsRepository;

void main() {
  const mood = MetricCatalog.mood;
  const energy = MetricCatalog.energy;
  const fullSelection = [
    MetricCatalog.sleepHours,
    MetricCatalog.sleepQuality,
    MetricCatalog.mood,
    MetricCatalog.energy,
    MetricCatalog.stress,
    MetricCatalog.caffeine,
  ];

  group(SetupBloc, () {
    late MetricsRepository metricsRepository;

    setUpAll(() {
      registerFallbackValue(<MetricDefinition>[]);
    });

    setUp(() {
      metricsRepository = _MockMetricsRepository();
    });

    SetupBloc buildBloc() {
      return SetupBloc(metricsRepository: metricsRepository);
    }

    test('initial state is empty', () {
      expect(buildBloc().state, equals(const SetupState()));
    });

    group('SetupMetricAdded', () {
      blocTest<SetupBloc, SetupState>(
        'adds a metric',
        build: buildBloc,
        act: (bloc) => bloc.add(const SetupMetricAdded(mood)),
        expect: () => [
          const SetupState(selected: [mood]),
        ],
      );

      blocTest<SetupBloc, SetupState>(
        'keeps the order metrics were added in',
        build: buildBloc,
        seed: () => const SetupState(selected: [energy]),
        act: (bloc) => bloc.add(const SetupMetricAdded(mood)),
        expect: () => [
          const SetupState(selected: [energy, mood]),
        ],
      );

      blocTest<SetupBloc, SetupState>(
        'does not add the same metric twice',
        build: buildBloc,
        seed: () => const SetupState(selected: [mood]),
        act: (bloc) => bloc.add(const SetupMetricAdded(mood)),
        expect: () => <SetupState>[],
      );

      blocTest<SetupBloc, SetupState>(
        'ignores a metric when the limit is reached',
        build: buildBloc,
        seed: () => const SetupState(selected: fullSelection),
        act: (bloc) =>
            bloc.add(const SetupMetricAdded(MetricCatalog.exerciseType)),
        expect: () => <SetupState>[],
      );
    });

    group('SetupMetricRemoved', () {
      blocTest<SetupBloc, SetupState>(
        'removes a metric',
        build: buildBloc,
        seed: () => const SetupState(selected: [mood, energy]),
        act: (bloc) => bloc.add(const SetupMetricRemoved(mood)),
        expect: () => [
          const SetupState(selected: [energy]),
        ],
      );

      blocTest<SetupBloc, SetupState>(
        'clears a failure',
        build: buildBloc,
        seed: () => const SetupState(
          selected: [mood, energy],
          status: SetupStatus.failure,
        ),
        act: (bloc) => bloc.add(const SetupMetricRemoved(mood)),
        expect: () => [
          const SetupState(selected: [energy]),
        ],
      );
    });

    group('SetupTemplateSelected', () {
      blocTest<SetupBloc, SetupState>(
        'replaces the chosen metrics with the template ones',
        build: buildBloc,
        seed: () => const SetupState(selected: [MetricCatalog.caffeine]),
        act: (bloc) =>
            bloc.add(const SetupTemplateSelected(SetupTemplate.mood)),
        expect: () => [SetupState(selected: SetupTemplate.mood.metrics)],
      );
    });

    group('SetupSubmitted', () {
      blocTest<SetupBloc, SetupState>(
        'saves the chosen metrics and succeeds',
        setUp: () {
          when(() => metricsRepository.saveMetrics(any()))
              .thenAnswer((_) async {});
        },
        build: buildBloc,
        seed: () => const SetupState(selected: [mood, energy]),
        act: (bloc) => bloc.add(const SetupSubmitted()),
        expect: () => [
          const SetupState(
            selected: [mood, energy],
            status: SetupStatus.saving,
          ),
          const SetupState(
            selected: [mood, energy],
            status: SetupStatus.success,
          ),
        ],
        verify: (_) {
          final captured = verify(
            () => metricsRepository.saveMetrics(captureAny()),
          ).captured;
          expect(captured.single, equals([mood, energy]));
        },
      );

      blocTest<SetupBloc, SetupState>(
        'fails and reports the error when saving fails',
        setUp: () {
          when(() => metricsRepository.saveMetrics(any()))
              .thenThrow(const SaveMetricsFailure('oops'));
        },
        build: buildBloc,
        seed: () => const SetupState(selected: [mood]),
        act: (bloc) => bloc.add(const SetupSubmitted()),
        expect: () => [
          const SetupState(selected: [mood], status: SetupStatus.saving),
          const SetupState(selected: [mood], status: SetupStatus.failure),
        ],
        errors: () => [isA<SaveMetricsFailure>()],
      );

      blocTest<SetupBloc, SetupState>(
        'does nothing when no metric is chosen',
        build: buildBloc,
        act: (bloc) => bloc.add(const SetupSubmitted()),
        expect: () => <SetupState>[],
        verify: (_) {
          verifyNever(() => metricsRepository.saveMetrics(any()));
        },
      );

      blocTest<SetupBloc, SetupState>(
        'does nothing while a save is running',
        build: buildBloc,
        seed: () =>
            const SetupState(selected: [mood], status: SetupStatus.saving),
        act: (bloc) => bloc.add(const SetupSubmitted()),
        expect: () => <SetupState>[],
        verify: (_) {
          verifyNever(() => metricsRepository.saveMetrics(any()));
        },
      );
    });
  });
}
