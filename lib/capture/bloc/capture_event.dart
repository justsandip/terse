part of 'capture_bloc.dart';

sealed class CaptureEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

/// The screen opened: load the metrics, today's entry and yesterday's values.
final class CaptureStarted extends CaptureEvent {
  const new();
}

/// The user set a value, or confirmed a suggested one.
final class CaptureValueSet extends CaptureEvent {
  const new(this.key, this.value);

  final String key;
  final MetricValue value;

  @override
  List<Object?> get props => [key, value];
}

/// The user took back a value, so the metric is not tracked today again.
final class CaptureValueCleared extends CaptureEvent {
  const new(this.key);
  final String key;

  @override
  List<Object?> get props => [key];
}

/// The user pressed "Same as yesterday".
final class CaptureHabitsConfirmed extends CaptureEvent {
  const new();
}

/// The user changed the note.
final class CaptureNoteChanged extends CaptureEvent {
  const new(this.note);
  final String note;

  @override
  List<Object?> get props => [note];
}

/// The user asked to save the day.
final class CaptureSubmitted extends CaptureEvent {
  const new();
}

/// The user asked to reopen a saved day.
final class CaptureEditRequested extends CaptureEvent {
  const new();
}
