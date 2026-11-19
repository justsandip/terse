import 'package:entries_repository/entries_repository.dart';
import 'package:test/test.dart';

void main() {
  group(EntriesFailure, () {
    test('toString includes the type and the error', () {
      const failure = FetchEntryFailure('boom');

      expect(failure.toString(), equals('FetchEntryFailure: boom'));
    });

    test('every failure keeps the underlying error', () {
      expect(const SaveEntryFailure('a').error, equals('a'));
      expect(const DeleteEntryFailure('b').error, equals('b'));
    });

    group(InvalidEntryFailure, () {
      test('names the metric and the reason', () {
        final failure = InvalidEntryFailure('mood', 'is too high');

        expect(failure.metricKey, equals('mood'));
        expect(
          failure.toString(),
          equals('InvalidEntryFailure: mood: is too high'),
        );
      });
    });
  });
}
