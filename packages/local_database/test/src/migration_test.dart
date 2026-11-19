// For testing purposes
// ignore_for_file: avoid_redundant_argument_values

import 'package:drift/native.dart';
import 'package:local_database/local_database.dart';
import 'package:test/test.dart';

void main() {
  group('$LocalDatabase migration from version 1', () {
    test('keeps the metrics and adds the entry tables', () async {
      final database = LocalDatabase(
        NativeDatabase.memory(
          setup: (raw) {
            raw
              ..execute('''
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
              ''')
              ..execute('''
                INSERT INTO metrics (id, key, kind, created_at, updated_at)
                VALUES ('mood', 'mood', 'scale', 1, 1)
              ''')
              ..execute('PRAGMA user_version = 1');
          },
        ),
      );
      addTearDown(database.close);

      final metrics = await database.fetchMetrics();

      final now = DateTime.utc(2026, 11, 15);
      await database.saveEntry(
        EntryRow(
          id: 'a',
          date: '2026-11-18',
          note: null,
          createdAt: now,
          updatedAt: now,
          deletedAt: null,
        ),
        [
          const EntryValueRow(
            entryId: 'a',
            metricId: 'mood',
            numberValue: 4,
            textValue: null,
          ),
        ],
      );

      expect(metrics.single.key, equals('mood'));
      expect(await database.fetchEntryValues('a'), hasLength(1));
    });
  });
}
