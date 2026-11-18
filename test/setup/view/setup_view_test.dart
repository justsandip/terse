import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/app/app.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/setup/setup.dart';
import 'package:terse/theme/theme.dart';

class _MockSetupBloc extends MockBloc<SetupEvent, SetupState>
    implements SetupBloc;

class _MockAppCubit extends MockCubit<AppState> implements AppCubit;

void main() {
  group(SetupView, () {
    const mood = MetricCatalog.mood;
    const energy = MetricCatalog.energy;
    const fullSelection = [
      MetricCatalog.sleepHours,
      MetricCatalog.sleepQuality,
      MetricCatalog.mood,
      MetricCatalog.energy,
      MetricCatalog.stress,
      MetricCatalog.caffeine,
    ];

    late SetupBloc setupBloc;
    late AppCubit appCubit;

    setUpAll(() {
      registerFallbackValue(const SetupSubmitted());
    });

    setUp(() {
      setupBloc = _MockSetupBloc();
      appCubit = _MockAppCubit();
      whenListen(
        appCubit,
        const Stream<AppState>.empty(),
        initialState: const AppState(),
      );
      when(() => appCubit.completeOnboarding()).thenAnswer((_) async {});
    });

    Future<void> pumpView(
      WidgetTester tester, {
      SetupState state = const SetupState(),
      Stream<SetupState>? states,
    }) async {
      whenListen(
        setupBloc,
        states ?? const Stream<SetupState>.empty(),
        initialState: state,
      );
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: setupBloc),
            BlocProvider.value(value: appCubit),
          ],
          child: MaterialApp(
            theme: const TerseTheme().themeData,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SetupView(),
          ),
        ),
      );
    }

    testWidgets('renders the title, the templates and the count', (
      tester,
    ) async {
      await pumpView(tester);

      expect(find.text('What to track?'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(3));
      expect(find.text('0 of 6'), findsOneWidget);
    });

    testWidgets('invites the user to pick when nothing is chosen', (
      tester,
    ) async {
      await pumpView(tester);

      expect(
        find.text('No metrics yet. Pick a template or add one.'),
        findsOneWidget,
      );
    });

    testWidgets('applies a template when its chip is tapped', (tester) async {
      await pumpView(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Sleep'));

      verify(
        () => setupBloc.add(const SetupTemplateSelected(SetupTemplate.sleep)),
      ).called(1);
    });

    testWidgets('highlights the template that matches the metrics', (
      tester,
    ) async {
      await pumpView(
        tester,
        state: SetupState(selected: SetupTemplate.mood.metrics),
      );

      final mood = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Mood'),
      );
      final sleep = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'Sleep'),
      );

      expect(mood.selected, isTrue);
      expect(sleep.selected, isFalse);
    });

    testWidgets('highlights no template when the metrics differ', (
      tester,
    ) async {
      await pumpView(tester, state: const SetupState(selected: [mood]));

      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));

      expect(chips.every((chip) => !chip.selected), isTrue);
    });

    testWidgets('lists the chosen metrics with their kind', (tester) async {
      await pumpView(
        tester,
        state: const SetupState(selected: [MetricCatalog.sleepHours, mood]),
      );

      final card = find.byType(Card);

      expect(
        find.descendant(of: card, matching: find.text('Sleep hours')),
        findsOneWidget,
      );
      expect(find.text('Hours'), findsOneWidget);
      expect(
        find.descendant(of: card, matching: find.text('Mood')),
        findsOneWidget,
      );
      expect(find.text('1 to 5'), findsOneWidget);
      expect(find.text('2 of 6'), findsOneWidget);
    });

    testWidgets('removes a metric when its button is tapped', (tester) async {
      await pumpView(tester, state: const SetupState(selected: [mood]));

      await tester.tap(find.byTooltip('Remove Mood'));

      verify(() => setupBloc.add(const SetupMetricRemoved(mood))).called(1);
    });

    testWidgets('adds the metric picked in the sheet', (tester) async {
      await pumpView(tester, state: const SetupState(selected: [mood]));

      await tester.tap(find.text('Add a metric'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Energy'));
      await tester.pumpAndSettle();

      verify(() => setupBloc.add(const SetupMetricAdded(energy))).called(1);
    });

    testWidgets('only offers metrics that are not chosen yet', (tester) async {
      await pumpView(tester, state: const SetupState(selected: [mood]));

      await tester.tap(find.text('Add a metric'));
      await tester.pumpAndSettle();

      expect(find.text('Choose a metric'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Mood'), findsNothing);
      expect(find.widgetWithText(ListTile, 'Energy'), findsOneWidget);
    });

    testWidgets('adds nothing when the sheet is dismissed', (tester) async {
      await pumpView(tester, state: const SetupState(selected: [mood]));

      await tester.tap(find.text('Add a metric'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(195, 40));
      await tester.pumpAndSettle();

      verifyNever(() => setupBloc.add(any()));
      expect(find.text('Choose a metric'), findsNothing);
    });

    testWidgets('disables adding when the limit is reached', (tester) async {
      await pumpView(tester, state: const SetupState(selected: fullSelection));

      final button = tester.widget<TextButton>(
        find.ancestor(
          of: find.text('Add a metric'),
          matching: find.byType(TextButton),
        ),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets('disables the button until a metric is chosen', (tester) async {
      await pumpView(tester);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));

      expect(button.onPressed, isNull);
    });

    testWidgets('starts when the button is tapped', (tester) async {
      await pumpView(tester, state: const SetupState(selected: [mood]));

      await tester.tap(find.byType(FilledButton));

      verify(() => setupBloc.add(const SetupSubmitted())).called(1);
    });

    testWidgets('shows progress while saving', (tester) async {
      await pumpView(
        tester,
        state: const SetupState(selected: [mood], status: SetupStatus.saving),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Start tracking'), findsNothing);
      expect(button.onPressed, isNull);
    });

    testWidgets('shows an error when saving failed', (tester) async {
      await pumpView(
        tester,
        state: const SetupState(selected: [mood], status: SetupStatus.failure),
      );

      expect(
        find.text('Could not save your metrics. Try again.'),
        findsOneWidget,
      );
      expect(find.text('Start tracking'), findsOneWidget);
    });

    testWidgets('completes onboarding once the metrics are saved', (
      tester,
    ) async {
      await pumpView(
        tester,
        state: const SetupState(selected: [mood]),
        states: Stream.value(
          const SetupState(selected: [mood], status: SetupStatus.success),
        ),
      );
      await tester.pump();

      verify(() => appCubit.completeOnboarding()).called(1);
    });

    testWidgets('does not complete onboarding before the save succeeds', (
      tester,
    ) async {
      await pumpView(
        tester,
        state: const SetupState(selected: [mood]),
        states: Stream.value(
          const SetupState(selected: [mood], status: SetupStatus.saving),
        ),
      );
      await tester.pump();

      verifyNever(() => appCubit.completeOnboarding());
    });
  });
}
