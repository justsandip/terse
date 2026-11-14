import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/app/router/router.dart';
import 'package:terse/capture/capture.dart';
import 'package:terse/setup/setup.dart';

void main() {
  group(AppRouter, () {
    late AppRouter appRouter;

    setUp(() {
      appRouter = AppRouter();
    });

    tearDown(() {
      appRouter.dispose();
    });

    Future<void> pumpRouter(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: appRouter.router),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('starts on CapturePage', (tester) async {
      await pumpRouter(tester);

      expect(find.byType(CapturePage), findsOneWidget);
    });

    testWidgets('navigates to SetupPage by name', (tester) async {
      await pumpRouter(tester);

      appRouter.router.goNamed(RouteNames.setup);
      await tester.pumpAndSettle();

      expect(find.byType(SetupPage), findsOneWidget);
    });

    testWidgets('navigates back to CapturePage by name', (tester) async {
      await pumpRouter(tester);

      appRouter.router.goNamed(RouteNames.setup);
      await tester.pumpAndSettle();
      appRouter.router.goNamed(RouteNames.capture);
      await tester.pumpAndSettle();

      expect(find.byType(CapturePage), findsOneWidget);
    });
  });
}
