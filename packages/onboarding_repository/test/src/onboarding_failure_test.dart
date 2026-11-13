import 'package:onboarding_repository/onboarding_repository.dart';
import 'package:test/test.dart';

void main() {
  group(OnboardingFailure, () {
    test('toString includes the type and the error', () {
      const failure = FetchOnboardingCompletedFailure('boom');

      expect(
        failure.toString(),
        equals('FetchOnboardingCompletedFailure: boom'),
      );
    });
  });
}
