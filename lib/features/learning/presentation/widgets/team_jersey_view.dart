import 'package:flutter/material.dart';

import '../../../../data/models/team_jersey.dart';

/// Renders a data-driven football jersey with a 3D / mobile-game look:
/// shaded body, fabric folds, gloss sheen, collar, sleeve trim, patterns
/// (stripes / checker / sash / halves / hoops), a crest and a sponsor block.
class JerseyView extends StatelessWidget {
  const JerseyView({
    super.key,
    required this.spec,
    this.size = 200,
    this.panel = true,
  });

  final TeamJersey spec;
  final double size;

  /// Wrap the jersey in a light "kit display" card so dark *and* light kits
  /// stay clearly visible, with the jersey casting a soft 3D shadow on it.
  final bool panel;

  @override
  Widget build(BuildContext context) {
    final jersey = SizedBox(
      width: size,
      height: size * 1.12,
      child: CustomPaint(painter: _JerseyPainter(spec)),
    );
    if (!panel) return jersey;
    return Container(
      padding: EdgeInsets.all(size * 0.11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF6F8FC), Color(0xFFDBE2F0)],
        ),
        borderRadius: BorderRadius.circular(size * 0.16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: jersey,
    );
  }
}

class _JerseyPainter extends CustomPainter {
  _JerseyPainter(this.spec);
  final TeamJersey spec;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset p(double dx, double dy) => Offset(w * dx, h * dy);

    final body = Color(spec.body);
    final collar = Color(spec.collar);
    final trim = Color(spec.sleeveTrim);
    final patternColor = Color(spec.patternColor);

    // Soft 3D drop shadow beneath the jersey (offset down).
    canvas.save();
    canvas.translate(0, h * 0.02);
    canvas.drawPath(
      _bodyPath(p),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.05)
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    final path = _bodyPath(p);
    canvas.save();
    canvas.clipPath(path);

    // 1. Base fabric (subtle vertical gradient for top-lit look).
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_lighten(body, 0.10), body, _darken(body, 0.10)],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // 2. Team pattern.
    _drawPattern(canvas, w, h, patternColor);

    // 3. Shading for 3D roundness.
    _drawShading(canvas, w, h);

    canvas.restore();

    // 4. Shoulder panels (only if distinct from body).
    if (spec.shoulderPanels != spec.body) {
      final panel = Paint()..color = Color(spec.shoulderPanels);
      canvas.save();
      canvas.clipPath(path);
      canvas.drawPath(
        Path()
          ..moveTo(p(0.22, 0.12).dx, p(0.22, 0.12).dy)
          ..lineTo(p(0.40, 0.12).dx, p(0.40, 0.12).dy)
          ..lineTo(p(0.36, 0.30).dx, p(0.36, 0.30).dy)
          ..lineTo(p(0.24, 0.30).dx, p(0.24, 0.30).dy)
          ..close(),
        panel,
      );
      canvas.drawPath(
        Path()
          ..moveTo(p(0.78, 0.12).dx, p(0.78, 0.12).dy)
          ..lineTo(p(0.60, 0.12).dx, p(0.60, 0.12).dy)
          ..lineTo(p(0.64, 0.30).dx, p(0.64, 0.30).dy)
          ..lineTo(p(0.76, 0.30).dx, p(0.76, 0.30).dy)
          ..close(),
        panel,
      );
      canvas.restore();
    }

    // 5. Sleeve cuffs (trim).
    final cuff = Paint()
      ..color = trim
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(0.04, 0.27), p(0.15, 0.43), cuff);
    canvas.drawLine(p(0.96, 0.27), p(0.85, 0.43), cuff);

    // 6. Collar (round neck band) + inner highlight.
    final neck = Path()
      ..moveTo(p(0.40, 0.12).dx, p(0.40, 0.12).dy)
      ..quadraticBezierTo(
          p(0.50, 0.25).dx, p(0.50, 0.25).dy, p(0.60, 0.12).dx, p(0.60, 0.12).dy);
    canvas.drawPath(
      neck,
      Paint()
        ..color = collar
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.05
        ..strokeCap = StrokeCap.round,
    );

    // 7. Crest + sponsor block (neutral kit decoration).
    _drawCrest(canvas, p, w);

    // 8. Outline for definition (crisp edge on any background).
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.014,
    );
  }

  // ---- Pattern ----
  void _drawPattern(Canvas canvas, double w, double h, Color color) {
    switch (spec.pattern) {
      case JerseyPattern.solid:
        return;
      case JerseyPattern.stripes:
        final bw = w * 0.09;
        final paint = Paint()..color = color;
        for (var x = bw; x < w; x += bw * 2) {
          canvas.drawRect(Rect.fromLTWH(x, 0, bw, h), paint);
        }
      case JerseyPattern.hoops:
        final bh = h * 0.09;
        final paint = Paint()..color = color;
        for (var y = bh; y < h; y += bh * 2) {
          canvas.drawRect(Rect.fromLTWH(0, y, w, bh), paint);
        }
      case JerseyPattern.halves:
        canvas.drawRect(
            Rect.fromLTWH(0, h * 0.5, w, h * 0.5), Paint()..color = color);
      case JerseyPattern.sash:
        final paint = Paint()..color = color;
        canvas.drawPath(
          Path()
            ..moveTo(0, h * 0.30)
            ..lineTo(w * 0.20, h * 0.16)
            ..lineTo(w, h * 0.78)
            ..lineTo(w * 0.80, h * 0.92)
            ..close(),
          paint,
        );
      case JerseyPattern.checker:
        final s = w * 0.11;
        final paint = Paint()..color = color;
        for (var row = 0; row * s < h; row++) {
          for (var col = 0; col * s < w; col++) {
            if ((row + col).isEven) {
              canvas.drawRect(Rect.fromLTWH(col * s, row * s, s, s), paint);
            }
          }
        }
    }
  }

  // ---- 3D shading overlays ----
  void _drawShading(Canvas canvas, double w, double h) {
    final rect = Rect.fromLTWH(0, 0, w, h);
    // Left edge shadow.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.center,
          colors: [Colors.black.withValues(alpha: 0.28), Colors.transparent],
        ).createShader(rect),
    );
    // Right edge shadow.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.center,
          colors: [Colors.black.withValues(alpha: 0.28), Colors.transparent],
        ).createShader(rect),
    );
    // Centre chest sheen.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.5),
          radius: 0.9,
          colors: [Colors.white.withValues(alpha: 0.18), Colors.transparent],
        ).createShader(rect),
    );
    // A couple of soft fabric folds.
    final fold = Paint()
      ..color = Colors.black.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.01);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.30, h * 0.30)
        ..quadraticBezierTo(w * 0.34, h * 0.6, w * 0.30, h * 0.9),
      fold,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.70, h * 0.30)
        ..quadraticBezierTo(w * 0.66, h * 0.6, w * 0.70, h * 0.9),
      fold,
    );
  }

  void _drawCrest(Canvas canvas, Offset Function(double, double) p, double w) {
    // Small shield crest on the right chest.
    final c = p(0.62, 0.30);
    final sw = w * 0.10;
    final shield = Path()
      ..moveTo(c.dx - sw / 2, c.dy - sw * 0.55)
      ..lineTo(c.dx + sw / 2, c.dy - sw * 0.55)
      ..lineTo(c.dx + sw / 2, c.dy + sw * 0.15)
      ..quadraticBezierTo(
          c.dx, c.dy + sw * 0.85, c.dx - sw / 2, c.dy + sw * 0.15)
      ..close();
    canvas.drawPath(shield, Paint()..color = Colors.white.withValues(alpha: 0.85));
    canvas.drawPath(
      shield,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.006,
    );
    // Sponsor block centre.
    final block = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: p(0.50, 0.46), width: w * 0.22, height: w * 0.07),
      Radius.circular(w * 0.015),
    );
    canvas.drawRRect(block, Paint()..color = Colors.white.withValues(alpha: 0.7));
  }

  // ---- Silhouette ----
  Path _bodyPath(Offset Function(double, double) p) => Path()
    ..moveTo(p(0.22, 0.12).dx, p(0.22, 0.12).dy)
    ..lineTo(p(0.40, 0.12).dx, p(0.40, 0.12).dy)
    ..quadraticBezierTo(
        p(0.50, 0.24).dx, p(0.50, 0.24).dy, p(0.60, 0.12).dx, p(0.60, 0.12).dy)
    ..lineTo(p(0.78, 0.12).dx, p(0.78, 0.12).dy)
    ..lineTo(p(0.98, 0.26).dx, p(0.98, 0.26).dy)
    ..lineTo(p(0.86, 0.44).dx, p(0.86, 0.44).dy)
    ..lineTo(p(0.76, 0.36).dx, p(0.76, 0.36).dy)
    ..lineTo(p(0.80, 0.94).dx, p(0.80, 0.94).dy)
    ..lineTo(p(0.20, 0.94).dx, p(0.20, 0.94).dy)
    ..lineTo(p(0.24, 0.36).dx, p(0.24, 0.36).dy)
    ..lineTo(p(0.14, 0.44).dx, p(0.14, 0.44).dy)
    ..lineTo(p(0.02, 0.26).dx, p(0.02, 0.26).dy)
    ..close();

  Color _lighten(Color c, double a) => Color.lerp(c, Colors.white, a) ?? c;
  Color _darken(Color c, double a) => Color.lerp(c, Colors.black, a) ?? c;

  @override
  bool shouldRepaint(covariant _JerseyPainter old) =>
      old.spec.body != spec.body ||
      old.spec.pattern != spec.pattern ||
      old.spec.collar != spec.collar ||
      old.spec.patternColor != spec.patternColor;
}
