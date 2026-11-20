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
  group(MetricRow, () {
    late CaptureBloc bloc;

    setUpAll(() {
      registerFallbackValue(const CaptureStarted());
    });

    setUp(() {
      bloc = _MockCaptureBloc();
    });

    Future<void> pumpRow(
      WidgetTester tester, {
      required MetricDefinition metric,
      MetricValue? value,
      MetricValue? suggestion,
      bool fromYesterday = false,
    }) {
      return tester.pumpApp(
        BlocProvider.value(
          value: bloc,
          child: Scaffold(
            body: MetricRow(
              metric: metric,
              value: value,
              suggestion: suggestion,
              fromYesterday: fromYesterday,
            ),
          ),
        ),
      );
    }

    testWidgets('captions a faded value from yesterday', (tester) async {
      await pumpRow(
        tester,
        metric: MetricCatalog.sleepHours,
        suggestion: const NumberValue(7),
        fromYesterday: true,
      );

      expect(find.text('Sleep hours'), findsOneWidget);
      expect(find.text('Yesterday: 7 h'), findsOneWidget);
    });

    testWidgets('captions a start value as a suggestion', (tester) async {
      await pumpRow(
        tester,
        metric: MetricCatalog.sleepHours,
        suggestion: const NumberValue(7),
      );

      expect(find.text('Suggested: 7 h'), findsOneWidget);
    });

    testWidgets('has no caption once the user set a value', (tester) async {
      await pumpRow(
        tester,
        metric: MetricCatalog.sleepHours,
        value: const NumberValue(6.5),
        suggestion: const NumberValue(7),
        fromYesterday: true,
      );

      expect(find.textContaining('Yesterday'), findsNothing);
    });

    testWidgets('sends a number the user changes', (tester) async {
      await pumpRow(
        tester,
        metric: MetricCatalog.sleepHours,
        suggestion: const NumberValue(7),
      );

      await tester.tap(find.byTooltip('More Sleep hours'));

      verify(
        () => bloc.add(const CaptureValueSet('sleep_hours', NumberValue(7.5))),
      ).called(1);
    });

    testWidgets('sends and clears a scale value', (tester) async {
      await pumpRow(tester, metric: MetricCatalog.mood);
      await tester.tap(find.text('3'));
      verify(() => bloc.add(const CaptureValueSet('mood', NumberValue(3))))
          .called(1);

      await pumpRow(
        tester,
        metric: MetricCatalog.mood,
        value: const NumberValue(3),
      );
      await tester.tap(find.text('3'));
      verify(() => bloc.add(const CaptureValueCleared('mood'))).called(1);
    });

    testWidgets('spreads the dots of a scale across the row', (tester) async {
      await pumpRow(tester, metric: MetricCatalog.mood);

      // The row is 390 wide with 16 of padding on each side.
      expect(tester.getSize(find.byType(Wrap)).width, equals(358));
      expect(tester.getTopLeft(find.byType(CaptureToken).first).dx, 16);
      expect(tester.getTopRight(find.byType(CaptureToken).last).dx, 374);
    });

    testWidgets('keeps the pills of a choice as wide as their label', (
      tester,
    ) async {
      await pumpRow(tester, metric: MetricCatalog.exerciseType);

      final gym = tester.getSize(find.widgetWithText(CaptureToken, 'Gym'));
      expect(gym.width, lessThan(120));
      expect(gym.height, equals(44));
    });

    testWidgets('sends a choice', (tester) async {
      await pumpRow(tester, metric: MetricCatalog.exerciseType);

      await tester.tap(find.text('Run'));

      verify(
        () => bloc.add(
          const CaptureValueSet('exercise_type', ChoiceValue('run')),
        ),
      ).called(1);
    });

    testWidgets('sends a yes or no', (tester) async {
      await pumpRow(
        tester,
        metric: const MetricDefinition(
          key: 'meditated',
          kind: MetricKind.boolean,
        ),
      );

      expect(find.text('meditated'), findsOneWidget);

      await tester.tap(find.text('Yes'));

      verify(
        () => bloc.add(const CaptureValueSet('meditated', BooleanValue(true))),
      ).called(1);
    });
  });
}
