import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:metrics_repository/metrics_repository.dart';

part 'setup_event.dart';
part 'setup_state.dart';

class SetupBloc extends Bloc<SetupEvent, SetupState> {
  new({required this._metricsRepository}) : super(const SetupState()) {
    on<SetupMetricAdded>(_onMetricAdded);
    on<SetupMetricRemoved>(_onMetricRemoved);
    on<SetupTemplateSelected>(_onTemplateSelected);
    on<SetupSubmitted>(_onSubmitted);
  }

  final MetricsRepository _metricsRepository;

  void _onMetricAdded(SetupMetricAdded event, Emitter<SetupState> emit) {
    if (state.isFull || state.selected.contains(event.metric)) return;
    emit(SetupState(selected: [...state.selected, event.metric]));
  }

  void _onMetricRemoved(SetupMetricRemoved event, Emitter<SetupState> emit) {
    emit(SetupState(selected: [...state.selected]..remove(event.metric)));
  }

  void _onTemplateSelected(
    SetupTemplateSelected event,
    Emitter<SetupState> emit,
  ) {
    emit(SetupState(selected: event.template.metrics));
  }

  Future<void> _onSubmitted(
    SetupSubmitted event,
    Emitter<SetupState> emit,
  ) async {
    if (!state.canStart) return;

    emit(SetupState(selected: state.selected, status: SetupStatus.saving));
    try {
      await _metricsRepository.saveMetrics(state.selected);
      emit(SetupState(selected: state.selected, status: SetupStatus.success));
    } on MetricsFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(SetupState(selected: state.selected, status: SetupStatus.failure));
    }
  }
}
