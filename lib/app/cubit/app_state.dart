part of 'app_cubit.dart';

enum AppStatus { unknown, onboardingRequired, ready, failure }

final class AppState extends Equatable {
  const new({this.status = AppStatus.unknown});
  final AppStatus status;

  @override
  List<Object> get props => [status];
}
