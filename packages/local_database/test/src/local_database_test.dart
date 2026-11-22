// For testing purposes
// ignore_for_file: avoid_redundant_argument_values

import 'package:drift/native.dart';
import 'package:local_database/local_database.dart';
import 'package:test/test.dart';

void main() {
  group(LocalDatabase, () {
    final now = DateTime.utc(2026, 11, 15);

    late LocalDatabase database;

    MetricRow metric({
      required String id,
      required String key,
      String kind = 'scale',
      int position = 0,
      double? stepValue,
      double? startValue,
      DateTime? archivedAt,
      DateTime? deletedAt,
    }) {
      return MetricRow(
        id: id,
        key: key,
        kind: kind,
        unit: null,
        minValue: 1,
        maxValue: 5,
        choices: null,
        stepValue: stepValue,
        startValue: startValue,
        position: position,
        archivedAt: archivedAt,
        createdAt: now,
        updatedAt: now,
        deletedAt: deletedAt,
      );
    }

    EntryRow entry({
      required String id,
      String date = '2026-11-18',
      String? note,
      DateTime? deletedAt,
    }) {
      return EntryRow(
        id: id,
        date: date,
        note: note,
        createdAt: now,
        updatedAt: now,
        deletedAt: deletedAt,
      );
    }

    EntryValueRow value({
      required String entryId,
      required String metricId,
      double? numberValue,
      String? textValue,
    }) {
      return EntryValueRow(
        entryId: entryId,
        metricId: metricId,
        numberValue: numberValue,
        textValue: textValue,
      );
    }

    setUp(() {
      database = LocalDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('is at schema version 3', () {
      expect(database.schemaVersion, equals(3));
    });

    group('fetchMetrics', () {
      test('returns nothing when no metric was saved', () async {
        expect(await database.fetchMetrics(), isEmpty);
      });

      test('returns metrics in position order', () async {
        await database.upsertMetrics([
          metric(id: 'b', key: 'energy', position: 1),
          metric(id: 'a', key: 'mood', position: 0),
        ]);

        final rows = await database.fetchMetrics();

        expect(rows.map((row) => row.key), equals(['mood', 'energy']));
      });

      test('leaves out archived and deleted metrics', () async {
        await database.upsertMetrics([
          metric(id: 'a', key: 'mood'),
          metric(id: 'b', key: 'energy', archivedAt: now),
          metric(id: 'c', key: 'stress', deletedAt: now),
        ]);

        final rows = await database.fetchMetrics();

        expect(rows.map((row) => row.key), equals(['mood']));
      });
    });

    group('fetchAllMetrics', () {
      test('returns every metric, archived and deleted ones too', () async {
        await database.upsertMetrics([
          metric(id: 'a', key: 'mood'),
          metric(id: 'b', key: 'energy', archivedAt: now),
          metric(id: 'c', key: 'stress', deletedAt: now),
        ]);

        final rows = await database.fetchAllMetrics();

        expect(
          rows.map((row) => row.key),
          unorderedEquals(['mood', 'energy', 'stress']),
        );
      });
    });

    group('upsertMetrics', () {
      test('updates a metric that already exists', () async {
        await database.upsertMetrics([metric(id: 'a', key: 'mood')]);
        await database.upsertMetrics([
          metric(id: 'a', key: 'mood', kind: 'number'),
        ]);

        final rows = await database.fetchMetrics();

        expect(rows, hasLength(1));
        expect(rows.single.kind, equals('number'));
      });

      test('keeps the step and the start value of a number', () async {
        await database.upsertMetrics([
          metric(
            id: 'a',
            key: 'sleep',
            kind: 'number',
            stepValue: 0.5,
            startValue: 7,
          ),
        ]);

        final rows = await database.fetchMetrics();

        expect(rows.single.stepValue, equals(0.5));
        expect(rows.single.startValue, equals(7));
      });

      test('rejects two metrics that share a key', () async {
        await expectLater(
          database.upsertMetrics([
            metric(id: 'a', key: 'mood'),
            metric(id: 'b', key: 'mood'),
          ]),
          throwsA(anything),
        );
      });
    });

    group('entries', () {
      setUp(() async {
        await database.upsertMetrics([
          metric(id: 'mood', key: 'mood'),
          metric(id: 'sleep', key: 'sleep', kind: 'number'),
          metric(id: 'exercise', key: 'exercise', kind: 'choice'),
        ]);
      });

      group('fetchEntryByDate', () {
        test('returns null when the day has no entry', () async {
          expect(await database.fetchEntryByDate('2026-11-18'), isNull);
        });

        test('returns the entry of that day', () async {
          await database.saveEntry(entry(id: 'a', note: 'Good run'), []);

          final row = await database.fetchEntryByDate('2026-11-18');

          expect(row?.id, equals('a'));
          expect(row?.note, equals('Good run'));
        });

        test('leaves out a deleted entry', () async {
          await database.saveEntry(entry(id: 'a', deletedAt: now), []);

          expect(await database.fetchEntryByDate('2026-11-18'), isNull);
        });

        test('returns a deleted entry when asked to', () async {
          await database.saveEntry(entry(id: 'a', deletedAt: now), []);

          final row = await database.fetchEntryByDate(
            '2026-11-18',
            includeDeleted: true,
          );

          expect(row?.id, equals('a'));
        });
      });

      group('fetchEntriesBetween', () {
        test('returns nothing when there are no entries', () async {
          expect(
            await database.fetchEntriesBetween('2026-11-01', '2026-11-30'),
            isEmpty,
          );
        });

        test(
          'returns the days in range, both ends included, oldest first',
          () async {
            await database.saveEntry(entry(id: 'c', date: '2026-11-18'), []);
            await database.saveEntry(entry(id: 'a', date: '2026-11-16'), []);
            await database.saveEntry(entry(id: 'b', date: '2026-11-17'), []);
            await database.saveEntry(entry(id: 'x', date: '2026-11-15'), []);
            await database.saveEntry(entry(id: 'y', date: '2026-11-19'), []);

            final rows = await database.fetchEntriesBetween(
              '2026-11-16',
              '2026-11-18',
            );

            expect(rows.map((row) => row.id), equals(['a', 'b', 'c']));
          },
        );

        test('leaves out a deleted entry', () async {
          await database.saveEntry(entry(id: 'a', date: '2026-11-16'), []);
          await database.saveEntry(
            entry(id: 'b', date: '2026-11-17', deletedAt: now),
            [],
          );

          final rows = await database.fetchEntriesBetween(
            '2026-11-16',
            '2026-11-18',
          );

          expect(rows.map((row) => row.id), equals(['a']));
        });

        test('returns nothing when the range is backwards', () async {
          await database.saveEntry(entry(id: 'a', date: '2026-11-17'), []);

          expect(
            await database.fetchEntriesBetween('2026-11-18', '2026-11-16'),
            isEmpty,
          );
        });
      });

      group('fetchValuesBetween', () {
        test('returns the values of the entries in range only', () async {
          await database.saveEntry(entry(id: 'a', date: '2026-11-16'), [
            value(entryId: 'a', metricId: 'mood', numberValue: 4),
            value(entryId: 'a', metricId: 'exercise', textValue: 'walk'),
          ]);
          await database.saveEntry(entry(id: 'b', date: '2026-11-17'), [
            value(entryId: 'b', metricId: 'mood', numberValue: 2),
          ]);
          await database.saveEntry(entry(id: 'c', date: '2026-11-25'), [
            value(entryId: 'c', metricId: 'mood', numberValue: 5),
          ]);

          final rows = await database.fetchValuesBetween(
            '2026-11-16',
            '2026-11-17',
          );

          expect(
            rows.map((row) => (row.entryId, row.metricId)),
            unorderedEquals([('a', 'mood'), ('a', 'exercise'), ('b', 'mood')]),
          );
        });

        test('leaves out the values of a deleted entry', () async {
          await database.saveEntry(entry(id: 'a', date: '2026-11-16'), [
            value(entryId: 'a', metricId: 'mood', numberValue: 4),
          ]);
          await database.saveEntry(
            entry(id: 'a', date: '2026-11-16', deletedAt: now),
            [value(entryId: 'a', metricId: 'mood', numberValue: 4)],
          );

          expect(
            await database.fetchValuesBetween('2026-11-16', '2026-11-16'),
            isEmpty,
          );
        });

        test('returns nothing when there are no entries', () async {
          expect(
            await database.fetchValuesBetween('2026-11-01', '2026-11-30'),
            isEmpty,
          );
        });
      });

      group('saveEntry', () {
        test('saves an entry with its values', () async {
          await database.saveEntry(entry(id: 'a'), [
            value(entryId: 'a', metricId: 'mood', numberValue: 4),
            value(entryId: 'a', metricId: 'exercise', textValue: 'walk'),
          ]);

          final rows = await database.fetchEntryValues('a');

          expect(
            rows.map((row) => row.metricId),
            unorderedEquals(['mood', 'exercise']),
          );
          expect(
            rows.singleWhere((row) => row.metricId == 'mood').numberValue,
            equals(4),
          );
          expect(
            rows.singleWhere((row) => row.metricId == 'exercise').textValue,
            equals('walk'),
          );
        });

        test('saves an entry that has no values', () async {
          await database.saveEntry(entry(id: 'a'), []);

          expect(await database.fetchEntryValues('a'), isEmpty);
        });

        test('replaces the values the entry had before', () async {
          await database.saveEntry(entry(id: 'a'), [
            value(entryId: 'a', metricId: 'mood', numberValue: 4),
            value(entryId: 'a', metricId: 'sleep', numberValue: 6.5),
          ]);

          await database.saveEntry(entry(id: 'a', note: 'Edited'), [
            value(entryId: 'a', metricId: 'mood', numberValue: 2),
          ]);

          final rows = await database.fetchEntryValues('a');

          expect(rows, hasLength(1));
          expect(rows.single.metricId, equals('mood'));
          expect(rows.single.numberValue, equals(2));
          expect(
            (await database.fetchEntryByDate('2026-11-18'))?.note,
            equals('Edited'),
          );
        });

        test('keeps the values of other entries', () async {
          await database.saveEntry(entry(id: 'a'), [
            value(entryId: 'a', metricId: 'mood', numberValue: 4),
          ]);

          await database.saveEntry(entry(id: 'b', date: '2026-11-19'), [
            value(entryId: 'b', metricId: 'mood', numberValue: 3),
          ]);

          expect(await database.fetchEntryValues('a'), hasLength(1));
          expect(await database.fetchEntryValues('b'), hasLength(1));
        });

        test('rejects two entries for the same day', () async {
          await database.saveEntry(entry(id: 'a'), []);

          await expectLater(
            database.saveEntry(entry(id: 'b'), []),
            throwsA(anything),
          );
        });

        test('rejects a value for a metric that does not exist', () async {
          await expectLater(
            database.saveEntry(entry(id: 'a'), [
              value(entryId: 'a', metricId: 'missing', numberValue: 1),
            ]),
            throwsA(anything),
          );
        });

        test('rejects a value that holds nothing', () async {
          await expectLater(
            database.saveEntry(entry(id: 'a'), [
              value(entryId: 'a', metricId: 'mood'),
            ]),
            throwsA(anything),
          );
        });

        test('leaves the old entry as it was when a save fails', () async {
          await database.saveEntry(entry(id: 'a'), [
            value(entryId: 'a', metricId: 'mood', numberValue: 4),
          ]);

          await expectLater(
            database.saveEntry(entry(id: 'a', note: 'Broken'), [
              value(entryId: 'a', metricId: 'missing', numberValue: 1),
            ]),
            throwsA(anything),
          );

          final rows = await database.fetchEntryValues('a');

          expect(rows.single.metricId, equals('mood'));
          expect((await database.fetchEntryByDate('2026-11-18'))?.note, isNull);
        });
      });
    });
  });
}
