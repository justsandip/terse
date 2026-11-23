import 'package:bloc/bloc.dart';
import 'package:entries_repository/entries_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:metrics_repository/metrics_repository.dart';

part 'entry_event.dart';
part 'entry_state.dart';

class EntryBloc extends Bloc<EntryEvent, EntryState> {
  new({
    required this._metricsRepository,
    required this._entriesRepository,
    required DateTime date,
  }) : super(EntryState(date: DateTime(date.year, date.month, date.day))) {
    on<EntryStarted>(_onStarted);
    on<EntryRefreshed>(_onRefreshed);
    on<EntryDeleted>(_onDeleted);
  }

  final MetricsRepository _metricsRepository;
  final EntriesRepository _entriesRepository;

  Future<void> _onStarted(EntryStarted event, Emitter<EntryState> emit) async {
    emit(EntryState(date: state.date));
    await _load(emit);
  }

  Future<void> _onRefreshed(EntryRefreshed event, Emitter<EntryState> emit) {
    return _load(emit);
  }

  Future<void> _load(Emitter<EntryState> emit) async {
    final date = state.date;
    try {
      final metrics = await _metricsRepository.fetchMetrics();
      final entry = await _entriesRepository.fetchEntry(date);
      emit(
        EntryState(
          date: date,
          status: entry == null ? EntryStatus.notFound : EntryStatus.loaded,
          metrics: metrics,
          entry: entry,
        ),
      );
    } on MetricsFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(EntryState(date: date, status: EntryStatus.failure));
    } on EntriesFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(EntryState(date: date, status: EntryStatus.failure));
    }
  }

  Future<void> _onDeleted(EntryDeleted event, Emitter<EntryState> emit) async {
    if (state.status != EntryStatus.loaded &&
        state.status != EntryStatus.deleteFailure) {
      return;
    }

    emit(state.copyWith(status: EntryStatus.deleting));
    try {
      await _entriesRepository.deleteEntry(state.date);
      emit(state.copyWith(status: EntryStatus.deleted));
    } on EntriesFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: EntryStatus.deleteFailure));
    }
  }
}
