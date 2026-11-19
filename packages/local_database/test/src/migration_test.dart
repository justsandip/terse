// For testing purposes
// ignore_for_file: avoid_redundant_argument_values

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:local_database/local_database.dart';
import 'package:test/test.dart';

/// The metrics table as it was in versions 1 and 2.
const _metricsTableBeforeStep = '''
  CREATE TABLE metrics (
    id TEXT NOT NULL,
    key TEXT NOT NULL UNIQUE,
    kind TEXT NOT NULL,
    unit TEXT NULL,
    min_value REAL NULL,
    max_value REAL NULL,
    choices TEXT NULL,
    position INTEGER NOT NULL DEFAULT 0,
    archived_at INTEGER NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER NULL,
    PRIMARY KEY (id)
  )
''';

const _insertMood = '''
  INSERT INTO metrics (id, key, kind, created_at, updated_at)
  VALUES ('mood', 'mood', 'scale', 1, 1)
''';

void main() {
  group('$LocalDatabase migration', () {
    test('from version 1 keeps the metrics and adds the rest', () async {
      final database = LocalDatabase(
        NativeDatabase.memory(
          setup: (raw) {
            raw
              ..execute(_metricsTableBeforeStep)
              ..execute(_insertMood)
              ..execute('PRAGMA user_version = 1');
          },
        ),
      );
      addTearDown(database.close);

      final metrics = await database.fetchMetrics();

      final now = DateTime.utc(2026, 11, 15);
      await database.saveEntry(
        EntryRow(
          id: '2026-11-18',
          date: '2026-11-18',
          note: null,
          createdAt: now,
          updatedAt: now,
          deletedAt: null,
        ),
        [
          const EntryValueRow(
            entryId: '2026-11-18',
            metricId: 'mood',
            numberValue: 4,
            textValue: null,
          ),
        ],
      );

      expect(metrics.single.key, equals('mood'));
      expect(metrics.single.stepValue, isNull);
      expect(metrics.single.startValue, isNull);
      expect(await database.fetchEntryValues('2026-11-18'), hasLength(1));
    });

    test('from version 2 adds the step and the start value', () async {
      final database = LocalDatabase(
        NativeDatabase.memory(
          setup: (raw) {
            raw
              ..execute(_metricsTableBeforeStep)
              ..execute(_insertMood)
              ..execute('PRAGMA user_version = 2');
          },
        ),
      );
      addTearDown(database.close);

      final before = await database.fetchMetrics();
      await database.upsertMetrics([
        before.single.copyWith(
          stepValue: const Value(0.5),
          startValue: const Value(7),
        ),
      ]);
      final after = await database.fetchMetrics();

      expect(before.single.stepValue, isNull);
      expect(after.single.stepValue, equals(0.5));
      expect(after.single.startValue, equals(7));
    });
  });
}
