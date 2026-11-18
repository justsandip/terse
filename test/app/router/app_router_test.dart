import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:metrics_repository/metrics_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:onboarding_repository/onboarding_repository.dart';
import 'package:terse/app/app.dart';
import 'package:terse/app/router/router.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/setup/setup.dart';
import 'package:terse/splash/splash.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository;

class _MockMetricsRepository extends Mock implements MetricsRepository;

void main() {
  group(AppRouter, () {
    late OnboardingRepository onboardingRepository;
    late MetricsRepository metricsRepository;

    late AppCubit appCubit;
    late AppRouter appRouter;

    setUp(() {
      onboardingRepository = _MockOnboardingRepository();
      metricsRepository = _MockMetricsRepository();

      appCubit = AppCubit(onboardingRepository: onboardingRepository);
      appRouter = AppRouter(appCubit: appCubit);
    });

    tearDown(() async {
      appRouter.dispose();
      await appCubit.close();
    });

    void stubStatus({required bool completed}) {
      when(() => onboardingRepository.fetchOnboardingCompleted())
          .thenAnswer((_) async => completed);
    }

    Future<void> pumpRouter(WidgetTester tester) async {
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: metricsRepository,
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: appRouter.router,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows SplashPage while the status is unknown', (tester) async {
      await pumpRouter(tester);

      expect(find.byType(SplashPage), findsOneWidget);
    });

    testWidgets('shows SetupPage when onboarding is incomplete', (
      tester,
    ) async {
      stubStatus(completed: false);
      await appCubit.fetchOnboardingCompleted();

      await pumpRouter(tester);

      expect(find.byType(SetupPage), findsOneWidget);
    });

    testWidgets('shows SetupPage when the status cannot be read', (
      tester,
    ) async {
      when(() => onboardingRepository.fetchOnboardingCompleted())
          .thenThrow(const FetchOnboardingCompletedFailure('oops'));
      await appCubit.fetchOnboardingCompleted();

      await pumpRouter(tester);

      expect(find.byType(SetupPage), findsOneWidget);
    });

    testWidgets('shows CapturePage when onboarding is complete', (
      tester,
    ) async {
      stubStatus(completed: true);
      await appCubit.fetchOnboardingCompleted();

      await pumpRouter(tester);
      await tester.pumpAndSettle();
      expect(find.byType(CapturePage), findsOneWidget);
    });

    testWidgets('leaves SplashPage once the status is known', (tester) async {
      await pumpRouter(tester);
      expect(find.byType(SplashPage), findsOneWidget);

      stubStatus(completed: true);
      await appCubit.fetchOnboardingCompleted();
      await tester.pumpAndSettle();

      expect(find.byType(CapturePage), findsOneWidget);
    });

    testWidgets('leaves SetupPage once onboarding completes', (tester) async {
      stubStatus(completed: false);
      await appCubit.fetchOnboardingCompleted();
      await pumpRouter(tester);
      expect(find.byType(SetupPage), findsOneWidget);

      when(
        () => onboardingRepository.setOnboardingCompleted(
          completed: any(named: 'completed'),
        ),
      ).thenAnswer((_) async {});
      await appCubit.completeOnboarding();
      await tester.pumpAndSettle();

      expect(find.byType(CapturePage), findsOneWidget);
    });

    testWidgets('sends a completed user away from SetupPage', (tester) async {
      stubStatus(completed: true);
      await appCubit.fetchOnboardingCompleted();
      await pumpRouter(tester);

      appRouter.router.goNamed(AppRoute.setup.name);
      await tester.pumpAndSettle();

      expect(find.byType(CapturePage), findsOneWidget);
      expect(find.byType(SetupPage), findsNothing);
    });
  });
}
