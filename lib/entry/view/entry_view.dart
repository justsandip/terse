import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/entry/entry.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/layout/layout.dart';
import 'package:terse/setup/setup.dart';
import 'package:terse/theme/theme.dart';

class EntryView extends StatelessWidget {
  const new({required this.onEdit, super.key});

  /// Opens the day for editing. The entry is read again when it completes.
  final Future<void> Function() onEdit;

  @override
  Widget build(BuildContext context) {
    return BlocListener<EntryBloc, EntryState>(
      listenWhen: (previous, current) => current.status == EntryStatus.deleted,
      listener: (context, state) => Navigator.of(context).maybePop(),
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: BlocBuilder<EntryBloc, EntryState>(
            builder: (context, state) {
              return switch (state.status) {
                EntryStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                EntryStatus.failure => const _LoadFailed(),
                EntryStatus.notFound => const _Gone(),
                EntryStatus.loaded ||
                EntryStatus.deleting ||
                EntryStatus.deleteFailure ||
                EntryStatus.deleted => _Loaded(state: state, onEdit: onEdit),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const new({required this.state, required this.onEdit});

  final EntryState state;
  final Future<void> Function() onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final entry = state.entry!;
    final note = entry.note?.trim() ?? '';
    final busy =
        state.status == EntryStatus.deleting ||
        state.status == EntryStatus.deleted;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: ContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.MMMEd(locale).format(state.date),
                    style: theme.textTheme.displayMedium,
                  ),
                  const SizedBox(height: TerseSpacing.xxs),
                  Text(
                    l10n.entryTrackedCount(
                      state.trackedCount,
                      state.metrics.length,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: TerseSpacing.md),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (index, metric)
                            in state.metrics.indexed) ...[
                          if (index > 0) const Divider(),
                          _ValueRow(
                            label: metric.label(l10n),
                            value: entry.values[metric.key] == null
                                ? null
                                : metric.describeValue(
                                    l10n,
                                    entry.values[metric.key]!,
                                  ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: TerseSpacing.md),
                    Text(
                      l10n.entryNoteLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: TerseSpacing.xs),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(TerseSpacing.md),
                        child: Text(note, style: theme.textTheme.bodyLarge),
                      ),
                    ),
                  ],
                  if (state.status == EntryStatus.deleteFailure)
                    Padding(
                      padding: const EdgeInsets.only(top: TerseSpacing.sm),
                      child: Text(
                        l10n.entryDeleteFailed,
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
              bottom: TerseSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: busy ? null : () => unawaited(_edit(context)),
                  child: Text(l10n.entryEdit),
                ),
                TextButton(
                  onPressed: busy ? null : () => unawaited(_delete(context)),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: Text(l10n.entryDelete),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _edit(BuildContext context) async {
    final bloc = context.read<EntryBloc>();
    await onEdit();
    bloc.add(const EntryRefreshed());
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = context.l10n;
    final bloc = context.read<EntryBloc>();
    final locale = Localizations.localeOf(context).toString();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.entryDeleteTitle),
        content: Text(
          l10n.entryDeleteBody(DateFormat.MMMEd(locale).format(state.date)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.entryDeleteKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.entryDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) bloc.add(const EntryDeleted());
  }
}

class _ValueRow extends StatelessWidget {
  const new({required this.label, required this.value});

  final String label;

  /// The value as text, or `null` when the metric is not tracked that day.
  final String? value;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TerseSpacing.md,
        vertical: TerseSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Both sides may wrap, so a long label, a long value or a large
          // system font cannot overflow the row.
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(color: muted),
            ),
          ),
          const SizedBox(width: TerseSpacing.sm),
          Flexible(
            child: Text(
              value ?? l10n.entryNotTracked,
              textAlign: TextAlign.end,
              style: value == null
                  ? theme.textTheme.bodyLarge?.copyWith(color: muted)
                  : theme.textTheme.titleSmall,
            ),
          ),
        ],
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
          Text(l10n.entryLoadFailed),
          const SizedBox(height: TerseSpacing.sm),
          TextButton(
            onPressed: () =>
                context.read<EntryBloc>().add(const EntryStarted()),
            child: Text(l10n.entryRetry),
          ),
        ],
      ),
    );
  }
}

class _Gone extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(context.l10n.entryGone));
  }
}
