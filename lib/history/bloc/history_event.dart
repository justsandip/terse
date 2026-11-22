part of 'history_bloc.dart';

sealed class HistoryEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

/// The screen opened: show the current month.
final class HistoryStarted extends HistoryEvent {
  const new();
}

/// The user moved to another month. A negative number goes back.
final class HistoryMonthShifted extends HistoryEvent {
  const new(this.months);
  final int months;

  @override
  List<Object?> get props => [months];
}

/// Read the shown month again, e.g. after a day was saved or deleted.
final class HistoryRefreshed extends HistoryEvent {
  const new();
}
