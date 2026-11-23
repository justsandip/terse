import 'package:flutter_test/flutter_test.dart';
import 'package:terse/entry/entry.dart';

void main() {
  group(EntryEvent, () {
    test('supports value comparison', () {
      expect(const EntryStarted(), equals(const EntryStarted()));
      expect(const EntryRefreshed(), equals(const EntryRefreshed()));
      expect(const EntryDeleted(), equals(const EntryDeleted()));
    });

    test('props are correct', () {
      expect(const EntryStarted().props, equals([]));
      expect(const EntryRefreshed().props, equals([]));
      expect(const EntryDeleted().props, equals([]));
    });
  });
}
