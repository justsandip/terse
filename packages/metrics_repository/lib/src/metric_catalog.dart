import 'package:metrics_repository/metrics_repository.dart';

/// {@template metric_catalog}
/// The built-in metrics a user can choose from.
///
/// Keys match the fields the extraction schema uses.
/// {@endtemplate}
abstract class MetricCatalog {
  /// Hours slept last night.
  static const sleepHours = MetricDefinition(
    key: 'sleep_hours',
    kind: MetricKind.number,
    unit: 'hours',
    min: 0,
    max: 16,
    step: 0.5,
    start: 7,
  );

  /// How well the user slept, from 1 to 5.
  static const sleepQuality = MetricDefinition(
    key: 'sleep_quality',
    kind: MetricKind.scale,
    min: 1,
    max: 5,
  );

  /// Mood, from 1 to 5.
  static const mood = MetricDefinition(
    key: 'mood',
    kind: MetricKind.scale,
    min: 1,
    max: 5,
  );

  /// Energy, from 1 to 5.
  static const energy = MetricDefinition(
    key: 'energy',
    kind: MetricKind.scale,
    min: 1,
    max: 5,
  );

  /// Stress, from 1 to 5.
  static const stress = MetricDefinition(
    key: 'stress',
    kind: MetricKind.scale,
    min: 1,
    max: 5,
  );

  /// Cups of caffeinated drinks.
  static const caffeine = MetricDefinition(
    key: 'caffeine_cups',
    kind: MetricKind.number,
    unit: 'cups',
    min: 0,
    max: 15,
    step: 1,
    start: 1,
  );

  /// The type of exercise.
  static const exerciseType = MetricDefinition(
    key: 'exercise_type',
    kind: MetricKind.choice,
    choices: ['none', 'walk', 'gym', 'run', 'yoga', 'other'],
  );

  /// Minutes of exercise.
  static const exerciseMinutes = MetricDefinition(
    key: 'exercise_minutes',
    kind: MetricKind.number,
    unit: 'minutes',
    min: 0,
    max: 600,
    step: 5,
    start: 30,
  );

  /// Every built-in metric.
  static const all = <MetricDefinition>[
    sleepHours,
    sleepQuality,
    mood,
    energy,
    stress,
    caffeine,
    exerciseType,
    exerciseMinutes,
  ];

  /// Returns the built-in metric with [key], or `null` if there is none.
  static MetricDefinition? byKey(String key) {
    for (final metric in all) {
      if (metric.key == key) return metric;
    }
    return null;
  }
}
