import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/setup/setup.dart';
import 'package:terse/theme/theme.dart';

/// A bottom sheet that lists [metrics] and returns the one that is tapped.
class AddMetricSheet extends StatelessWidget {
  const new({required this.metrics, super.key});

  final List<MetricDefinition> metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TerseSpacing.lg),
            child: Text(
              l10n.setupAddMetricSheetTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: TerseSpacing.xs),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final metric in metrics)
                  ListTile(
                    title: Text(metric.label(l10n)),
                    subtitle: Text(metric.description(l10n)),
                    onTap: () => Navigator.of(context).pop(metric),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
