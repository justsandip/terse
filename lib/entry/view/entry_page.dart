import 'package:entries_repository/entries_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/entry/entry.dart';

/// What the user logged on one day, with the way to change or delete it.
class EntryPage extends StatelessWidget {
  const new({required this.date, required this.onEdit, super.key});

  /// The day to show.
  final DateTime date;

  /// Opens the day for editing. The entry is read again when it completes.
  final Future<void> Function() onEdit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EntryBloc(
        metricsRepository: context.read<MetricsRepository>(),
        entriesRepository: context.read<EntriesRepository>(),
        date: date,
      )..add(const EntryStarted()),
      child: EntryView(onEdit: onEdit),
    );
  }
}
