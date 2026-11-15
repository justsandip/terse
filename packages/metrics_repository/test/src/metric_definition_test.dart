import 'package:metrics_repository/metrics_repository.dart';
import 'package:test/test.dart';

void main() {
  group(MetricDefinition, () {
    test('supports value comparison', () {
      expect(
        const MetricDefinition(key: 'mood', kind: MetricKind.scale, min: 1),
        equals(
          const MetricDefinition(key: 'mood', kind: MetricKind.scale, min: 1),
        ),
      );
      expect(
        const MetricDefinition(key: 'mood', kind: MetricKind.scale),
        isNot(equals(MetricCatalog.mood)),
      );
    });

    group('toJson', () {
      test('leaves out unset fields', () {
        expect(
          MetricCatalog.mood.toJson(),
          equals({'key': 'mood', 'kind': 'scale', 'min': 1, 'max': 5}),
        );
      });

      test('includes the unit, limits and choices when set', () {
        expect(
          MetricCatalog.sleepHours.toJson(),
          equals({
            'key': 'sleep_hours',
            'kind': 'number',
            'unit': 'hours',
            'min': 0,
            'max': 16,
          }),
        );
        expect(
          MetricCatalog.exerciseType.toJson()['choices'],
          equals(['none', 'walk', 'gym', 'run', 'yoga', 'other']),
        );
      });
    });

    group('fromJson', () {
      test('round-trips every built-in metric', () {
        for (final metric in MetricCatalog.all) {
          expect(MetricDefinition.fromJson(metric.toJson()), equals(metric));
        }
      });

      test('reads a kind without any optional field', () {
        final metric = MetricDefinition.fromJson(const {
          'key': 'walked',
          'kind': 'boolean',
        });

        expect(
          metric,
          equals(
            const MetricDefinition(key: 'walked', kind: MetricKind.boolean),
          ),
        );
      });

      test('throws for an unknown kind', () {
        expect(
          () => MetricDefinition.fromJson(const {'key': 'x', 'kind': 'nope'}),
          throwsArgumentError,
        );
      });
    });
  });
}
