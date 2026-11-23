import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/history/history.dart';

class HistoryPage extends StatelessWidget {
  const new({this.onDayTap, super.key});

  /// Opens a day. It completes when the user comes back, and the month is
  /// read again then, because the day may have been edited or deleted.
  final Future<void> Function(DateTime day)? onDayTap;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryBloc(
        metricsRepository: context.read<MetricsRepository>(),
        entriesRepository: context.read<EntriesRepository>(),
      )..add(const HistoryStarted()),
      child: Builder(
        builder: (context) {
          final open = onDayTap;
          return HistoryView(
            onDayTap: open == null
                ? null
                : (day) async {
                    final bloc = context.read<HistoryBloc>();
                    await open(day);
                    bloc.add(const HistoryRefreshed());
                  },
          );
        },
      ),
    );
  }
}
