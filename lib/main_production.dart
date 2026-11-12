import 'package:terse/app/app.dart';
import 'package:terse/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
