import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:terse/app/router/router.dart';

class _MockGoRouterState extends Mock implements GoRouterState;

void main() {
  group(AppRoute, () {
    test('has unique names', () {
      final names = AppRoute.values.map((route) => route.name).toSet();
      expect(names, hasLength(AppRoute.values.length));
    });

    test('has unique paths', () {
      final paths = AppRoute.values.map((route) => route.path).toSet();
      expect(paths, hasLength(AppRoute.values.length));
    });

    test('has paths that start with a slash', () {
      for (final route in AppRoute.values) {
        expect(route.path, startsWith('/'));
      }
    });

    test('route builds a GoRoute with the name and the path', () {
      final route = AppRoute.setup.route(
        builder: (context, state) => const SizedBox(),
      );

      expect(route.name, equals('setup'));
      expect(route.path, equals('/setup'));
    });

    group('isAt', () {
      late GoRouterState state;

      setUp(() {
        state = _MockGoRouterState();
      });

      test('is true when the matched location is the path', () {
        when(() => state.matchedLocation).thenReturn('/setup');
        expect(AppRoute.setup.isAt(state), isTrue);
      });

      test('is false for another location', () {
        when(() => state.matchedLocation).thenReturn('/');
        expect(AppRoute.setup.isAt(state), isFalse);
      });
    });
  });
}
