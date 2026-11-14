import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'setup_state.dart';

class SetupCubit extends Cubit<SetupState> {
  new() : super(const SetupState());

  /// Selects [metric], or deselects it when it is already selected.
  ///
  /// Does nothing when [metric] is not selected and the limit is reached.
  void toggle(SetupMetric metric) {
    if (state.selected.contains(metric)) {
      emit(SetupState(selected: {...state.selected}..remove(metric)));
    } else if (!state.isFull) {
      emit(SetupState(selected: {...state.selected, metric}));
    }
  }

  /// Replaces the selection with the metrics of [template].
  void applyTemplate(SetupTemplate template) {
    emit(SetupState(selected: template.metrics.toSet()));
  }
}
