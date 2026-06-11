import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../data/remote/firebase_providers.dart';
import 'router.dart';

class RoadToWC2026App extends ConsumerStatefulWidget {
  const RoadToWC2026App({super.key});

  @override
  ConsumerState<RoadToWC2026App> createState() => _RoadToWC2026AppState();
}

class _RoadToWC2026AppState extends ConsumerState<RoadToWC2026App> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    // Kick off anonymous sign-in early (no-op when offline).
    ref.watch(authUidProvider);
    return MaterialApp.router(
      title: 'Football Champions 2026',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: _router,
    );
  }
}
