import 'package:entries_repository/entries_repository.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/l10n/l10n.dart';

/// Localized texts for the values of a [MetricDefinition].
extension MetricValueL10n on MetricDefinition {
  /// A number with its unit, e.g. `6.5 h` or `2 cups`.
  String formatNumber(AppLocalizations l10n, double number) {
    final count = number == number.roundToDouble() ? number.toInt() : number;
    return switch (unit) {
      'hours' => l10n.captureValueHours(count),
      'cups' => l10n.captureValueCups(count),
      'minutes' => l10n.captureValueMinutes(count),
      null => '$count',
      final other => '$count $other',
    };
  }

  /// The name of a choice option. An option that is not built in shows itself.
  String optionLabel(AppLocalizations l10n, String option) {
    return switch (option) {
      'none' => l10n.choiceNone,
      'walk' => l10n.choiceWalk,
      'gym' => l10n.choiceGym,
      'run' => l10n.choiceRun,
      'yoga' => l10n.choiceYoga,
      'other' => l10n.choiceOther,
      _ => option,
    };
  }

  /// A value as text, e.g. `4`, `7 h`, `Walk` or `Yes`.
  String describeValue(AppLocalizations l10n, MetricValue metricValue) {
    return switch (metricValue) {
      NumberValue(:final number) when kind == MetricKind.scale =>
        '${number.round()}',
      NumberValue(:final number) => formatNumber(l10n, number),
      BooleanValue(:final value) => value ? l10n.captureYes : l10n.captureNo,
      ChoiceValue(:final option) => optionLabel(l10n, option),
    };
  }
}
