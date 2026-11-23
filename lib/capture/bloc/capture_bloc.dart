import 'package:bloc/bloc.dart';
import 'package:entries_repository/entries_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:metrics_repository/metrics_repository.dart';

part 'capture_event.dart';
part 'capture_state.dart';

class CaptureBloc extends Bloc<CaptureEvent, CaptureState> {
  new({
    required this._metricsRepository,
    required this._entriesRepository,
    this._date,
    this._now = DateTime.now,
  }) : super(const CaptureState()) {
    on<CaptureStarted>(_onStarted);
    on<CaptureValueSet>(_onValueSet);
    on<CaptureValueCleared>(_onValueCleared);
    on<CaptureHabitsConfirmed>(_onHabitsConfirmed);
    on<CaptureNoteChanged>(_onNoteChanged);
    on<CaptureSubmitted>(_onSubmitted);
    on<CaptureEditRequested>(_onEditRequested);
  }

  final MetricsRepository _metricsRepository;
  final EntriesRepository _entriesRepository;

  /// The day to log. Today when `null`. Only the calendar day counts, and it
  /// is up to the caller not to pass a day after today.
  final DateTime? _date;
  final DateTime Function() _now;

  Future<void> _onStarted(
    CaptureStarted event,
    Emitter<CaptureState> emit,
  ) async {
    emit(const CaptureState());
    try {
      final now = _now();
      final today = DateTime(now.year, now.month, now.day);
      final requested = _date;
      final day = requested == null
          ? today
          : DateTime(requested.year, requested.month, requested.day);
      final metrics = await _metricsRepository.fetchMetrics();
      final entry = await _entriesRepository.fetchEntry(day);
      final yesterday = await _entriesRepository.fetchEntry(
        DateTime(day.year, day.month, day.day - 1),
      );

      final saved = entry?.values ?? const <String, MetricValue>{};
      final before = yesterday?.values ?? const <String, MetricValue>{};
      final confirmed = <String, MetricValue>{};
      final suggestions = <String, MetricValue>{};
      final fromYesterday = <String>{};
      for (final metric in metrics) {
        final value = saved[metric.key];
        if (value != null) {
          confirmed[metric.key] = value;
          continue;
        }
        final remembered = before[metric.key];
        final suggestion = remembered ?? _startOf(metric);
        if (suggestion == null) continue;
        suggestions[metric.key] = suggestion;
        if (remembered != null) fromYesterday.add(metric.key);
      }

      emit(
        CaptureState(
          status: CaptureStatus.ready,
          date: day,
          isToday: day == today,
          metrics: metrics,
          suggestions: suggestions,
          suggestedFromYesterday: fromYesterday,
          confirmed: confirmed,
          note: entry?.note ?? '',
        ),
      );
    } on MetricsFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(const CaptureState(status: CaptureStatus.loadFailure));
    } on EntriesFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(const CaptureState(status: CaptureStatus.loadFailure));
    }
  }

  void _onValueSet(CaptureValueSet event, Emitter<CaptureState> emit) {
    if (!state.isEditable) return;
    _edit(
      emit,
      state.copyWith(confirmed: {...state.confirmed, event.key: event.value}),
    );
  }

  void _onValueCleared(CaptureValueCleared event, Emitter<CaptureState> emit) {
    if (!state.isEditable) return;
    _edit(
      emit,
      state.copyWith(confirmed: {...state.confirmed}..remove(event.key)),
    );
  }

  void _onHabitsConfirmed(
    CaptureHabitsConfirmed event,
    Emitter<CaptureState> emit,
  ) {
    final keys = state.habitsToConfirm;
    if (!state.isEditable || keys.isEmpty) return;
    _edit(
      emit,
      state.copyWith(
        confirmed: {
          ...state.confirmed,
          for (final key in keys) key: state.suggestions[key]!,
        },
      ),
    );
  }

  void _onNoteChanged(CaptureNoteChanged event, Emitter<CaptureState> emit) {
    if (!state.isEditable) return;
    _edit(emit, state.copyWith(note: event.note));
  }

  Future<void> _onSubmitted(
    CaptureSubmitted event,
    Emitter<CaptureState> emit,
  ) async {
    if (!state.canSave) return;

    emit(state.copyWith(status: CaptureStatus.saving));
    try {
      await _entriesRepository.saveEntry(
        Entry(date: state.date!, values: state.confirmed, note: state.note),
      );
      final startedAt = state.startedAt;
      emit(
        state.copyWith(
          status: CaptureStatus.saved,
          // How long logging took only means something for today. A day
          // filled in afterwards was not logged in the moment.
          elapsed: startedAt == null || !state.isToday
              ? null
              : _now().difference(startedAt),
        ),
      );
    } on EntriesFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: CaptureStatus.saveFailure));
    }
  }

  void _onEditRequested(
    CaptureEditRequested event,
    Emitter<CaptureState> emit,
  ) {
    if (state.status != CaptureStatus.saved) return;
    emit(state.copyWith(status: CaptureStatus.ready));
  }

  /// Emits [next], starting the clock on the first change.
  void _edit(Emitter<CaptureState> emit, CaptureState next) {
    emit(next.copyWith(startedAt: state.startedAt ?? _now()));
  }

  static MetricValue? _startOf(MetricDefinition metric) {
    final start = metric.start;
    return start == null ? null : NumberValue(start);
  }
}
