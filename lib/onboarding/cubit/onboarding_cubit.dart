import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onboarding_repository/onboarding_repository.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  new({required this._onboardingRepository}) : super(const OnboardingState());

  final OnboardingRepository _onboardingRepository;

  Future<void> fetchOnboardingCompleted() async {
    try {
      final completed = await _onboardingRepository.fetchOnboardingCompleted();
      emit(
        OnboardingState(
          status: completed
              ? OnboardingStatus.complete
              : OnboardingStatus.incomplete,
        ),
      );
    } on OnboardingFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(const OnboardingState(status: OnboardingStatus.failure));
    }
  }

  Future<void> completeOnboarding() async {
    try {
      await _onboardingRepository.setOnboardingCompleted(completed: true);
      emit(const OnboardingState(status: OnboardingStatus.complete));
    } on OnboardingFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(const OnboardingState(status: OnboardingStatus.failure));
    }
  }
}
