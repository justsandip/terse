import 'dart:convert';

import 'package:local_database/local_database.dart';
import 'package:metrics_repository/metrics_repository.dart';

/// {@template metrics_repository}
/// Stores the metrics a user chose to track.
/// {@endtemplate}
class MetricsRepository {
  /// {@macro metrics_repository}
  const new({required this._database, this._now = _utcNow});

  final LocalDatabase _database;
  final DateTime Function() _now;

  static DateTime _utcNow() => DateTime.now().toUtc();

  /// Returns the metrics the user is tracking, in the order they chose.
  ///
  /// Throws a [FetchMetricsFailure] if reading or decoding fails.
  Future<List<MetricDefinition>> fetchMetrics() async {
    try {
      final rows = await _database.fetchMetrics();
      return [for (final row in rows) _toDefinition(row)];
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(FetchMetricsFailure(error), stackTrace);
    }
  }

  /// Saves [metrics] as the ones the user tracks, in the given order.
  ///
  /// A metric that was tracked before and is missing from [metrics] is
  /// archived, not deleted, so the values already recorded for it stay valid.
  /// A metric that was archived and is chosen again is brought back.
  ///
  /// Throws a [SaveMetricsFailure] if saving fails.
  Future<void> saveMetrics(List<MetricDefinition> metrics) async {
    try {
      final existing = {
        for (final row in await _database.fetchAllMetrics()) row.id: row,
      };
      final now = _now();
      final chosen = <String>{};
      final rows = <MetricRow>[];

      for (final (index, metric) in metrics.indexed) {
        chosen.add(metric.key);
        rows.add(
          MetricRow(
            id: metric.key,
            key: metric.key,
            kind: metric.kind.name,
            unit: metric.unit,
            minValue: metric.min,
            maxValue: metric.max,
            choices: metric.choices.isEmpty ? null : jsonEncode(metric.choices),
            position: index,
            createdAt: existing[metric.key]?.createdAt ?? now,
            updatedAt: now,
          ),
        );
      }

      for (final row in existing.values) {
        final inactive = row.archivedAt != null || row.deletedAt != null;
        if (chosen.contains(row.id) || inactive) continue;
        rows.add(
          MetricRow(
            id: row.id,
            key: row.key,
            kind: row.kind,
            unit: row.unit,
            minValue: row.minValue,
            maxValue: row.maxValue,
            choices: row.choices,
            position: row.position,
            archivedAt: now,
            createdAt: row.createdAt,
            updatedAt: now,
          ),
        );
      }

      await _database.upsertMetrics(rows);
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(SaveMetricsFailure(error), stackTrace);
    }
  }

  static MetricDefinition _toDefinition(MetricRow row) {
    final choices = row.choices;
    return MetricDefinition(
      key: row.key,
      kind: MetricKind.values.byName(row.kind),
      unit: row.unit,
      min: row.minValue,
      max: row.maxValue,
      choices: choices == null
          ? const []
          : (jsonDecode(choices) as List<Object?>).cast<String>(),
    );
  }
}
