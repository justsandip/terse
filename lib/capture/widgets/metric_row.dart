import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/setup/setup.dart';
import 'package:terse/theme/theme.dart';

/// One metric on the capture screen: its name, a caption for a faded value,
/// and the input that fits its kind.
class MetricRow extends StatelessWidget {
  const new({
    required this.metric,
    required this.value,
    required this.suggestion,
    required this.fromYesterday,
    super.key,
  });

  final MetricDefinition metric;

  /// What the user set, if anything.
  final MetricValue? value;

  /// The faded suggestion, if there is one.
  final MetricValue? suggestion;

  /// Whether [suggestion] is yesterday's value, not a start value.
  final bool fromYesterday;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bloc = context.read<CaptureBloc>();
    void onChanged(MetricValue next) =>
        bloc.add(CaptureValueSet(metric.key, next));
    void onCleared() => bloc.add(CaptureValueCleared(metric.key));

    final faded = value == null ? suggestion : null;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(metric.label(l10n), style: theme.textTheme.titleSmall),
        if (faded != null)
          Text(
            fromYesterday
                ? l10n.captureYesterday(metric.describeValue(l10n, faded))
                : l10n.captureSuggested(metric.describeValue(l10n, faded)),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );

    final input = switch (metric.kind) {
      MetricKind.number => NumberInput(
        metric: metric,
        value: value,
        suggestion: suggestion,
        onChanged: onChanged,
        onCleared: onCleared,
      ),
      MetricKind.scale => ScaleInput(
        metric: metric,
        value: value,
        suggestion: suggestion,
        onChanged: onChanged,
        onCleared: onCleared,
      ),
      MetricKind.choice => ChoiceInput(
        metric: metric,
        value: value,
        suggestion: suggestion,
        onChanged: onChanged,
        onCleared: onCleared,
      ),
      MetricKind.boolean => BooleanInput(
        value: value,
        suggestion: suggestion,
        onChanged: onChanged,
        onCleared: onCleared,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TerseSpacing.md,
        vertical: TerseSpacing.xs,
      ),
      child: metric.kind == MetricKind.number
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Flexible(child: title), input],
            )
          : Column(
              // Stretch, so the input gets the full width and a Wrap can
              // spread its dots across it.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                title,
                const SizedBox(height: TerseSpacing.xs),
                input,
              ],
            ),
    );
  }
}
