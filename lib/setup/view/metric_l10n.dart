import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/l10n/l10n.dart';

/// Localized texts for a [MetricDefinition].
extension MetricDefinitionL10n on MetricDefinition {
  /// The name of the metric. A metric that is not built in shows its key.
  String label(AppLocalizations l10n) {
    return switch (key) {
      'sleep_hours' => l10n.metricSleepHours,
      'sleep_quality' => l10n.metricSleepQuality,
      'mood' => l10n.metricMood,
      'energy' => l10n.metricEnergy,
      'stress' => l10n.metricStress,
      'caffeine_cups' => l10n.metricCaffeine,
      'exercise_type' => l10n.metricExerciseType,
      'exercise_minutes' => l10n.metricExerciseMinutes,
      _ => key,
    };
  }

  /// A short description of the kind of value, such as its unit.
  String description(AppLocalizations l10n) {
    return switch (kind) {
      MetricKind.number => switch (unit) {
        'hours' => l10n.unitHours,
        'cups' => l10n.unitCups,
        'minutes' => l10n.unitMinutes,
        _ => unit ?? '',
      },
      MetricKind.scale => l10n.metricDescriptionScale(
        min?.toInt() ?? 1,
        max?.toInt() ?? 5,
      ),
      MetricKind.choice => l10n.metricDescriptionChoice,
      MetricKind.boolean => l10n.metricDescriptionBoolean,
    };
  }
}
