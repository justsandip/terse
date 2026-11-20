// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:entries_repository/entries_repository.dart';
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

class _MockEntriesRepository extends Mock implements EntriesRepository;

class _MockAppCubit extends MockCubit<AppState> implements AppCubit;

void main() {
  group('App', () {
    late OnboardingRepository onboardingRepository;
    late MetricsRepository metricsRepository;
    late EntriesRepository entriesRepository;

    void stubStatus({required bool completed}) {
      when(() => onboardingRepository.fetchOnboardingCompleted())
          .thenAnswer((_) async => completed);
      when(() => metricsRepository.fetchMetrics()).thenAnswer((_) async => []);
      when(() => entriesRepository.fetchEntry(any()))
          .thenAnswer((_) async => null);
    }

    setUp(() {
      onboardingRepository = _MockOnboardingRepository();
      metricsRepository = _MockMetricsRepository();
      entriesRepository = _MockEntriesRepository();
      stubStatus(completed: true);
    });

    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(
        App(
          onboardingRepository: onboardingRepository,
          metricsRepository: metricsRepository,
          entriesRepository: entriesRepository,
        ),
      );
      expect(find.byType(AppView), findsOneWidget);
    });

    testWidgets('provides the OnboardingRepository', (tester) async {
      await tester.pumpWidget(
        App(
          onboardingRepository: onboardingRepository,
          metricsRepository: metricsRepository,
          entriesRepository: entriesRepository,
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
          entriesRepository: entriesRepository,
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
          entriesRepository: entriesRepository,
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
          entriesRepository: entriesRepository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SetupPage), findsOneWidget);
    });
  });

  group('AppView', () {
    late AppCubit appCubit;
    late MetricsRepository metricsRepository;
    late EntriesRepository entriesRepository;

    setUpAll(() {
      registerFallbackValue(DateTime(2026));
    });

    setUp(() {
      appCubit = _MockAppCubit();
      metricsRepository = _MockMetricsRepository();
      entriesRepository = _MockEntriesRepository();
      whenListen(
        appCubit,
        const Stream<AppState>.empty(),
        initialState: AppState(status: AppStatus.ready),
      );
      when(() => metricsRepository.fetchMetrics()).thenAnswer((_) async => []);
      when(() => entriesRepository.fetchEntry(any()))
          .thenAnswer((_) async => null);
    });

    Widget buildSubject() {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: metricsRepository),
          RepositoryProvider.value(value: entriesRepository),
        ],
        child: BlocProvider.value(value: appCubit, child: AppView()),
      );
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
