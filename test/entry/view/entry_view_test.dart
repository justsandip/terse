import 'package:bloc_test/bloc_test.dart';
import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/entry/entry.dart';

import '../../helpers/helpers.dart';

class _MockEntryBloc extends MockBloc<EntryEvent, EntryState>
    implements EntryBloc;

void main() {
  group(EntryView, () {
    const metrics = [
      MetricCatalog.sleepHours,
      MetricCatalog.mood,
      MetricCatalog.exerciseType,
    ];
    final day = DateTime(2026, 11, 17);

    EntryState state({
      EntryStatus status = EntryStatus.loaded,
      Map<String, MetricValue> values = const {
        'sleep_hours': NumberValue(7),
        'mood': NumberValue(4),
      },
      String? note = 'Good run before work.',
    }) {
      return EntryState(
        date: day,
        status: status,
        metrics: metrics,
        entry: Entry(date: day, values: values, note: note),
      );
    }

    late EntryBloc bloc;
    late int edits;

    setUpAll(() {
      registerFallbackValue(const EntryStarted());
    });

    setUp(() {
      bloc = _MockEntryBloc();
      edits = 0;
    });

    Future<void> pumpView(WidgetTester tester, EntryState initial) {
      whenListen(bloc, const Stream<EntryState>.empty(), initialState: initial);
      return tester.pumpApp(
        BlocProvider.value(
          value: bloc,
          child: EntryView(onEdit: () async => edits++),
        ),
      );
    }

    testWidgets('shows a spinner while loading', (tester) async {
      await pumpView(tester, EntryState(date: day));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('offers a retry when loading failed', (tester) async {
      await pumpView(
        tester,
        EntryState(date: day, status: EntryStatus.failure),
      );

      expect(find.text('Could not load this entry.'), findsOneWidget);

      await tester.tap(find.text('Try again'));

      verify(() => bloc.add(const EntryStarted())).called(1);
    });

    testWidgets('says when the entry no longer exists', (tester) async {
      await pumpView(
        tester,
        EntryState(date: day, status: EntryStatus.notFound),
      );

      expect(find.text('This entry no longer exists.'), findsOneWidget);
    });

    testWidgets('shows the day, what was set and the note', (tester) async {
      await pumpView(tester, state());

      expect(find.text('Tue, Nov 17'), findsOneWidget);
      expect(find.text('2 of 3 tracked'), findsOneWidget);
      expect(find.text('Sleep hours'), findsOneWidget);
      expect(find.text('7 h'), findsOneWidget);
      expect(find.text('Mood'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Exercise type'), findsOneWidget);
      expect(find.text('Not tracked'), findsOneWidget);
      expect(find.text('NOTE'), findsOneWidget);
      expect(find.text('Good run before work.'), findsOneWidget);
    });

    testWidgets('leaves out the note when there is none', (tester) async {
      await pumpView(tester, state(note: '  '));

      expect(find.text('NOTE'), findsNothing);
    });

    testWidgets('opens the day for editing, then reads it again', (
      tester,
    ) async {
      await pumpView(tester, state());

      await tester.tap(find.text('Edit entry'));
      await tester.pump();

      expect(edits, equals(1));
      verify(() => bloc.add(const EntryRefreshed())).called(1);
    });

    testWidgets('deletes only after the user confirms', (tester) async {
      await pumpView(tester, state());

      await tester.tap(find.text('Delete entry'));
      await tester.pumpAndSettle();

      expect(find.text('Delete this entry?'), findsOneWidget);
      expect(
        find.text(
          'Tue, Nov 17 and its note will be removed. This cannot be undone.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(() => bloc.add(const EntryDeleted())).called(1);
    });

    testWidgets('keeps the entry when the user backs out', (tester) async {
      await pumpView(tester, state());

      await tester.tap(find.text('Delete entry'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep it'));
      await tester.pumpAndSettle();

      expect(find.text('Delete this entry?'), findsNothing);
      verifyNever(() => bloc.add(const EntryDeleted()));
    });

    testWidgets('cannot be changed while it is being deleted', (tester) async {
      await pumpView(tester, state(status: EntryStatus.deleting));

      final edit = tester.widget<FilledButton>(find.byType(FilledButton));
      final delete = tester.widget<TextButton>(find.byType(TextButton));
      expect(edit.onPressed, isNull);
      expect(delete.onPressed, isNull);
    });

    testWidgets('says when deleting failed', (tester) async {
      await pumpView(tester, state(status: EntryStatus.deleteFailure));

      expect(
        find.text('Could not delete this entry. Try again.'),
        findsOneWidget,
      );
      final delete = tester.widget<TextButton>(find.byType(TextButton));
      expect(delete.onPressed, isNotNull);
    });

    testWidgets('closes once the entry is deleted', (tester) async {
      final states = Stream.fromIterable([state(status: EntryStatus.deleted)]);
      whenListen(bloc, states, initialState: state());
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: bloc,
                  child: EntryView(onEdit: () async {}),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(EntryView), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });
}
