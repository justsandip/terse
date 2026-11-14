import 'package:material_ui/material_ui.dart';
import 'package:terse/l10n/l10n.dart';

/// Placeholder for the capture screen, replaced when the screen is built.
class CapturePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(body: Center(child: Text(l10n.captureAppBarTitle)));
  }
}
