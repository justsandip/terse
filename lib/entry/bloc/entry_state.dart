part of 'entry_bloc.dart';

/// Where the entry screen is.
enum EntryStatus {
  loading,
  failure,
  notFound,
  loaded,
  deleting,
  deleteFailure,
  deleted,
}

final class EntryState extends Equatable {
  const new({
    required this.date,
    this.status = EntryStatus.loading,
    this.metrics = const [],
    this.entry,
  });

  /// The calendar day of the entry.
  final DateTime date;

  final EntryStatus status;

  /// The metrics the user tracks, in their order.
  final List<MetricDefinition> metrics;

  /// The entry. `null` until loaded, and when there is none.
  final Entry? entry;

  /// How many of [metrics] the entry has a value for.
  int get trackedCount {
    final values = entry?.values;
    if (values == null) return 0;
    return metrics.where((metric) => values.containsKey(metric.key)).length;
  }

  EntryState copyWith({EntryStatus? status}) {
    return EntryState(
      date: date,
      status: status ?? this.status,
      metrics: metrics,
      entry: entry,
    );
  }

  @override
  List<Object?> get props => [date, status, metrics, entry];
}
