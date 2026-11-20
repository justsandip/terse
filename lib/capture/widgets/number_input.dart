import 'package:entries_repository/entries_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/setup/setup.dart';
import 'package:terse/theme/theme.dart';

/// A number with a minus and a plus.
///
/// Pressing + or − on a faded number starts from the faded value.
class NumberInput extends StatelessWidget {
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
    final label = metric.label(l10n);
    final current = switch (value) {
      NumberValue(:final number) => number,
      _ => null,
    };
    final ghost = switch (suggestion) {
      NumberValue(:final number) => number,
      _ => null,
    };
    final shown = current ?? ghost;
    final step = metric.step ?? 1;
    final seed = ghost ?? metric.start ?? metric.min ?? 0;

    void change(double delta) {
      onChanged(NumberValue(_clamp(_round((shown ?? seed) + delta))));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.outlined(
          onPressed: () => change(-step),
          tooltip: l10n.captureDecrease(label),
          icon: const Icon(Icons.remove),
        ),
        const SizedBox(width: TerseSpacing.xs),
        CaptureToken(
          minWidth: 80,
          label: shown == null
              ? l10n.captureNotSet
              : metric.formatNumber(l10n, shown),
          state: current != null
              ? TokenState.confirmed
              : ghost != null
              ? TokenState.ghost
              : TokenState.idle,
          onTap: () => current != null
              ? onCleared()
              : onChanged(NumberValue(_clamp(seed))),
        ),
        const SizedBox(width: TerseSpacing.xs),
        IconButton.outlined(
          onPressed: () => change(step),
          tooltip: l10n.captureIncrease(label),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  double _clamp(double number) {
    return number.clamp(
      metric.min ?? double.negativeInfinity,
      metric.max ?? double.infinity,
    );
  }

  /// Rounds away the error of adding steps like 0.1.
  static double _round(double number) {
    return (number * 1e6).round() / 1e6;
  }
}
