import 'package:go_router/go_router.dart';

/// {@template app_route}
/// The app's routes.
///
/// Each value is the route's name, through [name], and carries its [path].
/// {@endtemplate}
enum AppRoute {
  /// The screen shown while the onboarding status is being read.
  splash('/splash'),

  /// The capture screen.
  capture('/'),

  /// The history screen, the second tab of the home shell.
  history('/history'),

  /// The setup screen.
  setup('/setup'),

  /// What was logged on one day. The day is written `yyyy-MM-dd`.
  entry('/entries/:date'),

  /// Logging a day other than today, from its entry.
  entryEdit('/entries/:date/edit');

  /// {@macro app_route}
  new(this.path);

  /// The location of the route.
  final String path;

  /// Builds the [GoRoute] for this route, named [name] and located at [path].
  GoRoute route({required GoRouterWidgetBuilder builder}) {
    return GoRoute(name: name, path: path, builder: builder);
  }

  /// Whether [state] is currently at this route.
  ///
  /// It compares locations, not names: the state a top-level redirect
  /// receives has no route name.
  bool isAt(GoRouterState state) => state.matchedLocation == path;
}
