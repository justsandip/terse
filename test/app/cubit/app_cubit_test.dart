import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:onboarding_repository/onboarding_repository.dart';
import 'package:terse/app/app.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository;

void main() {
  group('AppCubit', () {
    late OnboardingRepository onboardingRepository;

    setUp(() {
      onboardingRepository = _MockOnboardingRepository();
    });

    AppCubit buildCubit() {
      return AppCubit(onboardingRepository: onboardingRepository);
    }

    test('initial state is unknown', () {
      expect(buildCubit().state, equals(const AppState()));
    });

    group('fetchOnboardingCompleted', () {
      blocTest<AppCubit, AppState>(
        'emits ready when onboarding is completed',
        setUp: () {
          when(() => onboardingRepository.fetchOnboardingCompleted())
              .thenAnswer((_) async => true);
        },
        build: buildCubit,
        act: (cubit) => cubit.fetchOnboardingCompleted(),
        expect: () => [const AppState(status: AppStatus.ready)],
      );

      blocTest<AppCubit, AppState>(
        'emits onboardingRequired when onboarding is not completed',
        setUp: () {
          when(() => onboardingRepository.fetchOnboardingCompleted())
              .thenAnswer((_) async => false);
        },
        build: buildCubit,
        act: (cubit) => cubit.fetchOnboardingCompleted(),
        expect: () => [const AppState(status: AppStatus.onboardingRequired)],
      );

      blocTest<AppCubit, AppState>(
        'emits failure and reports the error when fetching fails',
        setUp: () {
          when(() => onboardingRepository.fetchOnboardingCompleted())
              .thenThrow(const FetchOnboardingCompletedFailure('oops'));
        },
        build: buildCubit,
        act: (cubit) => cubit.fetchOnboardingCompleted(),
        expect: () => [const AppState(status: AppStatus.failure)],
        errors: () => [isA<FetchOnboardingCompletedFailure>()],
      );
    });

    group('completeOnboarding', () {
      blocTest<AppCubit, AppState>(
        'saves the status and emits ready',
        setUp: () {
          when(
            () => onboardingRepository.setOnboardingCompleted(
              completed: any(named: 'completed'),
            ),
          ).thenAnswer((_) async {});
        },
        build: buildCubit,
        act: (cubit) => cubit.completeOnboarding(),
        expect: () => [const AppState(status: AppStatus.ready)],
        verify: (_) {
          verify(
            () => onboardingRepository.setOnboardingCompleted(completed: true),
          ).called(1);
        },
      );

      blocTest<AppCubit, AppState>(
        'emits failure and reports the error when saving fails',
        setUp: () {
          when(
            () => onboardingRepository.setOnboardingCompleted(
              completed: any(named: 'completed'),
            ),
          ).thenThrow(const SetOnboardingCompletedFailure('oops'));
        },
        build: buildCubit,
        act: (cubit) => cubit.completeOnboarding(),
        expect: () => [const AppState(status: AppStatus.failure)],
        errors: () => [isA<SetOnboardingCompletedFailure>()],
      );
    });
  });
}
