// ignore_for_file: prefer_const_constructors

import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/history/history.dart';

import '../../helpers/helpers.dart';

class _MockMetricsRepository extends Mock implements MetricsRepository;

class _MockEntriesRepository extends Mock implements EntriesRepository;

void main() {
  group(HistoryPage, () {
    late MetricsRepository metricsRepository;
    late EntriesRepository entriesRepository;

    setUpAll(() {
      registerFallbackValue(DateTime(2026));
    });

    setUp(() {
      metricsRepository = _MockMetricsRepository();
      entriesRepository = _MockEntriesRepository();
      when(() => metricsRepository.fetchMetrics())
          .thenAnswer((_) async => [MetricCatalog.mood]);
      when(
        () => entriesRepository.fetchEntries(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => []);
    });

    testWidgets('loads the current month and shows it', (tester) async {
      await tester.pumpApp(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: metricsRepository),
            RepositoryProvider.value(value: entriesRepository),
          ],
          child: HistoryPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
      expect(find.text('Nothing logged this month.'), findsOneWidget);
      verify(
        () => entriesRepository.fetchEntries(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).called(1);
    });
  });
}
