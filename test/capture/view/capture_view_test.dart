import 'package:bloc_test/bloc_test.dart';
import 'package:entries_repository/entries_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/capture/capture.dart';

import '../../helpers/helpers.dart';

class _MockCaptureBloc extends MockBloc<CaptureEvent, CaptureState>
    implements CaptureBloc;

void main() {
  group(CaptureView, () {
    const metrics = [
      MetricCatalog.sleepHours,
      MetricCatalog.mood,
      MetricCatalog.exerciseType,
    ];
    final today = DateTime(2026, 11, 19);

    CaptureState state({
      CaptureStatus status = CaptureStatus.ready,
      bool isToday = true,
      Map<String, MetricValue> suggestions = const {},
      Set<String> fromYesterday = const {},
      Map<String, MetricValue> confirmed = const {},
      String note = '',
      Duration? elapsed,
    }) {
      return CaptureState(
        status: status,
        date: today,
        metrics: metrics,
        isToday: isToday,
        suggestions: suggestions,
        suggestedFromYesterday: fromYesterday,
        confirmed: confirmed,
        note: note,
        elapsed: elapsed,
      );
    }

    late CaptureBloc bloc;

    setUpAll(() {
      registerFallbackValue(const CaptureStarted());
    });

    setUp(() {
      bloc = _MockCaptureBloc();
    });

    Future<void> pumpView(WidgetTester tester, CaptureState initial) {
      whenListen(
        bloc,
        const Stream<CaptureState>.empty(),
        initialState: initial,
      );
      return tester.pumpApp(
        BlocProvider.value(value: bloc, child: const CaptureView()),
      );
    }

    testWidgets('shows a spinner while loading', (tester) async {
      await pumpView(tester, const CaptureState());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('offers a retry when loading failed', (tester) async {
      await pumpView(
        tester,
        const CaptureState(status: CaptureStatus.loadFailure),
      );

      expect(find.text('Could not load this day.'), findsOneWidget);
      await tester.tap(find.text('Try again'));

      verify(() => bloc.add(const CaptureStarted())).called(1);
    });

    testWidgets('shows the date, the title and a row for each metric', (
      tester,
    ) async {
      await pumpView(tester, state());

      expect(find.text('Thu, Nov 19'), findsOneWidget);
      expect(find.text('How was today?'), findsOneWidget);
      expect(find.text('Sleep hours'), findsOneWidget);
      expect(find.text('Mood'), findsOneWidget);
      expect(find.text('Exercise type'), findsOneWidget);
      expect(find.text('Anything else? (optional)'), findsOneWidget);
    });

    testWidgets('cannot save before anything is set', (tester) async {
      await pumpView(tester, state());

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
      expect(find.text('Save today (0 of 3)'), findsOneWidget);
    });

    testWidgets('saves what was confirmed', (tester) async {
      await pumpView(tester, state(confirmed: const {'mood': NumberValue(3)}));

      await tester.tap(find.text('Save today (1 of 3)'));

      verify(() => bloc.add(const CaptureSubmitted())).called(1);
    });

    testWidgets('shows a spinner on the button while saving', (tester) async {
      await pumpView(
        tester,
        state(
          status: CaptureStatus.saving,
          confirmed: const {'mood': NumberValue(3)},
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('Save today'), findsNothing);
    });

    testWidgets('says so when saving failed', (tester) async {
      await pumpView(
        tester,
        state(
          status: CaptureStatus.saveFailure,
          confirmed: const {'mood': NumberValue(3)},
        ),
      );

      expect(find.text('Could not save this day. Try again.'), findsOneWidget);
    });

    testWidgets('confirms habits from yesterday in one tap', (tester) async {
      await pumpView(
        tester,
        state(
          suggestions: const {'sleep_hours': NumberValue(7)},
          fromYesterday: const {'sleep_hours'},
        ),
      );

      await tester.tap(find.text('Same as yesterday · 1 habit'));

      verify(() => bloc.add(const CaptureHabitsConfirmed())).called(1);
    });

    testWidgets('offers to confirm the day before on a day that is not today', (
      tester,
    ) async {
      await pumpView(
        tester,
        state(
          isToday: false,
          suggestions: const {'sleep_hours': NumberValue(7)},
          fromYesterday: const {'sleep_hours'},
        ),
      );

      expect(find.text('Same as the day before · 1 habit'), findsOneWidget);

      await tester.tap(find.text('Same as the day before · 1 habit'));

      verify(() => bloc.add(const CaptureHabitsConfirmed())).called(1);
    });

    testWidgets('says "Use suggestions" when they are not from yesterday', (
      tester,
    ) async {
      await pumpView(
        tester,
        state(
          suggestions: const {
            'sleep_hours': NumberValue(7),
            'exercise_type': ChoiceValue('walk'),
          },
          fromYesterday: const {'exercise_type'},
        ),
      );

      expect(find.text('Use suggestions · 2 habits'), findsOneWidget);
    });

    testWidgets('hides the habits button when there is nothing to confirm', (
      tester,
    ) async {
      await pumpView(
        tester,
        state(suggestions: const {'mood': NumberValue(4)}),
      );

      expect(find.textContaining('habit'), findsNothing);
    });

    testWidgets('hides the habits button while saving', (tester) async {
      await pumpView(
        tester,
        state(
          status: CaptureStatus.saving,
          suggestions: const {'sleep_hours': NumberValue(7)},
        ),
      );

      expect(find.textContaining('habit'), findsNothing);
    });

    testWidgets('sends the note as it is typed', (tester) async {
      await pumpView(tester, state(note: 'slept badly'));

      expect(find.text('slept badly'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'tired');

      verify(() => bloc.add(const CaptureNoteChanged('tired'))).called(1);
    });

    testWidgets('explains faded and solid values in a help sheet', (
      tester,
    ) async {
      await pumpView(tester, state());

      await tester.tap(find.byTooltip('How Today works'));
      await tester.pumpAndSettle();

      expect(find.text('Faded is a suggestion'), findsOneWidget);
      expect(find.text('Solid is yours'), findsOneWidget);
      expect(find.text('Skipped means not tracked'), findsOneWidget);
    });

    testWidgets('shows how long logging took once saved', (tester) async {
      await pumpView(
        tester,
        state(
          status: CaptureStatus.saved,
          elapsed: const Duration(seconds: 14),
        ),
      );

      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Logged in 14 s'), findsOneWidget);

      await tester.tap(find.text('Edit today'));

      verify(() => bloc.add(const CaptureEditRequested())).called(1);
    });

    testWidgets('shows no time when the user changed nothing', (tester) async {
      await pumpView(tester, state(status: CaptureStatus.saved));

      expect(find.text('Saved'), findsOneWidget);
      expect(find.textContaining('Logged in'), findsNothing);
    });
  });
}
