import 'package:material_ui/material_ui.dart';
import 'package:terse/theme/theme.dart';

/// {@template content_frame}
/// Keeps [child] in a centered column no wider than [maxWidth], with the
/// horizontal padding of a screen.
/// {@endtemplate}
class ContentFrame extends StatelessWidget {
  /// {@macro content_frame}
  const new({required this.child, super.key});

  /// The widest the frame, padding included, is allowed to get.
  static const double maxWidth = 600;

  /// The content of the screen.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TerseSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}
