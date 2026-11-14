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

  group(SetupState, () {
    test('starts empty and cannot start', () {
      const state = SetupState();

      expect(state.selected, isEmpty);
      expect(state.canStart, isFalse);
      expect(state.isFull, isFalse);
    });

    test('can start once a metric is selected', () {
      const state = SetupState(selected: {SetupMetric.mood});

      expect(state.canStart, isTrue);
    });

    test('is full at the limit', () {
      const state = SetupState(selected: fullSelection);

      expect(fullSelection, hasLength(SetupState.maxMetrics));
      expect(state.isFull, isTrue);
    });

    test('supports value comparison', () {
      expect(
        const SetupState(selected: {SetupMetric.mood}),
        equals(const SetupState(selected: {SetupMetric.mood})),
      );
    });
  });

  group(SetupTemplate, () {
    test('every template has unique metrics within the limit', () {
      for (final template in SetupTemplate.values) {
        expect(template.metrics, isNotEmpty);
        expect(template.metrics.toSet(), hasLength(template.metrics.length));
        expect(
          template.metrics.length,
          lessThanOrEqualTo(SetupState.maxMetrics),
        );
      }
    });
  });
}
