import 'package:go_router/go_router.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/setup/setup.dart';

/// Names of the app's routes
abstract class RouteNames {
  /// The capture screen.
  static const capture = 'capture';

  /// The setup screen.
  static const setup = 'setup';
}

/// {@template app_router}
/// Owns the app's [GoRouter] and the route tree.
/// {@endtemplate}
class AppRouter {
  /// {@macro app_router}
  new()
    : router = GoRouter(
        routes: [
          GoRoute(
            name: RouteNames.capture,
            path: '/',
            builder: (context, state) => const CapturePage(),
          ),
          GoRoute(
            name: RouteNames.setup,
            path: '/setup',
            builder: (context, state) => const SetupPage(),
          ),
        ],
      );

  /// The router to hand to `MaterialApp.router`.
  final GoRouter router;

  /// Releases the resources held by [router].
  void dispose() => router.dispose();
}
