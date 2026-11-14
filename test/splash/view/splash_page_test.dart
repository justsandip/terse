import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/splash/splash.dart';

void main() {
  group('SplashPage', () {
    testWidgets('renders an empty scaffold', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
