import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:terse/app/app.dart';
import 'package:terse/app/router/app_route.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/history/history.dart';
import 'package:terse/home/home.dart';
import 'package:terse/setup/setup.dart';
import 'package:terse/splash/splash.dart';

/// {@template app_router}
/// Owns the app's [GoRouter] and the route tree.
/// {@endtemplate}
class AppRouter {
  /// {@macro app_router}
  new({required this._appCubit})
    : _refresh = _StreamListenable(_appCubit.stream) {
    router = GoRouter(
      initialLocation: AppRoute.splash.path,
      refreshListenable: _refresh,
      redirect: (context, state) => _redirect(state),
      routes: [
        AppRoute.splash.route(builder: (_, _) => const SplashPage()),
        AppRoute.setup.route(builder: (_, _) => const SetupPage()),
        StatefulShellRoute(
          builder: (_, _, navigationShell) {
            return HomeShell(navigationShell: navigationShell);
          },
          navigatorContainerBuilder: buildHomeBranches,
          // The order of the branches is the order of HomeTab.
          branches: [
            StatefulShellBranch(
              routes: [
                AppRoute.capture.route(builder: (_, _) => const CapturePage()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                AppRoute.history.route(builder: (_, _) => const HistoryPage()),
              ],
            ),
          ],
        ),
      ],
    );
  }

  final AppCubit _appCubit;
  final _StreamListenable _refresh;

  /// The router to hand to `MaterialApp.router`.
  late final GoRouter router;

  String? _redirect(GoRouterState state) {
    return switch (_appCubit.state.status) {
      AppStatus.unknown =>
        AppRoute.splash.isAt(state) ? null : AppRoute.splash.path,
      AppStatus.onboardingRequired || AppStatus.failure =>
        AppRoute.setup.isAt(state) ? null : AppRoute.setup.path,
      AppStatus.ready =>
        AppRoute.splash.isAt(state) || AppRoute.setup.isAt(state)
            ? AppRoute.capture.path
            : null,
    };
  }

  /// Releases the resources held by the router.
  void dispose() {
    router.dispose();
    _refresh.dispose();
  }
}

/// Notifies its listeners every time stream emits, so the router
/// re-evaluates its redirect.
class _StreamListenable extends ChangeNotifier {
  new(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
