import 'package:flutter_test/flutter_test.dart';
import 'package:terse/capture/capture.dart';

import '../../helpers/helpers.dart';

void main() {
  group('CapturePage', () {
    testWidgets('renders its placeholder', (tester) async {
      await tester.pumpApp(const CapturePage());
      expect(find.text('Capture'), findsOneWidget);
    });
  });
}
