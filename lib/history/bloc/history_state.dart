part of 'history_bloc.dart';

enum HistoryStatus { loading, loaded, failure }

/// How much of a day the user logged.
enum DayCoverage { none, some, all }

final class HistoryState extends Equatable {
  const new({
    this.status = HistoryStatus.loading,
    this.today,
    this.month,
    this.metrics = const [],
    this.entries = const [],
  });

  final HistoryStatus status;

  /// The current calendar day. `null` until the first load starts.
  final DateTime? today;

  /// The first day of the month shown. `null` until the first load starts.
  final DateTime? month;

  /// The metrics the user tracks now.
  final List<MetricDefinition> metrics;

  /// The entries of [month], oldest first. Days without one are missing.
  final List<Entry> entries;

  bool get isCurrentMonth {
    final today = this.today;
    return today != null && month == DateTime(today.year, today.month);
  }

  /// Whether a later month exists to go to. The future has no entries.
  bool get canShowNext {
    final today = this.today;
    final month = this.month;
    return today != null &&
        month != null &&
        month.isBefore(DateTime(today.year, today.month));
  }

  /// The days of [month] that have passed, today included.
  int get daysSoFar {
    final today = this.today;
    final month = this.month;
    if (today == null || month == null) return 0;
    return isCurrentMonth
        ? today.day
        : DateTime(month.year, month.month + 1, 0).day;
  }

  int get loggedDays => entries.length;

  /// The entries of [month], newest first.
  List<Entry> get recent => entries.reversed.toList();

  /// The entry for [day], ignoring its time, or `null`.
  Entry? entryOn(DateTime day) {
    for (final entry in entries) {
      if (entry.date.year == day.year &&
          entry.date.month == day.month &&
          entry.date.day == day.day) {
        return entry;
      }
    }
    return null;
  }

  DayCoverage coverageOf(DateTime day) {
    final entry = entryOn(day);
    if (entry == null) return DayCoverage.none;
    final complete =
        metrics.isNotEmpty &&
        metrics.every((metric) => entry.values.containsKey(metric.key));
    return complete ? DayCoverage.all : DayCoverage.some;
  }

  @override
  List<Object?> get props => [status, today, month, metrics, entries];
}
