import 'package:entries_repository/entries_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/l10n/l10n.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('formatNumber', () {
    test('adds the short unit', () {
      expect(MetricCatalog.sleepHours.formatNumber(l10n, 6.5), '6.5 h');
      expect(MetricCatalog.sleepHours.formatNumber(l10n, 7), '7 h');
      expect(MetricCatalog.exerciseMinutes.formatNumber(l10n, 30), '30 min');
    });

    test('uses the singular for one cup', () {
      expect(MetricCatalog.caffeine.formatNumber(l10n, 1), '1 cup');
      expect(MetricCatalog.caffeine.formatNumber(l10n, 2), '2 cups');
    });

    test('shows a custom unit as written, and no unit as a bare number', () {
      const km = MetricDefinition(
        key: 'run_km',
        kind: MetricKind.number,
        unit: 'km',
      );
      const bare = MetricDefinition(key: 'count', kind: MetricKind.number);

      expect(km.formatNumber(l10n, 3), '3 km');
      expect(bare.formatNumber(l10n, 3), '3');
    });
  });

  group('optionLabel', () {
    test('names the built-in options and keeps unknown ones', () {
      final labels = [
        for (final option in MetricCatalog.exerciseType.choices)
          MetricCatalog.exerciseType.optionLabel(l10n, option),
      ];

      expect(labels, equals(['None', 'Walk', 'Gym', 'Run', 'Yoga', 'Other']));
      expect(MetricCatalog.exerciseType.optionLabel(l10n, 'swim'), 'swim');
    });
  });

  group('describeValue', () {
    test('describes each kind of value', () {
      expect(
        MetricCatalog.mood.describeValue(l10n, const NumberValue(3.6)),
        '4',
      );
      expect(
        MetricCatalog.sleepHours.describeValue(l10n, const NumberValue(7)),
        '7 h',
      );
      expect(
        MetricCatalog.exerciseType.describeValue(
          l10n,
          const ChoiceValue('walk'),
        ),
        'Walk',
      );
      const flag = MetricDefinition(key: 'flag', kind: MetricKind.boolean);
      expect(flag.describeValue(l10n, const BooleanValue(true)), 'Yes');
      expect(flag.describeValue(l10n, const BooleanValue(false)), 'No');
    });
  });
}
