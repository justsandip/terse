part of 'capture_bloc.dart';

/// Where the capture screen is.
enum CaptureStatus {
  /// Reading the metrics and entries.
  loading,

  /// Reading failed.
  loadFailure,

  /// The user can log.
  ready,

  /// The day is being saved.
  saving,

  /// Saving failed. The user's values are kept, so they can try again.
  saveFailure,

  /// The day is saved.
  saved,
}

final class CaptureState extends Equatable {
  const new({
    this.status = CaptureStatus.loading,
    this.date,
    this.metrics = const [],
    this.suggestions = const {},
    this.suggestedFromYesterday = const {},
    this.confirmed = const {},
    this.note = '',
    this.startedAt,
    this.elapsed,
  });

  final CaptureStatus status;

  /// The calendar day being logged. `null` until loaded.
  final DateTime? date;

  /// The metrics the user tracks, in their order.
  final List<MetricDefinition> metrics;

  /// What the screen shows faded: yesterday's value, or the metric's start
  /// value when there is no history. Not saved until the user confirms it.
  final Map<String, MetricValue> suggestions;

  /// The keys of [suggestions] that are yesterday's values. The others are
  /// start values.
  final Set<String> suggestedFromYesterday;

  /// What the user set or confirmed. Only this is saved.
  final Map<String, MetricValue> confirmed;

  final String note;

  /// When the user first changed anything, to time how long logging took.
  final DateTime? startedAt;

  /// How long logging took, once saved. `null` if the user changed nothing.
  final Duration? elapsed;

  bool get isEditable =>
      status == CaptureStatus.ready || status == CaptureStatus.saveFailure;

  bool get canSave =>
      isEditable && (confirmed.isNotEmpty || note.trim().isNotEmpty);

  /// The keys "Same as yesterday" would confirm: suggested metrics the user
  /// has not set. Scales are left out on purpose, because carrying a feeling
  /// over would make the data flat.
  List<String> get habitsToConfirm => [
    for (final metric in metrics)
      if (metric.kind != MetricKind.scale &&
          suggestions.containsKey(metric.key) &&
          !confirmed.containsKey(metric.key))
        metric.key,
  ];

  CaptureState copyWith({
    CaptureStatus? status,
    DateTime? date,
    List<MetricDefinition>? metrics,
    Map<String, MetricValue>? suggestions,
    Map<String, MetricValue>? confirmed,
    String? note,
    DateTime? startedAt,
    Duration? elapsed,
  }) {
    return CaptureState(
      status: status ?? this.status,
      date: date ?? this.date,
      metrics: metrics ?? this.metrics,
      suggestions: suggestions ?? this.suggestions,
      suggestedFromYesterday: suggestedFromYesterday,
      confirmed: confirmed ?? this.confirmed,
      note: note ?? this.note,
      startedAt: startedAt ?? this.startedAt,
      elapsed: elapsed ?? this.elapsed,
    );
  }

  @override
  List<Object?> get props => [
    status,
    date,
    metrics,
    suggestions,
    suggestedFromYesterday,
    confirmed,
    note,
    startedAt,
    elapsed,
  ];
}
