import 'package:flutter_test/flutter_test.dart';
import 'package:terse/onboarding/onboarding.dart';

void main() {
  group('OnboardingState', () {
    test('defaults to unknown', () {
      expect(const OnboardingState().status, equals(OnboardingStatus.unknown));
    });

    test('supports value comparison', () {
      expect(const OnboardingState(), equals(const OnboardingState()));
      expect(
        const OnboardingState(status: OnboardingStatus.complete),
        isNot(equals(const OnboardingState())),
      );
    });
  });
}
