part of 'onboarding_cubit.dart';

enum OnboardingStatus { unknown, incomplete, complete, failure }

final class OnboardingState extends Equatable {
  const new({this.status = OnboardingStatus.unknown});

  final OnboardingStatus status;

  @override
  List<Object> get props => [status];
}
