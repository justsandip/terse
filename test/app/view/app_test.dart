// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:onboarding_repository/onboarding_repository.dart';
import 'package:terse/app/app.dart';
import 'package:terse/capture/capture.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository;

void main() {
  group('App', () {
    late OnboardingRepository onboardingRepository;

    setUp(() {
      onboardingRepository = _MockOnboardingRepository();
    });

    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(App(onboardingRepository: onboardingRepository));
      expect(find.byType(AppView), findsOneWidget);
    });

    testWidgets('provides the OnboardingRepository', (tester) async {
      await tester.pumpWidget(App(onboardingRepository: onboardingRepository));
      final context = tester.element(find.byType(AppView));
      expect(context.read<OnboardingRepository>(), same(onboardingRepository));
    });
  });

  group('AppView', () {
    testWidgets('renders CapturePage', (tester) async {
      await tester.pumpWidget(AppView());
      expect(find.byType(CapturePage), findsOneWidget);
    });

    testWidgets('disposes without errors', (tester) async {
      await tester.pumpWidget(AppView());
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });
}
