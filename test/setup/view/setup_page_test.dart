import 'package:flutter_test/flutter_test.dart';
import 'package:terse/setup/setup.dart';

import '../../helpers/helpers.dart';

void main() {
  group('SetupPage', () {
    testWidgets('renders its placeholder', (tester) async {
      await tester.pumpApp(const SetupPage());
      expect(find.text('Setup'), findsOneWidget);
    });
  });
}
