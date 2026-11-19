import 'package:entries_repository/entries_repository.dart';
import 'package:test/test.dart';

void main() {
  group(Entry, () {
    final date = DateTime(2026, 11, 18);

    test('has no values and no note by default', () {
      final entry = Entry(date: date);

      expect(entry.values, isEmpty);
      expect(entry.note, isNull);
    });

    test('supports value equality', () {
      final a = Entry(
        date: date,
        values: const {'mood': NumberValue(4)},
        note: 'ok',
      );
      final b = Entry(
        date: date,
        values: const {'mood': NumberValue(4)},
        note: 'ok',
      );

      expect(a, equals(b));
    });

    test('differs when a value differs', () {
      final a = Entry(date: date, values: const {'mood': NumberValue(4)});
      final b = Entry(date: date, values: const {'mood': NumberValue(3)});

      expect(a, isNot(equals(b)));
    });
  });
}
