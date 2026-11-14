import 'package:flutter_test/flutter_test.dart';
import 'package:terse/app/app.dart';

void main() {
  group('AppState', () {
    test('defaults to unknown', () {
      expect(const AppState().status, equals(AppStatus.unknown));
    });

    test('supports value comparison', () {
      expect(const AppState(), equals(const AppState()));
      expect(
        const AppState(status: AppStatus.onboardingRequired),
        isNot(equals(const AppState())),
      );
    });
  });
}
