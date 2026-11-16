import 'package:drift/drift.dart';
import 'package:local_database/src/tables.dart';

part 'local_database.g.dart';

/// {@template local_database}
/// Local Database for Terse, backed by Drift
/// {@endtemplate}
@DriftDatabase(tables: [Metrics])
class LocalDatabase extends _$LocalDatabase {
  /// {@macro local_database}
  new(super.e);

  @override
  int get schemaVersion => 1;

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
}
