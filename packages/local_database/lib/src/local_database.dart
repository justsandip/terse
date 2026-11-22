import 'package:drift/drift.dart';
import 'package:local_database/src/tables.dart';

part 'local_database.g.dart';

/// {@template local_database}
/// Local Database for Terse, backed by Drift
/// {@endtemplate}
@DriftDatabase(tables: [Metrics, Entries, EntryValues])
class LocalDatabase extends _$LocalDatabase {
  /// {@macro local_database}
  new(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(entries);
          await migrator.createTable(entryValues);
        }
        if (from < 3) {
          await migrator.addColumn(metrics, metrics.stepValue);
          await migrator.addColumn(metrics, metrics.startValue);
        }
      },
      beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
    );
  }

  /// Returns the metrics that are neither archived nor deleted,
  /// in position order.
  Future<List<MetricRow>> fetchMetrics() {
    final query = select(metrics)
      ..where(
        (metric) => metric.deletedAt.isNull() & metric.archivedAt.isNull(),
      )
      ..orderBy([(metric) => OrderingTerm.asc(metric.position)]);
    return query.get();
  }

  /// Returns every metric, including the archived and the deleted ones.
  Future<List<MetricRow>> fetchAllMetrics() => select(metrics).get();

  /// Inserts [rows], or updates the rows that already exist.
  Future<void> upsertMetrics(List<MetricRow> rows) {
    return batch((batch) => batch.insertAllOnConflictUpdate(metrics, rows));
  }

  /// Returns the entry for [date] (`YYYY-MM-DD`), or `null` if there is none.
  ///
  /// A deleted entry is left out, unless [includeDeleted] is `true`. A caller
  /// that saves a new entry for a day needs the deleted one too, because a day
  /// can have only one row.
  Future<EntryRow?> fetchEntryByDate(
    String date, {
    bool includeDeleted = false,
  }) {
    final query = select(entries)
      ..where((entry) {
        final onDate = entry.date.equals(date);
        return includeDeleted ? onDate : onDate & entry.deletedAt.isNull();
      });
    return query.getSingleOrNull();
  }

  /// Returns the entries from [from] to [to] (both `YYYY-MM-DD`, both
  /// included), oldest first. Deleted entries are left out.
  Future<List<EntryRow>> fetchEntriesBetween(String from, String to) {
    final query = select(entries)
      ..where(
        (entry) =>
            entry.date.isBetweenValues(from, to) & entry.deletedAt.isNull(),
      )
      ..orderBy([(entry) => OrderingTerm.asc(entry.date)]);
    return query.get();
  }

  /// Returns the values of the entries that [fetchEntriesBetween] returns for
  /// [from] and [to], in no particular order.
  ///
  /// It joins on the entries instead of listing their ids, so a long range
  /// does not hit the limit SQLite puts on the variables of one query.
  Future<List<EntryValueRow>> fetchValuesBetween(String from, String to) {
    final query =
        select(entryValues).join([
          innerJoin(entries, entries.id.equalsExp(entryValues.entryId)),
        ])..where(
          entries.date.isBetweenValues(from, to) & entries.deletedAt.isNull(),
        );
    return query.map((row) => row.readTable(entryValues)).get();
  }

  /// Returns the values saved for the entry with [entryId].
  Future<List<EntryValueRow>> fetchEntryValues(String entryId) {
    final query = select(entryValues)
      ..where((value) => value.entryId.equals(entryId));
    return query.get();
  }

  /// Saves [entry] and makes [values] the whole set of its values.
  ///
  /// Values the entry had before and [values] leaves out are removed. All of it
  /// happens in one transaction, so a failure leaves the old entry as it was.
  Future<void> saveEntry(EntryRow entry, List<EntryValueRow> values) {
    return transaction(() async {
      await into(entries).insertOnConflictUpdate(entry);
      await (delete(
        entryValues,
      )..where((value) => value.entryId.equals(entry.id))).go();
      await batch((batch) => batch.insertAll(entryValues, values));
    });
  }
}
