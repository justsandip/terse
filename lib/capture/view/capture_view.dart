import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/layout/layout.dart';
import 'package:terse/theme/theme.dart';

class CaptureView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Only a day opened from its entry can go back. Today is a tab.
      appBar: Navigator.of(context).canPop() ? AppBar() : null,
      body: SafeArea(
        child: BlocBuilder<CaptureBloc, CaptureState>(
          builder: (context, state) {
            return switch (state.status) {
              CaptureStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              CaptureStatus.loadFailure => const _LoadFailed(),
              CaptureStatus.saved => _Saved(state: state),
              CaptureStatus.ready ||
              CaptureStatus.saving ||
              CaptureStatus.saveFailure => _Form(state: state),
            };
          },
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const new({required this.state});

  final CaptureState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bloc = context.read<CaptureBloc>();
    final locale = Localizations.localeOf(context).toString();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: ContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: TerseSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat.MMMEd(locale).format(state.date!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      IconButton(
                        onPressed: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => const CaptureHelpSheet(),
                        ),
                        tooltip: l10n.captureHelpTooltip,
                        icon: const Icon(Icons.help_outline),
                      ),
                    ],
                  ),
                  Text(
                    state.isToday ? l10n.captureTitle : l10n.captureTitleOther,
                    style: theme.textTheme.displayMedium,
                  ),
                  const SizedBox(height: TerseSpacing.md),
                  if (state.isEditable && state.habitsToConfirm.isNotEmpty)
                    _HabitsButton(state: state),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: TerseSpacing.sm),
                        for (final (index, metric)
                            in state.metrics.indexed) ...[
                          if (index > 0) const Divider(),
                          MetricRow(
                            metric: metric,
                            value: state.confirmed[metric.key],
                            suggestion: state.suggestions[metric.key],
                            fromYesterday: state.suggestedFromYesterday
                                .contains(metric.key),
                            isToday: state.isToday,
                          ),
                        ],
                        const SizedBox(height: TerseSpacing.sm),
                      ],
                    ),
                  ),
                  const SizedBox(height: TerseSpacing.sm),
                  TextFormField(
                    initialValue: state.note,
                    onChanged: (note) => bloc.add(CaptureNoteChanged(note)),
                    decoration: InputDecoration(
                      hintText: l10n.captureNoteHint,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                  if (state.status == CaptureStatus.saveFailure)
                    Padding(
                      padding: const EdgeInsets.only(top: TerseSpacing.xs),
                      child: Text(
                        l10n.captureSaveFailed,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
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
                onPressed: state.canSave
                    ? () => bloc.add(const CaptureSubmitted())
                    : null,
                child: state.status == CaptureStatus.saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        state.isToday
                            ? l10n.captureSave(
                                state.confirmed.length,
                                state.metrics.length,
                              )
                            : l10n.captureSaveDay(
                                state.confirmed.length,
                                state.metrics.length,
                              ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HabitsButton extends StatelessWidget {
  const new({required this.state});

  final CaptureState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final habits = state.habitsToConfirm;
    final fromYesterday = habits.every(state.suggestedFromYesterday.contains);

    return Padding(
      padding: const EdgeInsets.only(bottom: TerseSpacing.sm),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () =>
              context.read<CaptureBloc>().add(const CaptureHabitsConfirmed()),
          child: Text(
            fromYesterday
                ? state.isToday
                      ? l10n.captureSameAsYesterday(habits.length)
                      : l10n.captureSameAsDayBefore(habits.length)
                : l10n.captureUseSuggestions(habits.length),
          ),
        ),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.captureLoadFailed),
          const SizedBox(height: TerseSpacing.sm),
          TextButton(
            onPressed: () =>
                context.read<CaptureBloc>().add(const CaptureStarted()),
            child: Text(l10n.captureRetry),
          ),
        ],
      ),
    );
  }
}

class _Saved extends StatelessWidget {
  const new({required this.state});

  final CaptureState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final elapsed = state.elapsed;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(TerseSpacing.lg),
              child: Icon(
                Icons.check,
                size: 44,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: TerseSpacing.xl),
          Text(l10n.captureSavedTitle, style: theme.textTheme.displayMedium),
          if (elapsed != null) ...[
            const SizedBox(height: TerseSpacing.xxs),
            Text(
              l10n.captureLoggedIn(elapsed.inSeconds),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: TerseSpacing.xl),
          TextButton(
            onPressed: () =>
                context.read<CaptureBloc>().add(const CaptureEditRequested()),
            child: Text(
              state.isToday ? l10n.captureEditToday : l10n.captureEditDay,
            ),
          ),
        ],
      ),
    );
  }
}
