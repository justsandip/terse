import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/home/home.dart';
import 'package:terse/l10n/l10n.dart';
import 'package:terse/theme/theme.dart';

/// A screen that records every time it is mounted.
class _Probe extends StatefulWidget {
  const new({required this.label, required this.mounts});

  final String label;
  final List<String> mounts;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    widget.mounts.add(widget.label);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.label),
        TextField(key: Key('${widget.label}-field')),
      ],
    );
  }
}

void main() {
  group('HomeShell', () {
    late List<String> mounts;
    late GoRouter router;

    setUp(() {
      mounts = [];
      router = GoRouter(
        routes: [
          StatefulShellRoute(
            builder: (_, _, shell) => HomeShell(navigationShell: shell),
            navigatorContainerBuilder: buildHomeBranches,
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (_, _) =>
                        _Probe(label: 'today-page', mounts: mounts),
                    routes: [
                      GoRoute(
                        path: 'second',
                        builder: (_, _) => const Text('second-page'),
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/history',
                    builder: (_, _) =>
                        _Probe(label: 'history-page', mounts: mounts),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
    });

    Future<void> pumpShell(WidgetTester tester) {
      return tester.pumpWidget(
        MaterialApp.router(
          theme: const TerseTheme().themeData,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
    }

    int selectedIndex(WidgetTester tester) {
      return tester
          .widget<NavigationBar>(find.byType(NavigationBar))
          .selectedIndex;
    }

    testWidgets('shows Today and History, with Today selected', (tester) async {
      await pumpShell(tester);

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(selectedIndex(tester), HomeTab.today.index);
      expect(find.text('today-page'), findsOneWidget);
    });

    testWidgets('opens History from the navigation bar', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(selectedIndex(tester), HomeTab.history.index);
      expect(find.text('history-page'), findsOneWidget);
    });

    testWidgets('keeps what was typed in Today while History is shown', (
      tester,
    ) async {
      await pumpShell(tester);
      await tester.enterText(
        find.byKey(const Key('today-page-field')),
        'draft',
      );

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(find.text('draft'), findsOneWidget);
      expect(mounts.where((label) => label == 'today-page'), hasLength(1));
    });

    testWidgets('mounts History again each time it is opened', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      expect(mounts.where((label) => label == 'history-page'), hasLength(2));
    });

    testWidgets('tapping the shown tab goes back to its first screen', (
      tester,
    ) async {
      await pumpShell(tester);
      router.go('/second');
      await tester.pumpAndSettle();
      expect(find.text('second-page'), findsOneWidget);

      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(find.text('second-page'), findsNothing);
      expect(find.text('today-page'), findsOneWidget);
    });
  });
}
