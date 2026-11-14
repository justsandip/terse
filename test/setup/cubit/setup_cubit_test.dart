import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terse/setup/setup.dart';

void main() {
  const fullSelection = {
    SetupMetric.sleepHours,
    SetupMetric.sleepQuality,
    SetupMetric.mood,
    SetupMetric.energy,
    SetupMetric.stress,
    SetupMetric.caffeine,
  };

  group(SetupCubit, () {
    test('initial state is empty', () {
      expect(SetupCubit().state, equals(const SetupState()));
    });

    group('toggle', () {
      blocTest<SetupCubit, SetupState>(
        'selects a metric that is not selected',
        build: SetupCubit.new,
        act: (cubit) => cubit.toggle(SetupMetric.mood),
        expect: () => [
          const SetupState(selected: {SetupMetric.mood}),
        ],
      );

      blocTest<SetupCubit, SetupState>(
        'deselects a metric that is selected',
        build: SetupCubit.new,
        seed: () => const SetupState(selected: {SetupMetric.mood}),
        act: (cubit) => cubit.toggle(SetupMetric.mood),
        expect: () => [const SetupState()],
      );

      blocTest<SetupCubit, SetupState>(
        'ignores a new metric when the limit is reached',
        build: SetupCubit.new,
        seed: () => const SetupState(selected: fullSelection),
        act: (cubit) => cubit.toggle(SetupMetric.exercise),
        expect: () => <SetupState>[],
      );

      blocTest<SetupCubit, SetupState>(
        'still deselects a metric when the limit is reached',
        build: SetupCubit.new,
        seed: () => const SetupState(selected: fullSelection),
        act: (cubit) => cubit.toggle(SetupMetric.mood),
        expect: () => [
          SetupState(selected: {...fullSelection}..remove(SetupMetric.mood)),
        ],
      );
    });

    group('applyTemplate', () {
      blocTest<SetupCubit, SetupState>(
        'replaces the selection with the template metrics',
        build: SetupCubit.new,
        seed: () => const SetupState(selected: {SetupMetric.caffeine}),
        act: (cubit) => cubit.applyTemplate(SetupTemplate.mood),
        expect: () => [
          SetupState(selected: SetupTemplate.mood.metrics.toSet()),
        ],
      );
    });
  });
}
