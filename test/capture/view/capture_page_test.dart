import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/capture/capture.dart';

void main() {
  group('CapturePage', () {
    testWidgets('renders its placeholder', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CapturePage()));
      expect(find.text('Capture'), findsOneWidget);
    });
  });
}
