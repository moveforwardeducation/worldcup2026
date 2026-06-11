import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A friendly flat-style mascot: a young fan holding the World Cup aloft.
/// Drawn with CustomPainter so it ships with zero image assets.
class JourneyMascot extends StatelessWidget {
  const JourneyMascot({super.key, this.size = 104});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.12,
      child: CustomPaint(painter: _MascotPainter()),
    );
  }
}

class _MascotPainter extends CustomPainter {
  static const _skin = Color(0xFFF3B98E);
  static const _skinShade = Color(0xFFE3A472);
  static const _hair = Color(0xFF3F2817);
  static const _jacket = Color(0xFF12245A);
  static const _jacketDark = Color(0xFF0C173B);
  static const _strap = Color(0xFFF59E0B);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset o(double x, double y) => Offset(w * x, h * y);

    // ---- Body / jacket ----
    final body = Path()
      ..moveTo(w * 0.27, h * 0.64)
      ..quadraticBezierTo(w * 0.5, h * 0.56, w * 0.73, h * 0.64)
      ..lineTo(w * 0.80, h * 1.0)
      ..lineTo(w * 0.20, h * 1.0)
      ..close();
    canvas.drawPath(body, Paint()..color = _jacket);
    // Zipper.
    canvas.drawLine(
      o(0.5, 0.60),
      o(0.5, 1.0),
      Paint()
        ..color = _jacketDark
        ..strokeWidth = w * 0.02,
    );
    // Backpack straps.
    final strapPaint = Paint()
      ..color = _strap
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(o(0.40, 0.62), o(0.43, 0.97), strapPaint);
    canvas.drawLine(o(0.60, 0.62), o(0.57, 0.97), strapPaint);

    // ---- Arms raised toward the trophy ----
    final armPaint = Paint()
      ..color = _skin
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.095
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(o(0.33, 0.66), o(0.42, 0.33), armPaint);
    canvas.drawLine(o(0.67, 0.66), o(0.58, 0.33), armPaint);

    // ---- Head ----
    final headC = o(0.5, 0.44);
    final headR = w * 0.155;
    // Ears.
    canvas.drawCircle(o(0.355, 0.45), w * 0.028, Paint()..color = _skin);
    canvas.drawCircle(o(0.645, 0.45), w * 0.028, Paint()..color = _skin);
    canvas.drawCircle(headC, headR, Paint()..color = _skin);
    // Hair (top cap of the head).
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: headC, radius: headR)));
    final hairPath = Path()
      ..moveTo(headC.dx - headR, headC.dy)
      ..lineTo(headC.dx - headR, headC.dy - headR)
      ..lineTo(headC.dx + headR, headC.dy - headR)
      ..lineTo(headC.dx + headR, headC.dy)
      ..quadraticBezierTo(headC.dx + headR * 0.4, headC.dy - headR * 0.35,
          headC.dx, headC.dy - headR * 0.05)
      ..quadraticBezierTo(headC.dx - headR * 0.4, headC.dy - headR * 0.35,
          headC.dx - headR, headC.dy)
      ..close();
    canvas.drawPath(hairPath, Paint()..color = _hair);
    canvas.restore();

    // Face.
    final eye = Paint()..color = const Color(0xFF2A1A0F);
    canvas.drawCircle(o(0.45, 0.45), w * 0.017, eye);
    canvas.drawCircle(o(0.55, 0.45), w * 0.017, eye);
    // Rosy cheeks.
    final cheek = Paint()..color = const Color(0x33D9534F);
    canvas.drawCircle(o(0.43, 0.50), w * 0.025, cheek);
    canvas.drawCircle(o(0.57, 0.50), w * 0.025, cheek);
    // Smile.
    final smile = Path()
      ..addArc(
        Rect.fromCircle(center: o(0.5, 0.48), radius: w * 0.05),
        0.15 * math.pi,
        0.7 * math.pi,
      );
    canvas.drawPath(
      smile,
      Paint()
        ..color = const Color(0xFF8B4A2F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.013
        ..strokeCap = StrokeCap.round,
    );

    // ---- Trophy held aloft ----
    _trophy(canvas, Rect.fromLTWH(w * 0.35, h * 0.0, w * 0.30, h * 0.30));

    // Hands gripping the trophy base.
    canvas.drawCircle(o(0.43, 0.31), w * 0.046, Paint()..color = _skinShade);
    canvas.drawCircle(o(0.57, 0.31), w * 0.046, Paint()..color = _skinShade);
  }

  void _trophy(Canvas canvas, Rect r) {
    double x(double p) => r.left + r.width * p;
    double y(double p) => r.top + r.height * p;

    // Glow.
    canvas.drawCircle(
      Offset(x(0.5), y(0.38)),
      r.width * 0.55,
      Paint()
        ..color = const Color(0xFFFBBF24).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    final gold = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFEF3C7), Color(0xFFFBBF24), Color(0xFFB45309)],
      ).createShader(r);
    final handle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r.width * 0.07
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE0A106);

    canvas.drawPath(
      Path()
        ..moveTo(x(0.20), y(0.12))
        ..cubicTo(x(0.0), y(0.14), x(0.02), y(0.42), x(0.26), y(0.44)),
      handle,
    );
    canvas.drawPath(
      Path()
        ..moveTo(x(0.80), y(0.12))
        ..cubicTo(x(1.0), y(0.14), x(0.98), y(0.42), x(0.74), y(0.44)),
      handle,
    );

    final bowl = Path()
      ..moveTo(x(0.18), y(0.10))
      ..quadraticBezierTo(x(0.5), y(0.22), x(0.82), y(0.10))
      ..cubicTo(x(0.84), y(0.46), x(0.64), y(0.62), x(0.5), y(0.64))
      ..cubicTo(x(0.36), y(0.62), x(0.16), y(0.46), x(0.18), y(0.10))
      ..close();
    canvas.drawPath(bowl, gold);

    // Stem + base.
    canvas.drawRect(
        Rect.fromLTWH(x(0.43), y(0.62), r.width * 0.14, r.height * 0.16), gold);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x(0.28), y(0.78), r.width * 0.44, r.height * 0.18),
        Radius.circular(r.width * 0.05),
      ),
      gold,
    );
    // Shine.
    canvas.drawPath(
      Path()
        ..moveTo(x(0.34), y(0.16))
        ..cubicTo(x(0.30), y(0.34), x(0.38), y(0.5), x(0.44), y(0.56))
        ..lineTo(x(0.49), y(0.56))
        ..cubicTo(x(0.42), y(0.44), x(0.42), y(0.28), x(0.45), y(0.16))
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.30),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
