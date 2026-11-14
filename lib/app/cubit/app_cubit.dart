import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:onboarding_repository/onboarding_repository.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  new({required this._onboardingRepository}) : super(const AppState());

  final OnboardingRepository _onboardingRepository;

  Future<void> fetchOnboardingCompleted() async {
    try {
      final completed = await _onboardingRepository.fetchOnboardingCompleted();
      emit(
        AppState(
          status: completed ? AppStatus.ready : AppStatus.onboardingRequired,
        ),
      );
    } on OnboardingFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(const AppState(status: AppStatus.failure));
    }
  }

  Future<void> completeOnboarding() async {
    try {
      await _onboardingRepository.setOnboardingCompleted(completed: true);
      emit(const AppState(status: AppStatus.ready));
    } on OnboardingFailure catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(const AppState(status: AppStatus.failure));
    }
  }
}
