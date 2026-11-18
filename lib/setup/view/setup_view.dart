import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/app/app.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/layout/layout.dart';
import 'package:terse/setup/setup.dart';
import 'package:terse/theme/theme.dart';

class SetupView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SetupBloc, SetupState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == SetupStatus.success,
      listener: (context, state) {
        unawaited(context.read<AppCubit>().completeOnboarding());
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<SetupBloc, SetupState>(
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: ContentFrame(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Header(),
                            _Templates(selected: state.matchedTemplate),
                            const SizedBox(height: TerseSpacing.xl),
                            _MetricsSection(state: state),
                            const SizedBox(height: TerseSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ContentFrame(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: TerseSpacing.sm,
                        bottom: TerseSpacing.xl,
                      ),
                      child: _StartButton(state: state),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: TerseSpacing.xxl),
        Text(l10n.setupTitle, style: theme.textTheme.displayMedium),
        const SizedBox(height: TerseSpacing.xs),
        Text(
          l10n.setupSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: TerseSpacing.xl),
      ],
    );
  }
}

class _Templates extends StatelessWidget {
  const new({required this.selected});

  /// The template that matches the chosen metrics, if any.
  final SetupTemplate? selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<SetupBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(l10n.setupTemplatesLabel),
        const SizedBox(height: TerseSpacing.xs),
        Wrap(
          spacing: TerseSpacing.xs,
          runSpacing: TerseSpacing.xs,
          children: [
            for (final template in SetupTemplate.values)
              ChoiceChip(
                label: Text(template.label(l10n)),
                selected: selected == template,
                onSelected: (_) => bloc.add(SetupTemplateSelected(template)),
              ),
          ],
        ),
      ],
    );
  }
}

class _MetricsSection extends StatelessWidget {
  const new({required this.state});

  final SetupState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final bloc = context.read<SetupBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionLabel(l10n.setupMetricsLabel),
            Text(
              l10n.setupMetricsCount(
                state.selected.length,
                SetupState.maxMetrics,
              ),
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
        ),
        const SizedBox(height: TerseSpacing.xs),
        Card(
          child: state.selected.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(TerseSpacing.md),
                  child: Text(
                    l10n.setupMetricsEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                )
              : Column(
                  children: [
                    for (final (index, metric) in state.selected.indexed) ...[
                      if (index > 0) const Divider(),
                      _MetricRow(
                        metric: metric,
                        onRemove: () => bloc.add(SetupMetricRemoved(metric)),
                      ),
                    ],
                  ],
                ),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(right: TerseSpacing.md),
          ),
          onPressed: state.isFull
              ? null
              : () => unawaited(_addMetric(context, bloc, state.available)),
          icon: const Icon(Icons.add),
          label: Text(l10n.setupAddMetric),
        ),
        if (state.status == SetupStatus.failure)
          Padding(
            padding: const EdgeInsets.only(top: TerseSpacing.xs),
            child: Text(
              l10n.setupSaveFailed,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

Future<void> _addMetric(
  BuildContext context,
  SetupBloc bloc,
  List<MetricDefinition> available,
) async {
  final metric = await showModalBottomSheet<MetricDefinition>(
    context: context,
    builder: (context) => AddMetricSheet(metrics: available),
  );
  if (metric != null) bloc.add(SetupMetricAdded(metric));
}

class _MetricRow extends StatelessWidget {
  const new({required this.metric, required this.onRemove});

  final MetricDefinition metric;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final label = metric.label(l10n);

    return Padding(
      padding: const EdgeInsets.only(
        left: TerseSpacing.md,
        top: TerseSpacing.xxs,
        bottom: TerseSpacing.xxs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleSmall),
                Text(
                  metric.description(l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: l10n.setupRemoveMetric(label),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const new({required this.state});

  final SetupState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SetupBloc>();

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: state.canStart
            ? () => bloc.add(const SetupSubmitted())
            : null,
        child: state.status == SetupStatus.saving
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(context.l10n.setupStartTracking),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

extension on SetupTemplate {
  String label(AppLocalizations l10n) {
    return switch (this) {
      SetupTemplate.sleep => l10n.setupTemplateSleep,
      SetupTemplate.mood => l10n.setupTemplateMood,
      SetupTemplate.fitness => l10n.setupTemplateFitness,
    };
  }
}
