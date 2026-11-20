import 'package:entries_repository/entries_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/theme/theme.dart';

/// A row of dots, one for each step of a scale.
class ScaleInput extends StatelessWidget {
  const new({
    required this.metric,
    required this.value,
    required this.suggestion,
    required this.onChanged,
    required this.onCleared,
    super.key,
  });

  final MetricDefinition metric;

  /// What the user set, if anything.
  final MetricValue? value;

  /// The faded suggestion, if there is one.
  final MetricValue? suggestion;

  final ValueChanged<MetricValue> onChanged;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final current = switch (value) {
      NumberValue(:final number) => number,
      _ => null,
    };
    final ghost = switch (suggestion) {
      NumberValue(:final number) => number,
      _ => null,
    };
    final first = metric.min?.toInt() ?? 1;
    final last = metric.max?.toInt() ?? 5;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: TerseSpacing.xs,
      children: [
        for (var step = first; step <= last; step++)
          CaptureToken(
            circle: true,
            label: '$step',
            state: current == step
                ? TokenState.selected
                : current == null && ghost == step
                ? TokenState.ghost
                : TokenState.idle,
            onTap: () => current == step
                ? onCleared()
                : onChanged(NumberValue(step.toDouble())),
          ),
      ],
    );
  }
}
