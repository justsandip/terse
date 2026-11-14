import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:terse/layout/layout.dart';
import 'package:terse/theme/theme.dart';

void main() {
  group(ContentFrame, () {
    const childKey = Key('child');

    Future<void> pumpFrame(
      WidgetTester tester, {
      required double windowWidth,
    }) async {
      tester.view
        ..physicalSize = Size(windowWidth, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ContentFrame(child: Container(key: childKey, height: 50)),
          ),
        ),
      );
    }

    testWidgets('renders its child', (tester) async {
      await pumpFrame(tester, windowWidth: 400);

      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('only adds side padding on a narrow window', (tester) async {
      await pumpFrame(tester, windowWidth: 400);

      final size = tester.getSize(find.byKey(childKey));

      expect(size.width, equals(400 - 2 * TerseSpacing.lg));
    });

    testWidgets('caps the width and centers on a wide window', (tester) async {
      await pumpFrame(tester, windowWidth: 1000);

      final size = tester.getSize(find.byKey(childKey));
      final center = tester.getCenter(find.byKey(childKey));

      expect(size.width, equals(ContentFrame.maxWidth - 2 * TerseSpacing.lg));
      expect(center.dx, equals(500));
    });
  });
}
