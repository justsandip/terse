import 'package:go_router/go_router.dart';
import 'package:terse/app/router/app_route.dart';
import 'package:terse/app/router/entry_routes.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/history/history.dart';
import 'package:terse/home/home.dart';

/// The main screens, as tabs. The order of the branches is the order of
/// [HomeTab].
StatefulShellRoute homeRoute() {
  return StatefulShellRoute(
    builder: (_, _, navigationShell) {
      return HomeShell(navigationShell: navigationShell);
    },
    navigatorContainerBuilder: buildHomeBranches,
    branches: [
      StatefulShellBranch(
        routes: [
          AppRoute.capture.route(builder: (_, _) => const CapturePage()),
        ],
      ),
      StatefulShellBranch(
        routes: [
          AppRoute.history.route(
            builder: (context, _) {
              return HistoryPage(onDayTap: (day) => openEntry(context, day));
            },
          ),
        ],
      ),
    ],
  );
}
