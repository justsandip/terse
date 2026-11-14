import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/setup/setup.dart';

void main() {
  group('SetupPage', () {
    testWidgets('renders its placeholder', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SetupPage()));
      expect(find.text('Setup'), findsOneWidget);
    });
  });
}
