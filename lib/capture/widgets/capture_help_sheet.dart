import 'package:material_ui/material_ui.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/theme/theme.dart';

/// A bottom sheet that explains faded and solid values.
class CaptureHelpSheet extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          TerseSpacing.lg,
          0,
          TerseSpacing.lg,
          TerseSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.captureHelpTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: TerseSpacing.md),
            _Item(l10n.captureHelpFadedTitle, l10n.captureHelpFadedBody),
            _Item(l10n.captureHelpSolidTitle, l10n.captureHelpSolidBody),
            _Item(l10n.captureHelpHabitsTitle, l10n.captureHelpHabitsBody),
            _Item(l10n.captureHelpSkipTitle, l10n.captureHelpSkipBody),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const new(this.title, this.body);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: TerseSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: TerseSpacing.xxs),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
