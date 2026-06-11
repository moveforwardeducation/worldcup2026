import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'data/seed/user_state_seeder.dart';

Future<void> main() async {
  await bootstrap();

  // First-launch welcome (grants one pack). The real profile is created
  // during onboarding — new users start fresh at Level 1.
  await UserStateSeeder().ensureSeeded();

  // Lock to portrait — this is a phone app.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF16234A),
  ));

  runApp(
    const ProviderScope(child: RoadToWC2026App()),
  );
}
