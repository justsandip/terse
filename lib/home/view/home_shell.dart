import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/l10n/l10n.dart';

/// The tabs of the home shell, in the order of the router's branches.
enum HomeTab {
  /// Capturing today.
  today,

  /// Looking back at earlier days.
  history,
}

/// Lays out the branches of the home shell.
///
/// The Today branch stays mounted while another tab is shown, so an
/// unsaved entry survives a trip to History. Any other branch is mounted
/// only while shown, so it reads again each time it is opened. Otherwise
/// History would keep showing the month as it was before today was saved.
Widget buildHomeBranches(
  BuildContext context,
  StatefulNavigationShell navigationShell,
  List<Widget> children,
) {
  return IndexedStack(
    index: navigationShell.currentIndex,
    children: [
      for (final (index, child) in children.indexed)
        if (index == HomeTab.today.index ||
            index == navigationShell.currentIndex)
          child
        else
          const SizedBox.shrink(),
    ],
  );
}

/// {@template home_shell}
/// The frame around the main screens: the current tab and a navigation bar.
/// {@endtemplate}
class HomeShell extends StatelessWidget {
  /// {@macro home_shell}
  const new({required this.navigationShell, super.key});

  /// The router's state for the tabs.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            // Tapping the shown tab goes back to its first screen.
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l10n.homeTodayTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.homeHistoryTab,
          ),
        ],
      ),
    );
  }
}
