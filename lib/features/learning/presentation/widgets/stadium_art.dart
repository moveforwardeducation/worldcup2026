import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A stylised stadium illustration. Deterministic per [seed] so each stadium
/// looks consistent (slightly different tint/floodlight arrangement).
class StadiumArt extends StatelessWidget {
  const StadiumArt({super.key, required this.seed, this.size = 240});

  final int seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.7,
      child: CustomPaint(painter: _StadiumPainter(seed)),
    );
  }
}

class _StadiumPainter extends CustomPainter {
  _StadiumPainter(this.seed);
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rnd = math.Random(seed);
    final hue = 200 + rnd.nextInt(80); // bluish stand tints

    final standOuter = HSLColor.fromAHSL(1, hue.toDouble(), 0.35, 0.30).toColor();
    final standInner = HSLColor.fromAHSL(1, hue.toDouble(), 0.30, 0.45).toColor();

    final center = Offset(w / 2, h * 0.62);
    final outer = Rect.fromCenter(center: center, width: w * 0.94, height: h * 0.78);
    final mid = Rect.fromCenter(center: center, width: w * 0.74, height: h * 0.58);
    final pitch = Rect.fromCenter(center: center, width: w * 0.52, height: h * 0.40);

    // Floodlights.
    for (final fx in [0.10, 0.90]) {
      final base = Offset(w * fx, h * 0.30);
      canvas.drawRect(
        Rect.fromCenter(center: base.translate(0, h * 0.16), width: w * 0.012, height: h * 0.34),
        Paint()..color = const Color(0xFF64748B),
      );
      final glow = Paint()
        ..color = const Color(0xFFFEF9C3).withValues(alpha: 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: base, width: w * 0.10, height: h * 0.05),
          const Radius.circular(3),
        ),
        glow,
      );
    }

    // Stand rings.
    canvas.drawOval(outer, Paint()..color = standOuter);
    canvas.drawOval(mid, Paint()..color = standInner);

    // Tiered seating hint.
    canvas.drawOval(
      mid,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012
        ..color = Colors.white.withValues(alpha: 0.15),
    );

    // Pitch.
    canvas.drawOval(
      pitch,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF15803D), Color(0xFF166534)],
        ).createShader(pitch),
    );

    // Mowing stripes.
    canvas.save();
    canvas.clipPath(Path()..addOval(pitch));
    for (var i = 0; i < 6; i++) {
      if (i.isOdd) continue;
      final stripe = Rect.fromLTWH(
        pitch.left + pitch.width / 6 * i,
        pitch.top,
        pitch.width / 6,
        pitch.height,
      );
      canvas.drawRect(stripe, Paint()..color = Colors.white.withValues(alpha: 0.06));
    }
    // Centre line + circle.
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.006;
    canvas.drawLine(
      Offset(center.dx, pitch.top),
      Offset(center.dx, pitch.bottom),
      line,
    );
    canvas.drawCircle(center, pitch.height * 0.18, line);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StadiumPainter old) => old.seed != seed;
}
