import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/app/router/entry_routes.dart';
import 'package:terse/app/router/home_route.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/entry/entry.dart';
import 'package:terse/history/history.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/theme/theme.dart';

class _MockMetricsRepository extends Mock implements MetricsRepository;

class _MockEntriesRepository extends Mock implements EntriesRepository;

void main() {
  group('dayParameter', () {
    test('writes a day as yyyy-MM-dd', () {
      expect(dayParameter(DateTime(2026, 1, 5, 23)), equals('2026-01-05'));
      expect(dayParameter(DateTime(2026, 11, 17)), equals('2026-11-17'));
    });
  });

  group('home and entry routes', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    late MetricsRepository metricsRepository;
    late EntriesRepository entriesRepository;
    late GoRouter router;

    setUpAll(() {
      registerFallbackValue(DateTime(2026));
    });

    setUp(() {
      metricsRepository = _MockMetricsRepository();
      entriesRepository = _MockEntriesRepository();
      final entry = Entry(date: today, values: const {'mood': NumberValue(3)});
      when(() => metricsRepository.fetchMetrics())
          .thenAnswer((_) async => [MetricCatalog.mood]);
      when(() => entriesRepository.fetchEntry(any()))
          .thenAnswer((invocation) async {
            final date = invocation.positionalArguments.first as DateTime;
            return date == today ? entry : null;
          });
      when(
        () => entriesRepository.fetchEntries(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => [entry]);

      router = GoRouter(routes: [homeRoute(), ...entryRoutes()]);
      addTearDown(router.dispose);
    });

    Future<void> pumpRouter(WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: metricsRepository),
            RepositoryProvider.value(value: entriesRepository),
          ],
          child: MaterialApp.router(
            theme: const TerseTheme().themeData,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('starts on Today', (tester) async {
      await pumpRouter(tester);

      expect(find.byType(CapturePage), findsOneWidget);
    });

    testWidgets('opens a day from History, and reads the month on return', (
      tester,
    ) async {
      await pumpRouter(tester);
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.byType(HistoryPage), findsOneWidget);

      await tester.tap(find.text('Mood 3'));
      await tester.pumpAndSettle();

      expect(find.byType(EntryPage), findsOneWidget);
      expect(find.text('Edit entry'), findsOneWidget);
      // The entry covers the navigation bar.
      expect(find.byType(NavigationBar), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(HistoryPage), findsOneWidget);
      verify(
        () => entriesRepository.fetchEntries(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).called(2);
    });

    testWidgets('edits the day of an entry, then reads the entry again', (
      tester,
    ) async {
      router.go('/entries/${dayParameter(today)}');
      await pumpRouter(tester);
      // verify marks the calls it matched, so each check below counts only
      // the calls made since the one before it.
      verify(() => entriesRepository.fetchEntry(today)).called(1);

      await tester.tap(find.text('Edit entry'));
      await tester.pumpAndSettle();

      expect(find.byType(CapturePage), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      // Capture read the same day too.
      verify(() => entriesRepository.fetchEntry(today)).called(1);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(EntryPage), findsOneWidget);
      // The entry was read again after coming back.
      verify(() => entriesRepository.fetchEntry(today)).called(1);
    });
  });
}
