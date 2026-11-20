import 'package:entries_repository/entries_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/theme/theme.dart';

/// A Yes and a No.
class BooleanInput extends StatelessWidget {
  const new({
    required this.value,
    required this.suggestion,
    required this.onChanged,
    required this.onCleared,
    super.key,
  });

  final MetricValue? value;
  final MetricValue? suggestion;
  final ValueChanged<MetricValue> onChanged;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = switch (value) {
      BooleanValue(:final value) => value,
      _ => null,
    };
    final ghost = switch (suggestion) {
      BooleanValue(:final value) => value,
      _ => null,
    };

    return Wrap(
      spacing: TerseSpacing.xs,
      children: [
        for (final (answer, label) in [
          (true, l10n.captureYes),
          (false, l10n.captureNo),
        ])
          CaptureToken(
            label: label,
            state: current == answer
                ? TokenState.selected
                : current == null && ghost == answer
                ? TokenState.ghost
                : TokenState.idle,
            onTap: () => current == answer
                ? onCleared()
                : onChanged(BooleanValue(answer)),
          ),
      ],
    );
  }
}
