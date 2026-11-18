import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/setup/setup.dart';

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

  group(SetupState, () {
    test('starts empty, editing, and cannot start', () {
      const state = SetupState();

      expect(state.selected, isEmpty);
      expect(state.status, equals(SetupStatus.editing));
      expect(state.canStart, isFalse);
      expect(state.isFull, isFalse);
    });

    test('can start once a metric is chosen', () {
      const state = SetupState(selected: [mood]);

      expect(state.canStart, isTrue);
    });

    test('cannot start while saving', () {
      const state = SetupState(selected: [mood], status: SetupStatus.saving);

      expect(state.canStart, isFalse);
    });

    test('is full at the limit', () {
      const state = SetupState(selected: fullSelection);

      expect(fullSelection, hasLength(SetupState.maxMetrics));
      expect(state.isFull, isTrue);
    });

    test('lists the built-in metrics that are not chosen', () {
      const state = SetupState(selected: [mood]);

      expect(state.available, isNot(contains(mood)));
      expect(state.available, contains(energy));
      expect(state.available, hasLength(MetricCatalog.all.length - 1));
    });

    group('matchedTemplate', () {
      test('is null when nothing is chosen', () {
        expect(const SetupState().matchedTemplate, isNull);
      });

      test('is the template whose metrics are chosen, in any order', () {
        final reversed = SetupTemplate.mood.metrics.reversed.toList();

        expect(
          SetupState(selected: reversed).matchedTemplate,
          equals(SetupTemplate.mood),
        );
      });

      test('is null when a metric was added to a template', () {
        final state = SetupState(
          selected: [...SetupTemplate.mood.metrics, MetricCatalog.caffeine],
        );

        expect(state.matchedTemplate, isNull);
      });

      test('is null when a metric was removed from a template', () {
        final state = SetupState(
          selected: SetupTemplate.mood.metrics.skip(1).toList(),
        );

        expect(state.matchedTemplate, isNull);
      });
    });

    test('supports value comparison', () {
      expect(
        const SetupState(selected: [mood]),
        equals(const SetupState(selected: [mood])),
      );
      expect(
        const SetupState(selected: [mood]),
        isNot(
          equals(
            const SetupState(selected: [mood], status: SetupStatus.failure),
          ),
        ),
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
