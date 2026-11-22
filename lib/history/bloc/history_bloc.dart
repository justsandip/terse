import 'package:bloc/bloc.dart';
import 'package:entries_repository/entries_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:metrics_repository/metrics_repository.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  new({
    required this._metricsRepository,
    required this._entriesRepository,
    this._now = DateTime.now,
  }) : super(const HistoryState()) {
    on<HistoryStarted>(_onStarted);
    on<HistoryMonthShifted>(_onMonthShifted);
    on<HistoryRefreshed>(_onRefreshed);
  }

  final MetricsRepository _metricsRepository;
  final EntriesRepository _entriesRepository;
  final DateTime Function() _now;

  DateTime get _today {
    final now = _now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _onStarted(HistoryStarted event, Emitter<HistoryState> emit) {
    final today = _today;
    return _load(emit, month: DateTime(today.year, today.month));
  }

  Future<void> _onMonthShifted(
    HistoryMonthShifted event,
    Emitter<HistoryState> emit,
  ) async {
    final shown = state.month;
    if (shown == null) return;

    final target = DateTime(shown.year, shown.month + event.months);
    final today = _today;
    if (target.isAfter(DateTime(today.year, today.month))) return;

    await _load(emit, month: target);
  }

  Future<void> _onRefreshed(
    HistoryRefreshed event,
    Emitter<HistoryState> emit,
  ) async {
    final shown = state.month;
    if (shown == null) return;

    await _load(emit, month: shown, showLoading: false);
  }

  /// Reads [month] and emits it.
  ///
  /// The user can move on while a month is still loading. A result for a month
  /// that is no longer shown is dropped, so a slow read cannot overwrite a
  /// newer one.
  Future<void> _load(
    Emitter<HistoryState> emit, {
    required DateTime month,
    bool showLoading = true,
  }) async {
    final today = _today;
    if (showLoading) {
      emit(HistoryState(today: today, month: month));
    }

    try {
      final metrics = await _metricsRepository.fetchMetrics();
      final entries = await _entriesRepository.fetchEntries(
        from: month,
        to: DateTime(month.year, month.month + 1, 0),
      );
      if (state.month != month) return;

      emit(
        HistoryState(
          status: HistoryStatus.loaded,
          today: today,
          month: month,
          metrics: metrics,
          entries: entries,
        ),
      );
    } on MetricsFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      if (state.month != month) return;
      emit(
        HistoryState(status: HistoryStatus.failure, today: today, month: month),
      );
    } on EntriesFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      if (state.month != month) return;
      emit(
        HistoryState(status: HistoryStatus.failure, today: today, month: month),
      );
    }
  }
}
