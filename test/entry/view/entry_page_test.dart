import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/entry/entry.dart';

import '../../helpers/helpers.dart';

class _MockMetricsRepository extends Mock implements MetricsRepository;

class _MockEntriesRepository extends Mock implements EntriesRepository;

void main() {
  group(EntryPage, () {
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
      when(() => entriesRepository.fetchEntry(any())).thenAnswer(
        (_) async => Entry(
          date: DateTime(2026, 11, 17),
          values: const {'mood': NumberValue(4)},
        ),
      );
    });

    testWidgets('loads the entry of the day and shows it', (tester) async {
      await tester.pumpApp(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: metricsRepository),
            RepositoryProvider.value(value: entriesRepository),
          ],
          child: EntryPage(date: DateTime(2026, 11, 17), onEdit: () async {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tue, Nov 17'), findsOneWidget);
      expect(find.text('Mood'), findsOneWidget);
      verify(() => entriesRepository.fetchEntry(DateTime(2026, 11, 17)))
          .called(1);
    });
  });
}
