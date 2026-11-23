import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:terse/app/router/app_route.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/entry/entry.dart';

const _dateParameter = 'date';

/// A day as it is written in a path: `2026-11-17`.
String dayParameter(DateTime day) {
  final year = day.year.toString().padLeft(4, '0');
  final month = day.month.toString().padLeft(2, '0');
  final date = day.day.toString().padLeft(2, '0');
  return '$year-$month-$date';
}

/// Opens the entry of [day], and completes when the user comes back.
Future<void> openEntry(BuildContext context, DateTime day) {
  return context.pushNamed<void>(
    AppRoute.entry.name,
    pathParameters: {_dateParameter: dayParameter(day)},
  );
}

DateTime _dayOf(GoRouterState state) {
  return DateTime.parse(state.pathParameters[_dateParameter]!);
}

/// The routes of a single day. They sit outside the home shell, so they cover
/// the navigation bar.
List<GoRoute> entryRoutes() {
  return [
    AppRoute.entry.route(
      builder: (context, state) {
        final day = _dayOf(state);
        return EntryPage(
          date: day,
          onEdit: () => context.pushNamed<void>(
            AppRoute.entryEdit.name,
            pathParameters: {_dateParameter: dayParameter(day)},
          ),
        );
      },
    ),
    AppRoute.entryEdit.route(
      builder: (_, state) => CapturePage(date: _dayOf(state)),
    ),
  ];
}
