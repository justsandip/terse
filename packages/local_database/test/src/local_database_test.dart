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
        position: position,
        archivedAt: archivedAt,
        createdAt: now,
        updatedAt: now,
        deletedAt: deletedAt,
      );
    }

    setUp(() {
      database = LocalDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('is at schema version 1', () {
      expect(database.schemaVersion, equals(1));
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
  });
}
