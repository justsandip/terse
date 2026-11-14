part of 'setup_cubit.dart';

/// The metrics a user can choose to track.
enum SetupMetric {
  sleepHours,
  sleepQuality,
  mood,
  energy,
  stress,
  caffeine,
  exercise,
}

/// A ready-made group of metrics.
enum SetupTemplate {
  sleep([
    SetupMetric.sleepHours,
    SetupMetric.sleepQuality,
    SetupMetric.caffeine,
  ]),
  mood([SetupMetric.mood, SetupMetric.energy, SetupMetric.stress]),
  fitness([SetupMetric.exercise, SetupMetric.energy, SetupMetric.sleepHours]);

  new(this.metrics);

  final List<SetupMetric> metrics;
}

final class SetupState extends Equatable {
  const new({this.selected = const <SetupMetric>{}});

  /// The most metrics a user can track.
  static const maxMetrics = 6;

  final Set<SetupMetric> selected;

  bool get isFull => selected.length >= maxMetrics;

  bool get canStart => selected.isNotEmpty;

  @override
  List<Object> get props => [selected];
}
