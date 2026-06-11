import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Scattered confetti drawn behind the hero. Deterministic (fixed seed) so the
/// layout is stable across rebuilds.
class Confetti extends StatelessWidget {
  const Confetti({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ConfettiPainter(), size: Size.infinite);
  }
}

class _ConfettiPainter extends CustomPainter {
  static const _colors = [
    Color(0xFF22C55E),
    Color(0xFFFBBF24),
    Color(0xFF3B82F6),
    Color(0xFFEF4444),
    Color(0xFFFFFFFF),
    Color(0xFFA855F7),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    const count = 38;
    for (var i = 0; i < count; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final color = _colors[rnd.nextInt(_colors.length)]
          .withValues(alpha: 0.65 + rnd.nextDouble() * 0.35);
      final paint = Paint()..color = color;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(rnd.nextDouble() * math.pi);

      if (rnd.nextBool()) {
        final s = 3.0 + rnd.nextDouble() * 5;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: s, height: s * 1.8),
            const Radius.circular(1.5),
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, 1.5 + rnd.nextDouble() * 2.5, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
