import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/capture/capture.dart';

import '../../helpers/helpers.dart';

class _MockMetricsRepository extends Mock implements MetricsRepository;

class _MockEntriesRepository extends Mock implements EntriesRepository;

void main() {
  group(CapturePage, () {
    late MetricsRepository metricsRepository;
    late EntriesRepository entriesRepository;

    setUpAll(() {
      registerFallbackValue(DateTime(2026));
    });

    setUp(() {
      metricsRepository = _MockMetricsRepository();
      entriesRepository = _MockEntriesRepository();
      when(
        () => metricsRepository.fetchMetrics(),
      ).thenAnswer((_) async => [MetricCatalog.mood]);
      when(
        () => entriesRepository.fetchEntry(any()),
      ).thenAnswer((_) async => null);
    });

    testWidgets('loads today and shows the form', (tester) async {
      await tester.pumpApp(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: metricsRepository),
            RepositoryProvider.value(value: entriesRepository),
          ],
          child: const CapturePage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('How was today?'), findsOneWidget);
      expect(find.text('Mood'), findsOneWidget);
      verify(() => metricsRepository.fetchMetrics()).called(1);
    });
  });
}
