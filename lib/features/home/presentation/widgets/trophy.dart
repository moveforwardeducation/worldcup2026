import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A vector golden trophy with glow and sparkles — drawn, not a bitmap.
class Trophy extends StatelessWidget {
  const Trophy({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.12,
      child: CustomPaint(painter: _TrophyPainter()),
    );
  }
}

class _TrophyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    double x(double p) => w * p;
    double y(double p) => h * p;

    // Warm glow behind the trophy.
    canvas.drawCircle(
      Offset(x(0.5), y(0.34)),
      w * 0.46,
      Paint()
        ..color = const Color(0xFFFBBF24).withValues(alpha: 0.30)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.16),
    );

    final goldFill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFEF3C7), Color(0xFFFBBF24), Color(0xFFB45309)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final darkGold = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF59E0B), Color(0xFF92400E)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final handleStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFFCD34D), Color(0xFFB45309)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Handles (behind the bowl).
    final leftHandle = Path()
      ..moveTo(x(0.20), y(0.10))
      ..cubicTo(x(-0.04), y(0.12), x(-0.02), y(0.42), x(0.26), y(0.40));
    final rightHandle = Path()
      ..moveTo(x(0.80), y(0.10))
      ..cubicTo(x(1.04), y(0.12), x(1.02), y(0.42), x(0.74), y(0.40));
    canvas.drawPath(leftHandle, handleStroke);
    canvas.drawPath(rightHandle, handleStroke);

    // Bowl.
    final bowl = Path()
      ..moveTo(x(0.18), y(0.08))
      ..quadraticBezierTo(x(0.50), y(0.16), x(0.82), y(0.08))
      ..cubicTo(x(0.84), y(0.34), x(0.68), y(0.48), x(0.58), y(0.50))
      ..lineTo(x(0.42), y(0.50))
      ..cubicTo(x(0.32), y(0.48), x(0.16), y(0.34), x(0.18), y(0.08))
      ..close();
    canvas.drawPath(bowl, goldFill);

    // Stem.
    final stem = Path()
      ..moveTo(x(0.45), y(0.50))
      ..lineTo(x(0.55), y(0.50))
      ..lineTo(x(0.535), y(0.63))
      ..lineTo(x(0.465), y(0.63))
      ..close();
    canvas.drawPath(stem, darkGold);

    // Base cone.
    final baseCone = Path()
      ..moveTo(x(0.40), y(0.63))
      ..lineTo(x(0.60), y(0.63))
      ..lineTo(x(0.64), y(0.74))
      ..lineTo(x(0.36), y(0.74))
      ..close();
    canvas.drawPath(baseCone, goldFill);

    // Plinth.
    final plinth = RRect.fromRectAndRadius(
      Rect.fromLTRB(x(0.28), y(0.74), x(0.72), y(0.88)),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(plinth, darkGold);

    // Rim accent across the top of the bowl.
    canvas.drawPath(
      Path()
        ..moveTo(x(0.18), y(0.08))
        ..quadraticBezierTo(x(0.50), y(0.16), x(0.82), y(0.08)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035
        ..color = const Color(0xFFFEF9C3).withValues(alpha: 0.9),
    );

    // Vertical shine streak on the bowl.
    canvas.drawPath(
      Path()
        ..moveTo(x(0.34), y(0.14))
        ..cubicTo(x(0.30), y(0.30), x(0.36), y(0.40), x(0.40), y(0.46))
        ..lineTo(x(0.46), y(0.46))
        ..cubicTo(x(0.40), y(0.36), x(0.40), y(0.24), x(0.44), y(0.14))
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.30),
    );

    _sparkle(canvas, Offset(x(0.86), y(0.04)), w * 0.07);
    _sparkle(canvas, Offset(x(0.10), y(0.30)), w * 0.05);
    _sparkle(canvas, Offset(x(0.74), y(0.46)), w * 0.04);
  }

  void _sparkle(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.95);
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = i * (math.pi / 2);
      final tip = c + Offset(math.cos(a), math.sin(a)) * r;
      final side1 = c + Offset(math.cos(a + 0.4), math.sin(a + 0.4)) * r * 0.28;
      final side2 = c + Offset(math.cos(a - 0.4), math.sin(a - 0.4)) * r * 0.28;
      if (i == 0) path.moveTo(side2.dx, side2.dy);
      path
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(side1.dx, side1.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
