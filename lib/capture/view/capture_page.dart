import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:terse/capture/capture.dart';

class CapturePage extends StatelessWidget {
  const new({this.date, super.key});

  /// The day to log. Today when `null`.
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CaptureBloc(
        metricsRepository: context.read<MetricsRepository>(),
        entriesRepository: context.read<EntriesRepository>(),
        date: date,
      )..add(const CaptureStarted()),
      child: const CaptureView(),
    );
  }
}
