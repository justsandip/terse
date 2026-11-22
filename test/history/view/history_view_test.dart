import 'package:bloc_test/bloc_test.dart';
import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/history/history.dart';

import '../../helpers/helpers.dart';

class _MockHistoryBloc extends MockBloc<HistoryEvent, HistoryState>
    implements HistoryBloc;

void main() {
  group(HistoryView, () {
    const metrics = [MetricCatalog.sleepHours, MetricCatalog.mood];
    final today = DateTime(2026, 11, 22);

    final full = Entry(
      date: DateTime(2026, 11, 16),
      values: const {'sleep_hours': NumberValue(6), 'mood': NumberValue(3)},
    );
    final partial = Entry(
      date: DateTime(2026, 11, 17),
      values: const {'mood': NumberValue(4)},
    );

    HistoryState loaded({DateTime? month, List<Entry> entries = const []}) {
      return HistoryState(
        status: HistoryStatus.loaded,
        today: today,
        month: month ?? DateTime(2026, 11),
        metrics: metrics,
        entries: entries,
      );
    }

    late HistoryBloc bloc;

    setUpAll(() {
      registerFallbackValue(const HistoryStarted());
    });

    setUp(() {
      bloc = _MockHistoryBloc();
    });

    Future<void> pumpView(
      WidgetTester tester,
      HistoryState initial, {
      ValueChanged<DateTime>? onDayTap,
    }) {
      whenListen(
        bloc,
        const Stream<HistoryState>.empty(),
        initialState: initial,
      );
      return tester.pumpApp(
        BlocProvider.value(
          value: bloc,
          child: HistoryView(onDayTap: onDayTap),
        ),
      );
    }

    testWidgets('shows a spinner while loading', (tester) async {
      await pumpView(tester, const HistoryState());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('offers a retry when loading failed', (tester) async {
      await pumpView(
        tester,
        HistoryState(
          status: HistoryStatus.failure,
          today: today,
          month: DateTime(2026, 11),
        ),
      );

      expect(find.text('Could not load your history.'), findsOneWidget);

      await tester.tap(find.text('Try again'));

      verify(() => bloc.add(const HistoryRefreshed())).called(1);
    });

    testWidgets('shows the title, the count and the month', (tester) async {
      await pumpView(tester, loaded(entries: [full, partial]));

      expect(find.text('History'), findsOneWidget);
      expect(find.text('2 of 22 days logged'), findsOneWidget);
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.text('Everything set'), findsOneWidget);
      expect(find.text('Some set'), findsOneWidget);
    });

    testWidgets('says "1 day" for the first day of the month', (tester) async {
      await pumpView(
        tester,
        HistoryState(
          status: HistoryStatus.loaded,
          today: DateTime(2026, 11),
          month: DateTime(2026, 11),
          metrics: metrics,
        ),
      );

      expect(find.text('0 of 1 day logged'), findsOneWidget);
    });

    testWidgets('lists the entries newest first with what they hold', (
      tester,
    ) async {
      await pumpView(tester, loaded(entries: [full, partial]));

      expect(find.text('ENTRIES'), findsOneWidget);
      expect(find.text('Tue, Nov 17'), findsOneWidget);
      expect(find.text('Mon, Nov 16'), findsOneWidget);
      expect(find.text('Mood 4'), findsOneWidget);
      expect(find.text('Sleep hours 6 h · Mood 3'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Tue, Nov 17')).dy,
        lessThan(tester.getTopLeft(find.text('Mon, Nov 16')).dy),
      );
    });

    testWidgets('shows the note of an entry that holds only a note', (
      tester,
    ) async {
      await pumpView(
        tester,
        loaded(
          entries: [Entry(date: DateTime(2026, 11, 10), note: 'Rest day')],
        ),
      );

      expect(find.text('Rest day'), findsOneWidget);
    });

    testWidgets('says so when the month has no entries', (tester) async {
      await pumpView(tester, loaded());

      expect(find.text('Nothing logged this month.'), findsOneWidget);
    });

    testWidgets('goes back a month', (tester) async {
      await pumpView(tester, loaded());

      await tester.tap(find.byTooltip('Previous month'));

      verify(() => bloc.add(const HistoryMonthShifted(-1))).called(1);
    });

    testWidgets('cannot go forward from the current month', (tester) async {
      await pumpView(tester, loaded());

      final next = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(next.onPressed, isNull);
    });

    testWidgets('goes forward from an earlier month', (tester) async {
      await pumpView(tester, loaded(month: DateTime(2026, 10)));

      await tester.tap(find.byTooltip('Next month'));

      verify(() => bloc.add(const HistoryMonthShifted(1))).called(1);
    });

    testWidgets('opens an entry from the list', (tester) async {
      DateTime? opened;
      await pumpView(
        tester,
        loaded(entries: [full, partial]),
        onDayTap: (day) => opened = day,
      );

      await tester.tap(find.text('Mon, Nov 16'));

      expect(opened, equals(DateTime(2026, 11, 16)));
    });

    testWidgets('leaves the list inert without a callback', (tester) async {
      await pumpView(tester, loaded(entries: [full]));

      await tester.tap(find.text('Mon, Nov 16'));

      expect(tester.takeException(), isNull);
    });
  });
}
