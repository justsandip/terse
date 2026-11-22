import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/history/history.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/layout/layout.dart';
import 'package:terse/setup/setup.dart';
import 'package:terse/theme/theme.dart';

class HistoryView extends StatelessWidget {
  const new({this.onDayTap, super.key});

  /// Called with the day of an entry the user taps. The entry screen is not
  /// built yet, so the page leaves it empty and entries cannot be opened.
  final ValueChanged<DateTime>? onDayTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            return switch (state.status) {
              HistoryStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              HistoryStatus.failure => const _LoadFailed(),
              HistoryStatus.loaded => _Loaded(state: state, onDayTap: onDayTap),
            };
          },
        ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const new({required this.state, required this.onDayTap});

  final HistoryState state;
  final ValueChanged<DateTime>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bloc = context.read<HistoryBloc>();
    final muted = theme.colorScheme.onSurfaceVariant;
    final locale = Localizations.localeOf(context).toString();

    return SingleChildScrollView(
      child: ContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TerseSpacing.xl),
            Text(l10n.historyTitle, style: theme.textTheme.displayLarge),
            const SizedBox(height: TerseSpacing.xxs),
            Text(
              l10n.historyLoggedDays(state.loggedDays, state.daysSoFar),
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: TerseSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMM(locale).format(state.month!),
                  style: theme.textTheme.titleSmall,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => bloc.add(const HistoryMonthShifted(-1)),
                      tooltip: l10n.historyPreviousMonth,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      onPressed: state.canShowNext
                          ? () => bloc.add(const HistoryMonthShifted(1))
                          : null,
                      tooltip: l10n.historyNextMonth,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
            MonthGrid(state: state, onDayTap: onDayTap),
            const SizedBox(height: TerseSpacing.xs),
            Row(
              children: [
                _Legend(
                  color: theme.colorScheme.primary,
                  label: l10n.historyLegendAll,
                ),
                const SizedBox(width: TerseSpacing.md),
                _Legend(
                  color: theme.colorScheme.primaryContainer,
                  label: l10n.historyLegendSome,
                ),
              ],
            ),
            const SizedBox(height: TerseSpacing.xl),
            Text(
              l10n.historyEntriesLabel.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(color: muted),
            ),
            const SizedBox(height: TerseSpacing.xs),
            Card(
              child: state.entries.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(TerseSpacing.md),
                      child: Text(
                        l10n.historyEmpty,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: muted,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (index, entry) in state.recent.indexed) ...[
                          if (index > 0) const Divider(),
                          _EntryRow(
                            title: DateFormat.MMMEd(locale).format(entry.date),
                            summary: _summary(state, entry, l10n),
                            onTap: onDayTap == null
                                ? null
                                : () => onDayTap!(entry.date),
                          ),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: TerseSpacing.xl),
          ],
        ),
      ),
    );
  }
}

/// What an entry holds, e.g. `Sleep hours 7 h · Mood 4`. An entry with only a
/// note shows the note.
String _summary(HistoryState state, Entry entry, AppLocalizations l10n) {
  final parts = [
    for (final metric in state.metrics)
      if (entry.values[metric.key] case final value?)
        '${metric.label(l10n)} ${metric.describeValue(l10n, value)}',
  ];
  return parts.isEmpty ? entry.note ?? '' : parts.join(' · ');
}

class _EntryRow extends StatelessWidget {
  const new({required this.title, required this.summary, required this.onTap});

  final String title;
  final String summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TerseSpacing.md,
          vertical: TerseSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: TerseSpacing.xxs),
            Text(
              summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const new({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const SizedBox.square(dimension: 10),
        ),
        const SizedBox(width: TerseSpacing.xxs + 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
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
          Text(l10n.historyLoadFailed),
          const SizedBox(height: TerseSpacing.sm),
          TextButton(
            onPressed: () =>
                context.read<HistoryBloc>().add(const HistoryRefreshed()),
            child: Text(l10n.captureRetry),
          ),
        ],
      ),
    );
  }
}
