import 'package:flutter_test/flutter_test.dart';
import 'package:terse/history/history.dart';

void main() {
  group(HistoryEvent, () {
    test('supports value comparison', () {
      expect(const HistoryStarted(), equals(const HistoryStarted()));
      expect(
        const HistoryMonthShifted(-1),
        equals(const HistoryMonthShifted(-1)),
      );
      expect(
        const HistoryMonthShifted(-1),
        isNot(equals(const HistoryMonthShifted(1))),
      );
      expect(const HistoryRefreshed(), equals(const HistoryRefreshed()));
    });

    test('props are correct', () {
      expect(const HistoryStarted().props, equals([]));
      expect(const HistoryMonthShifted(-1).props, equals([-1]));
      expect(const HistoryMonthShifted(-1).props, isNot(equals([1])));
      expect(const HistoryRefreshed().props, equals([]));
    });
  });
}
