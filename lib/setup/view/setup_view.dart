import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/app/app.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/layout/layout.dart';
import 'package:terse/setup/setup.dart';
import 'package:terse/theme/theme.dart';

class SetupView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final muted = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SetupCubit, SetupState>(
          builder: (context, state) {
            final cubit = context.read<SetupCubit>();

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: ContentFrame(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: TerseSpacing.xxl),
                          Text(l10n.setupTitle, style: textTheme.displayMedium),
                          const SizedBox(height: TerseSpacing.xs),
                          Text(
                            l10n.setupSubtitle(SetupState.maxMetrics),
                            style: textTheme.bodyMedium?.copyWith(color: muted),
                          ),
                          const SizedBox(height: TerseSpacing.xl),
                          _SectionLabel(l10n.setupTemplatesLabel),
                          const SizedBox(height: TerseSpacing.xs),
                          Wrap(
                            spacing: TerseSpacing.xs,
                            runSpacing: TerseSpacing.xs,
                            children: [
                              for (final template in SetupTemplate.values)
                                ActionChip(
                                  label: Text(template.label(l10n)),
                                  onPressed: () =>
                                      cubit.applyTemplate(template),
                                ),
                            ],
                          ),
                          const SizedBox(height: TerseSpacing.xl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _SectionLabel(l10n.setupMetricsLabel),
                              Text(
                                l10n.setupMetricsCount(
                                  state.selected.length,
                                  SetupState.maxMetrics,
                                ),
                                style: textTheme.bodySmall?.copyWith(
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: TerseSpacing.xs),
                          Wrap(
                            spacing: TerseSpacing.xs,
                            runSpacing: TerseSpacing.xs,
                            children: [
                              for (final metric in SetupMetric.values)
                                FilterChip(
                                  label: Text(metric.label(l10n)),
                                  selected: state.selected.contains(metric),
                                  onSelected:
                                      state.isFull &&
                                          !state.selected.contains(metric)
                                      ? null
                                      : (_) => cubit.toggle(metric),
                                ),
                            ],
                          ),
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
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: state.canStart
                            ? () =>
                                  context.read<AppCubit>().completeOnboarding()
                            : null,
                        child: Text(l10n.setupStartTracking),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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

extension on SetupMetric {
  String label(AppLocalizations l10n) {
    return switch (this) {
      SetupMetric.sleepHours => l10n.metricSleepHours,
      SetupMetric.sleepQuality => l10n.metricSleepQuality,
      SetupMetric.mood => l10n.metricMood,
      SetupMetric.energy => l10n.metricEnergy,
      SetupMetric.stress => l10n.metricStress,
      SetupMetric.caffeine => l10n.metricCaffeine,
      SetupMetric.exercise => l10n.metricExercise,
    };
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
