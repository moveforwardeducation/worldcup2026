import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A vector soccer ball drawn with CustomPainter — no bitmap asset needed.
/// Classic black-and-white panel look with a glossy highlight.
class SoccerBall extends StatelessWidget {
  const SoccerBall({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SoccerBallPainter()),
    );
  }
}

class _SoccerBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final rect = Rect.fromCircle(center: c, radius: r);

    // Soft drop shadow beneath the ball.
    canvas.drawCircle(
      c + Offset(0, r * 0.12),
      r * 0.96,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.18),
    );

    // Sphere base with a top-left highlight.
    final sphere = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.42),
        radius: 1.05,
        colors: const [
          Colors.white,
          Color(0xFFE6EAF2),
          Color(0xFFB4BFD6),
        ],
        stops: const [0.0, 0.58, 1.0],
      ).createShader(rect);
    canvas.drawCircle(c, r, sphere);

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    final black = Paint()..color = const Color(0xFF161B27);
    final seam = Paint()
      ..color = const Color(0xFF161B27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.055
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Central pentagon (pointing up).
    final central = _pentagon(c, r * 0.34, -math.pi / 2);
    canvas.drawPath(_poly(central), black);

    // Five outer pentagons sitting on each edge of the central one.
    const twoPi = 2 * math.pi;
    for (var i = 0; i < 5; i++) {
      final ang = -math.pi / 2 + (i + 0.5) * (twoPi / 5);
      final oc = c + Offset(math.cos(ang), math.sin(ang)) * r * 0.82;
      final outer = _pentagon(oc, r * 0.30, ang + math.pi);
      canvas.drawPath(_poly(outer), black);
    }

    // Seams radiating from the central pentagon's vertices.
    for (final v in central) {
      final end = c + (v - c) * 2.6;
      canvas.drawLine(v, end, seam);
    }
    canvas.restore();

    // Subtle rim to seat the ball against the background.
    canvas.drawCircle(
      c,
      r - r * 0.02,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.03
        ..color = const Color(0xFF8A97B5).withValues(alpha: 0.4),
    );

    // Glossy highlight.
    canvas.drawCircle(
      c + Offset(-r * 0.32, -r * 0.36),
      r * 0.22,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
    );
  }

  List<Offset> _pentagon(Offset c, double radius, double rot) =>
      List.generate(5, (i) {
        final a = rot + i * (2 * math.pi / 5);
        return c + Offset(math.cos(a), math.sin(a)) * radius;
      });

  Path _poly(List<Offset> pts) {
    final p = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final pt in pts.skip(1)) {
      p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
