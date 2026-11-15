import 'package:metrics_repository/metrics_repository.dart';
import 'package:test/test.dart';

void main() {
  group(MetricCatalog, () {
    test('has the eight built-in metrics with unique keys', () {
      final keys = MetricCatalog.all.map((metric) => metric.key).toSet();

      expect(MetricCatalog.all, hasLength(8));
      expect(keys, hasLength(MetricCatalog.all.length));
    });

    test('uses snake_case keys', () {
      for (final metric in MetricCatalog.all) {
        expect(metric.key, matches(RegExp(r'^[a-z]+(_[a-z]+)*$')));
      }
    });

    test('scales run from 1 to 5', () {
      final scales = MetricCatalog.all.where(
        (metric) => metric.kind == MetricKind.scale,
      );

      expect(scales, isNotEmpty);
      for (final metric in scales) {
        expect(metric.min, equals(1));
        expect(metric.max, equals(5));
      }
    });

    test('numbers have a unit and limits', () {
      final numbers = MetricCatalog.all.where(
        (metric) => metric.kind == MetricKind.number,
      );

      expect(numbers, isNotEmpty);
      for (final metric in numbers) {
        expect(metric.unit, isNotNull);
        expect(metric.min, isNotNull);
        expect(metric.max, isNotNull);
      }
    });

    test('choices have options', () {
      final choices = MetricCatalog.all.where(
        (metric) => metric.kind == MetricKind.choice,
      );

      expect(choices, isNotEmpty);
      for (final metric in choices) {
        expect(metric.choices, isNotEmpty);
      }
    });

    group('byKey', () {
      test('returns the metric with that key', () {
        expect(MetricCatalog.byKey('mood'), equals(MetricCatalog.mood));
      });

      test('returns null for an unknown key', () {
        expect(MetricCatalog.byKey('unknown'), isNull);
      });
    });
  });
}
