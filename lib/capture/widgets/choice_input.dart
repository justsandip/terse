import 'package:entries_repository/entries_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/theme/theme.dart';

/// A pill for each option of a choice.
class ChoiceInput extends StatelessWidget {
  const new({
    required this.metric,
    required this.value,
    required this.suggestion,
    required this.onChanged,
    required this.onCleared,
    super.key,
  });

  final MetricDefinition metric;
  final MetricValue? value;
  final MetricValue? suggestion;
  final ValueChanged<MetricValue> onChanged;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = switch (value) {
      ChoiceValue(:final option) => option,
      _ => null,
    };
    final ghost = switch (suggestion) {
      ChoiceValue(:final option) => option,
      _ => null,
    };

    return Wrap(
      spacing: TerseSpacing.xs,
      runSpacing: TerseSpacing.xs,
      children: [
        for (final option in metric.choices)
          CaptureToken(
            label: metric.optionLabel(l10n, option),
            state: current == option
                ? TokenState.selected
                : current == null && ghost == option
                ? TokenState.ghost
                : TokenState.idle,
            onTap: () => current == option
                ? onCleared()
                : onChanged(ChoiceValue(option)),
          ),
      ],
    );
  }
}
