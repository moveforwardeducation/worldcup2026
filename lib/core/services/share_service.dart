import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/home/presentation/widgets/trophy.dart';
import '../constants/app_links.dart';
import '../widgets/soccer_ball.dart';

/// Shares the app with a generated, branded promo **banner image** plus an
/// attractive message. The banner reuses the same Home-screen artwork (trophy,
/// soccer ball, confetti, "Football Champions 2026" wordmark). Falls back to
/// text-only sharing if the image can't be rendered.
class ShareService {
  ShareService._();

  static Future<void> shareApp() async {
    try {
      final bytes = await _renderBanner();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/fc2026_share.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(ShareParams(
        text: AppLinks.shareMessage,
        files: [XFile(file.path, mimeType: 'image/png')],
        subject: '${AppLinks.appName} — play free!',
      ));
    } catch (_) {
      await SharePlus.instance.share(ShareParams(text: AppLinks.shareMessage));
    }
  }

  // ---- Banner rendering (1080×1080 square, social-friendly) ----

  static Future<Uint8List> _renderBanner() async {
    const size = Size(1080, 1080);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Offset.zero & size);
    final full = Offset.zero & size;

    // Background gradient (app navy theme).
    canvas.drawRect(
      full,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF15265C), Color(0xFF0E1B3D), Color(0xFF0A1230)],
          stops: [0.0, 0.45, 1.0],
        ).createShader(full),
    );

    _drawConfetti(canvas);

    // Trophy, upper-right — reuses the Home-screen painter.
    canvas.save();
    canvas.translate(640, 70);
    TrophyPainter().paint(canvas, const Size(360, 360 * 1.12));
    canvas.restore();

    // Wordmark, left (mirrors the Home hero).
    _text(canvas,
        text: 'FOOTBALL',
        left: 90,
        top: 165,
        fontSize: 34,
        weight: FontWeight.w800,
        color: const Color(0xFFB8C2DC),
        letterSpacing: 8);
    _text(canvas,
        text: 'CHAMPIONS',
        left: 88,
        top: 205,
        fontSize: 78,
        weight: FontWeight.w900,
        color: const Color(0xFFF8FAFC));
    _text(canvas,
        text: '2026',
        left: 88,
        top: 290,
        fontSize: 124,
        weight: FontWeight.w900,
        color: const Color(0xFFFBBF24),
        glow: const Color(0x66FBBF24));

    // Soccer ball near the wordmark — reuses the Home-screen painter.
    canvas.save();
    canvas.translate(430, 470);
    SoccerBallPainter().paint(canvas, const Size(150, 150));
    canvas.restore();

    // Tagline row.
    _centered(canvas,
        text: '⚽ Learn    🎯 Predict    ⚔️ Battle    🏆 Win',
        width: size.width,
        centerY: 720,
        fontSize: 38,
        weight: FontWeight.w700,
        color: const Color(0xFFB8C2DC));

    // Call-to-action pill.
    final pill = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(540, 870), width: 620, height: 104),
      const Radius.circular(52),
    );
    canvas.drawRRect(
      pill,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF15803D)],
        ).createShader(pill.outerRect),
    );
    _centered(canvas,
        text: 'Play FREE on Google Play',
        width: size.width,
        centerY: 870,
        fontSize: 42,
        weight: FontWeight.w800,
        color: Colors.white);

    _centered(canvas,
        text: 'No sign-up needed · Learn · Predict · Collect',
        width: size.width,
        centerY: 970,
        fontSize: 28,
        weight: FontWeight.w600,
        color: const Color(0xFF7A88B0));

    final picture = recorder.endRecording();
    final img =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  /// Scattered static confetti specks across the top band.
  static void _drawConfetti(Canvas canvas) {
    const colors = [
      Color(0xFFFBBF24),
      Color(0xFF22C55E),
      Color(0xFF3B82F6),
      Color(0xFFEF4444),
      Color(0xFFF8FAFC),
    ];
    final rnd = math.Random(2026);
    for (var i = 0; i < 26; i++) {
      final x = 50 + rnd.nextDouble() * 980;
      final y = 30 + rnd.nextDouble() * 470;
      final angle = rnd.nextDouble() * math.pi;
      final w = 12 + rnd.nextDouble() * 10;
      final h = 18 + rnd.nextDouble() * 14;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(3),
        ),
        Paint()
          ..color = colors[i % colors.length].withValues(alpha: 0.55),
      );
      canvas.restore();
    }
  }

  static void _text(
    Canvas canvas, {
    required String text,
    required double left,
    required double top,
    required double fontSize,
    required FontWeight weight,
    required Color color,
    double letterSpacing = 0.5,
    Color? glow,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
          letterSpacing: letterSpacing,
          shadows: glow == null
              ? null
              : [Shadow(color: glow, blurRadius: 22)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(left, top));
  }

  static void _centered(
    Canvas canvas, {
    required String text,
    required double width,
    required double centerY,
    required double fontSize,
    required FontWeight weight,
    required Color color,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 80);
    tp.paint(canvas, Offset((width - tp.width) / 2, centerY - tp.height / 2));
  }
}
