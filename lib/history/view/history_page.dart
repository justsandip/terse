import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/history/history.dart';

class HistoryPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryBloc(
        metricsRepository: context.read<MetricsRepository>(),
        entriesRepository: context.read<EntriesRepository>(),
      )..add(const HistoryStarted()),
      child: const HistoryView(),
    );
  }
}
