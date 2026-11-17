// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:onboarding_repository/onboarding_repository.dart';
import 'package:terse/app/app.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/setup/setup.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository;

class _MockMetricsRepository extends Mock implements MetricsRepository;

class _MockAppCubit extends MockCubit<AppState> implements AppCubit;

void main() {
  group('App', () {
    late OnboardingRepository onboardingRepository;
    late MetricsRepository metricsRepository;

    void stubStatus({required bool completed}) {
      when(() => onboardingRepository.fetchOnboardingCompleted())
          .thenAnswer((_) async => completed);
    }

    setUp(() {
      onboardingRepository = _MockOnboardingRepository();
      metricsRepository = _MockMetricsRepository();
      stubStatus(completed: true);
    });

    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(
        App(
          onboardingRepository: onboardingRepository,
          metricsRepository: metricsRepository,
        ),
      );
      expect(find.byType(AppView), findsOneWidget);
    });

    testWidgets('provides the OnboardingRepository', (tester) async {
      await tester.pumpWidget(
        App(
          onboardingRepository: onboardingRepository,
          metricsRepository: metricsRepository,
        ),
      );
      final context = tester.element(find.byType(AppView));
      expect(context.read<OnboardingRepository>(), same(onboardingRepository));
    });

    testWidgets('provides an AppCubit that fetches the status', (tester) async {
      await tester.pumpWidget(
        App(
          onboardingRepository: onboardingRepository,
          metricsRepository: metricsRepository,
        ),
      );
      final context = tester.element(find.byType(AppView));

      expect(context.read<AppCubit>(), isA<AppCubit>());
      verify(() => onboardingRepository.fetchOnboardingCompleted()).called(1);
    });

    testWidgets('shows CapturePage once onboarding is complete', (
      tester,
    ) async {
      await tester.pumpWidget(
        App(
          onboardingRepository: onboardingRepository,
          metricsRepository: metricsRepository,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CapturePage), findsOneWidget);
    });

    testWidgets('shows SetupPage while onboarding is incomplete', (
      tester,
    ) async {
      stubStatus(completed: false);

      await tester.pumpWidget(
        App(
          onboardingRepository: onboardingRepository,
          metricsRepository: metricsRepository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SetupPage), findsOneWidget);
    });
  });

  group('AppView', () {
    late AppCubit appCubit;

    setUp(() {
      appCubit = _MockAppCubit();
      whenListen(
        appCubit,
        const Stream<AppState>.empty(),
        initialState: AppState(status: AppStatus.ready),
      );
    });

    Widget buildSubject() {
      return BlocProvider.value(value: appCubit, child: AppView());
    }

    testWidgets('renders CapturePage when onboarding is complete', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(CapturePage), findsOneWidget);
    });

    testWidgets('disposes without errors', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });
}
