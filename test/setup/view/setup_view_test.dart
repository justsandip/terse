import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/app/app.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/setup/setup.dart';
import 'package:terse/theme/theme.dart';

class _MockSetupCubit extends MockCubit<SetupState> implements SetupCubit;

class _MockAppCubit extends MockCubit<AppState> implements AppCubit;

void main() {
  group(SetupView, () {
    late SetupCubit setupCubit;
    late AppCubit appCubit;

    setUp(() {
      setupCubit = _MockSetupCubit();
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
    }) async {
      whenListen(
        setupCubit,
        const Stream<SetupState>.empty(),
        initialState: state,
      );
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: setupCubit),
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

    testWidgets('renders the title, templates, metrics and the button', (
      tester,
    ) async {
      await pumpView(tester);

      expect(find.text('What to track?'), findsOneWidget);
      expect(find.byType(ActionChip), findsNWidgets(3));
      expect(find.byType(FilterChip), findsNWidgets(7));
      expect(find.text('0 of 6'), findsOneWidget);
      expect(find.text('Start tracking'), findsOneWidget);
    });

    testWidgets('shows every template and metric label', (tester) async {
      await pumpView(tester);

      for (final label in ['Sleep', 'Mood', 'Fitness']) {
        expect(find.widgetWithText(ActionChip, label), findsOneWidget);
      }
      for (final label in [
        'Sleep hours',
        'Sleep quality',
        'Mood',
        'Energy',
        'Stress',
        'Caffeine',
        'Exercise',
      ]) {
        expect(find.widgetWithText(FilterChip, label), findsOneWidget);
      }
    });

    testWidgets('applies a template when its chip is tapped', (tester) async {
      await pumpView(tester);

      await tester.tap(find.widgetWithText(ActionChip, 'Sleep'));

      verify(() => setupCubit.applyTemplate(SetupTemplate.sleep)).called(1);
    });

    testWidgets('toggles a metric when its chip is tapped', (tester) async {
      await pumpView(tester);

      await tester.tap(find.widgetWithText(FilterChip, 'Mood'));

      verify(() => setupCubit.toggle(SetupMetric.mood)).called(1);
    });

    testWidgets('shows selected metrics and the count', (tester) async {
      await pumpView(
        tester,
        state: const SetupState(selected: {SetupMetric.mood}),
      );

      final chip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Mood'),
      );

      expect(chip.selected, isTrue);
      expect(find.text('1 of 6'), findsOneWidget);
    });

    testWidgets('disables the button until a metric is selected', (
      tester,
    ) async {
      await pumpView(tester);

      final button = tester.widget<FilledButton>(find.byType(FilledButton));

      expect(button.onPressed, isNull);
    });

    testWidgets('completes onboarding when the button is tapped', (
      tester,
    ) async {
      await pumpView(
        tester,
        state: const SetupState(selected: {SetupMetric.mood}),
      );

      await tester.tap(find.byType(FilledButton));

      verify(() => appCubit.completeOnboarding()).called(1);
    });

    testWidgets('disables unselected metrics when the limit is reached', (
      tester,
    ) async {
      await pumpView(
        tester,
        state: const SetupState(
          selected: {
            SetupMetric.sleepHours,
            SetupMetric.sleepQuality,
            SetupMetric.mood,
            SetupMetric.energy,
            SetupMetric.stress,
            SetupMetric.caffeine,
          },
        ),
      );

      final unselected = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Exercise'),
      );
      final selected = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, 'Mood'),
      );

      expect(unselected.onSelected, isNull);
      expect(selected.onSelected, isNotNull);
    });
  });
}
