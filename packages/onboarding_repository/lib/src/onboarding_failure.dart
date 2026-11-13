/// {@template onboarding_failure}
/// Base class for failures thrown by the onboarding repository.
/// {@endtemplate}
abstract class OnboardingFailure implements Exception {
  /// {@macro onboarding_failure}
  const new(this.error);

  /// The underlying error.
  final Object error;

  @override
  String toString() => '$runtimeType: $error';
}

/// {@template fetch_onboarding_completed_failure}
/// Thrown when reading the onboarding status fails.
/// {@endtemplate}
class FetchOnboardingCompletedFailure extends OnboardingFailure {
  /// {@macro fetch_onboarding_completed_failure}
  const new(super.error);
}

/// {@template set_onboarding_completed_failure}
/// Thrown when saving the onboarding status fails.
/// {@endtemplate}
class SetOnboardingCompletedFailure extends OnboardingFailure {
  /// {@macro set_onboarding_completed_failure}
  const new(super.error);
}
