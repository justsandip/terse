import 'package:material_ui/material_ui.dart';

/// How a [CaptureToken] looks.
enum TokenState {
  /// Not chosen.
  idle,

  /// A suggestion, shown faded with a dashed outline. Not saved.
  ghost,

  /// The chosen option of a scale, a choice or a yes or no.
  selected,

  /// A confirmed number.
  confirmed,
}

/// {@template capture_token}
/// A tappable pill or circle that shows one value or option.
///
/// It is at least 44 by 44, so it is easy to hit.
/// {@endtemplate}
class CaptureToken extends StatelessWidget {
  /// {@macro capture_token}
  const new({
    required this.label,
    required this.state,
    required this.onTap,
    this.circle = false,
    this.minWidth = 44,
    this.semanticsLabel,
    super.key,
  });

  static const double _size = 44;

  final String label;
  final TokenState state;
  final VoidCallback onTap;

  /// Whether the token is a circle, like a dot on a scale.
  final bool circle;

  /// The narrowest a pill is allowed to be.
  final double minWidth;

  /// What a screen reader says instead of [label].
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelMedium;
    final (Color? fill, Color foreground, Color? border) = switch (state) {
      TokenState.idle => (
        scheme.surfaceContainer,
        scheme.onSurface,
        scheme.outline,
      ),
      TokenState.ghost => (null, scheme.primary, null),
      TokenState.selected => (scheme.primary, scheme.onPrimary, null),
      TokenState.confirmed => (
        scheme.surfaceContainerHighest,
        scheme.onSurface,
        null,
      ),
    };
    final shape = circle
        ? const CircleBorder()
        : const StadiumBorder();

    Widget content = Container(
      constraints: circle
          ? const BoxConstraints.tightFor(width: _size, height: _size)
          : BoxConstraints(minWidth: minWidth, minHeight: _size),
      padding: circle
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16),
      decoration: ShapeDecoration(
        color: fill,
        shape: border == null
            ? shape
            : (circle
                  ? CircleBorder(side: BorderSide(color: border))
                  : StadiumBorder(side: BorderSide(color: border))),
      ),
      // Center, not Container.alignment: an aligned Container grows to the
      // widest width its parent allows, which made pills fill a whole row.
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(label, style: style?.copyWith(color: foreground)),
      ),
    );

    if (state == TokenState.ghost) {
      content = CustomPaint(
        foregroundPainter: DashedBorderPainter(color: foreground),
        child: content,
      );
    }

    return Semantics(
      button: true,
      selected: state == TokenState.selected || state == TokenState.confirmed,
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: content,
      ),
    );
  }
}

/// Paints a dashed outline that follows a pill or a circle.
class DashedBorderPainter extends CustomPainter {
  /// Creates a [DashedBorderPainter].
  const new({required this.color});

  /// The color of the dashes.
  final Color color;

  static const double _dash = 4;
  static const double _gap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final inset = paint.strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - paint.strokeWidth,
      size.height - paint.strokeWidth,
    );
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(rect.shortestSide / 2)),
      );
    for (final metric in path.computeMetrics()) {
      for (var at = 0.0; at < metric.length; at += _dash + _gap) {
        canvas.drawPath(metric.extractPath(at, at + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
