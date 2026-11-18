import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/setup/setup.dart';

void main() {
  group('MetricDefinitionL10n', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    group('label', () {
      test('names every built-in metric', () {
        final labels = MetricCatalog.all.map((metric) => metric.label(l10n));

        expect(
          labels,
          equals([
            'Sleep hours',
            'Sleep quality',
            'Mood',
            'Energy',
            'Stress',
            'Caffeine',
            'Exercise type',
            'Exercise minutes',
          ]),
        );
      });

      test('falls back to the key for any other metric', () {
        const metric = MetricDefinition(
          key: 'water_glasses',
          kind: MetricKind.number,
        );

        expect(metric.label(l10n), equals('water_glasses'));
      });
    });

    group('description', () {
      test('describes the unit of a number', () {
        expect(MetricCatalog.sleepHours.description(l10n), equals('Hours'));
        expect(MetricCatalog.caffeine.description(l10n), equals('Cups'));
        expect(
          MetricCatalog.exerciseMinutes.description(l10n),
          equals('Minutes'),
        );
      });

      test('shows any other unit as it is', () {
        const metric = MetricDefinition(
          key: 'water',
          kind: MetricKind.number,
          unit: 'liters',
        );

        expect(metric.description(l10n), equals('liters'));
      });

      test('is empty for a number without a unit', () {
        const metric = MetricDefinition(key: 'count', kind: MetricKind.number);

        expect(metric.description(l10n), isEmpty);
      });

      test('describes the range of a scale', () {
        expect(MetricCatalog.mood.description(l10n), equals('1 to 5'));
      });

      test('assumes 1 to 5 for a scale without limits', () {
        const metric = MetricDefinition(key: 'focus', kind: MetricKind.scale);

        expect(metric.description(l10n), equals('1 to 5'));
      });

      test('describes a choice', () {
        expect(
          MetricCatalog.exerciseType.description(l10n),
          equals('One of a list'),
        );
      });

      test('describes a boolean', () {
        const metric = MetricDefinition(
          key: 'walked',
          kind: MetricKind.boolean,
        );

        expect(metric.description(l10n), equals('Yes or no'));
      });
    });
  });
}
