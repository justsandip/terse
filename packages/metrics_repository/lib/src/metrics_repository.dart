import 'dart:convert';

import 'package:metrics_repository/metrics_repository.dart';
import 'package:storage/storage.dart';

/// {@template metrics_repository}
/// Stores the metrics a user chose to track.
/// {@endtemplate}
class MetricsRepository {
  /// {@macro metrics_repository}
  const new({required this._storage});

  /// The storage key that holds the chosen metrics.
  static const metricsKey = '__metrics_key__';

  final Storage _storage;

  /// Returns the metrics the user chose, or an empty list if none were saved.
  ///
  /// Throws a [FetchMetricsFailure] if reading or decoding fails.
  Future<List<MetricDefinition>> fetchMetrics() async {
    try {
      final value = await _storage.read(key: metricsKey);
      if (value == null) return const [];

      final items = jsonDecode(value) as List<Object?>;
      return [
        for (final item in items)
          MetricDefinition.fromJson(item! as Map<String, Object?>),
      ];
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(FetchMetricsFailure(error), stackTrace);
    }
  }

  /// Saves [metrics] as the ones the user chose, replacing any saved before.
  ///
  /// Throws a [SaveMetricsFailure] if saving fails.
  Future<void> saveMetrics(List<MetricDefinition> metrics) async {
    try {
      final value = jsonEncode([for (final m in metrics) m.toJson()]);
      await _storage.write(key: metricsKey, value: value);
    } on Object catch (error, stackTrace) {
      Error.throwWithStackTrace(SaveMetricsFailure(error), stackTrace);
    }
  }
}
