import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:onboarding_repository/onboarding_repository.dart';
import 'package:terse/onboarding/onboarding.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository;

void main() {
  group('OnboardingCubit', () {
    late OnboardingRepository onboardingRepository;

    setUp(() {
      onboardingRepository = _MockOnboardingRepository();
    });

    OnboardingCubit buildCubit() {
      return OnboardingCubit(onboardingRepository: onboardingRepository);
    }

    test('initial state is unknown', () {
      expect(buildCubit().state, equals(const OnboardingState()));
    });

    group('fetchOnboardingCompleted', () {
      blocTest<OnboardingCubit, OnboardingState>(
        'emits complete when onboarding is completed',
        setUp: () {
          when(() => onboardingRepository.fetchOnboardingCompleted())
              .thenAnswer((_) async => true);
        },
        build: buildCubit,
        act: (cubit) => cubit.fetchOnboardingCompleted(),
        expect: () => [
          const OnboardingState(status: OnboardingStatus.complete),
        ],
      );

      blocTest<OnboardingCubit, OnboardingState>(
        'emits incomplete when onboarding is not completed',
        setUp: () {
          when(() => onboardingRepository.fetchOnboardingCompleted())
              .thenAnswer((_) async => false);
        },
        build: buildCubit,
        act: (cubit) => cubit.fetchOnboardingCompleted(),
        expect: () => [
          const OnboardingState(status: OnboardingStatus.incomplete),
        ],
      );

      blocTest<OnboardingCubit, OnboardingState>(
        'emits failure and reports the error when fetching fails',
        setUp: () {
          when(() => onboardingRepository.fetchOnboardingCompleted())
              .thenThrow(const FetchOnboardingCompletedFailure('oops'));
        },
        build: buildCubit,
        act: (cubit) => cubit.fetchOnboardingCompleted(),
        expect: () => [const OnboardingState(status: OnboardingStatus.failure)],
        errors: () => [isA<FetchOnboardingCompletedFailure>()],
      );
    });

    group('completeOnboarding', () {
      blocTest<OnboardingCubit, OnboardingState>(
        'saves the status and emits complete',
        setUp: () {
          when(
            () => onboardingRepository.setOnboardingCompleted(
              completed: any(named: 'completed'),
            ),
          ).thenAnswer((_) async {});
        },
        build: buildCubit,
        act: (cubit) => cubit.completeOnboarding(),
        expect: () => [
          const OnboardingState(status: OnboardingStatus.complete),
        ],
        verify: (_) {
          verify(
            () => onboardingRepository.setOnboardingCompleted(completed: true),
          ).called(1);
        },
      );

      blocTest<OnboardingCubit, OnboardingState>(
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
        expect: () => [const OnboardingState(status: OnboardingStatus.failure)],
        errors: () => [isA<SetOnboardingCompletedFailure>()],
      );
    });
  });
}
