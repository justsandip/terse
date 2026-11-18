import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/setup/setup.dart';

void main() {
  const mood = MetricCatalog.mood;
  const energy = MetricCatalog.energy;

  group(SetupEvent, () {
    test('supports value comparison', () {
      expect(
        const SetupMetricAdded(mood),
        equals(const SetupMetricAdded(mood)),
      );
      expect(
        const SetupMetricAdded(mood),
        isNot(equals(const SetupMetricAdded(energy))),
      );
      expect(
        const SetupMetricRemoved(mood),
        equals(const SetupMetricRemoved(mood)),
      );
      expect(
        const SetupTemplateSelected(SetupTemplate.mood),
        equals(const SetupTemplateSelected(SetupTemplate.mood)),
      );
      expect(const SetupSubmitted(), equals(const SetupSubmitted()));
    });

    test('props are correct', () {
      expect(const SetupMetricAdded(mood).props, equals([mood]));
      expect(const SetupMetricAdded(mood).props, isNot(equals([energy])));
      expect(const SetupMetricRemoved(mood).props, equals([mood]));
      expect(
        const SetupTemplateSelected(SetupTemplate.mood).props,
        equals([SetupTemplate.mood]),
      );
      expect(const SetupSubmitted().props, equals([]));
    });
  });
}
