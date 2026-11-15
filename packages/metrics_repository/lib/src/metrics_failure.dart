/// {@template metrics_failure}
/// Base class for failures thrown by the metrics repository.
/// {@endtemplate}
abstract class MetricsFailure implements Exception {
  /// {@macro metrics_failure}
  const new(this.error);

  /// The underlying error.
  final Object error;

  @override
  String toString() => '$runtimeType: $error';
}

/// {@template fetch_metrics_failure}
/// Thrown when reading the chosen metrics fails.
/// {@endtemplate}
class FetchMetricsFailure extends MetricsFailure {
  /// {@macro fetch_metrics_failure}
  const new(super.error);
}

/// {@template save_metrics_failure}
/// Thrown when saving the chosen metrics fails.
/// {@endtemplate}
class SaveMetricsFailure extends MetricsFailure {
  /// {@macro save_metrics_failure}
  const new(super.error);
}
