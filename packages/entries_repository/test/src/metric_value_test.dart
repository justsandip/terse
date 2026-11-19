import 'package:entries_repository/entries_repository.dart';
import 'package:test/test.dart';

void main() {
  group(MetricValue, () {
    group(NumberValue, () {
      test('supports value equality', () {
        expect(const NumberValue(4), equals(const NumberValue(4)));
        expect(const NumberValue(4), isNot(equals(const NumberValue(5))));
      });
    });

    group(BooleanValue, () {
      test('supports value equality', () {
        expect(const BooleanValue(true), equals(const BooleanValue(true)));
        expect(
          const BooleanValue(true),
          isNot(equals(const BooleanValue(false))),
        );
      });
    });

    group(ChoiceValue, () {
      test('supports value equality', () {
        expect(const ChoiceValue('walk'), equals(const ChoiceValue('walk')));
        expect(
          const ChoiceValue('walk'),
          isNot(equals(const ChoiceValue('run'))),
        );
      });
    });

    test('values of different kinds are never equal', () {
      expect(const NumberValue(1), isNot(equals(const BooleanValue(true))));
    });
  });
}
