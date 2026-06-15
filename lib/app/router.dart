import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/collectible_card.dart';
import '../data/models/lesson.dart';
import '../features/achievements/presentation/achievements_screen.dart';
import '../features/battle/presentation/battle_match_screen.dart';
import '../features/battle/presentation/battle_result_screen.dart';
import '../features/battle/presentation/battle_screen.dart';
import '../features/collection/presentation/card_detail_screen.dart';
import '../features/collection/presentation/collection_screen.dart';
import '../features/fan_club/presentation/club_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/journey/presentation/journey_screen.dart';
import '../features/journey/presentation/stage_lessons_screen.dart';
import '../features/learning/presentation/lesson_result_screen.dart';
import '../features/learning/presentation/lesson_screen.dart';
import '../features/onboarding/presentation/onboarding_providers.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/packs/presentation/pack_open_screen.dart';
import '../features/packs/presentation/packs_screen.dart';
import '../features/predictions/presentation/predictions_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/schedule/presentation/schedule_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/standings/presentation/standings_screen.dart';
import 'nav_shell.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey(debugLabel: 'root');

GoRouter buildRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final done = readOnboardingDone();
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!done && !atOnboarding) return '/onboarding';
      if (done && atOnboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => NavShell(navigationShell: shell),
        branches: [
          _branch('/home', const HomeScreen()),
          _branch('/journey', const JourneyScreen()),
          _branch('/predict', const PredictionsScreen()),
          _branch('/battle', const BattleScreen()),
          _branch('/club', const ClubScreen()),
          _branch('/profile', const ProfileScreen()),
        ],
      ),
      // Full-screen routes above the bottom nav.
      GoRoute(
        path: '/stage/:index',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => StageLessonsScreen(
          stageIndex: int.tryParse(state.pathParameters['index'] ?? '0') ?? 0,
        ),
      ),
      GoRoute(
        path: '/lesson',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => LessonScreen(lesson: state.extra as Lesson),
      ),
      GoRoute(
        path: '/lesson-result',
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            LessonResultScreen(result: state.extra as LessonResult),
      ),
      GoRoute(
        path: '/collection',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const CollectionScreen(),
      ),
      GoRoute(
        path: '/collection/card',
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            CardDetailScreen(card: state.extra as CollectibleCard),
      ),
      GoRoute(
        path: '/packs',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const PacksScreen(),
      ),
      GoRoute(
        path: '/packs/open',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const PackOpenScreen(),
      ),
      GoRoute(
        path: '/achievements',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/schedule',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/standings',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const StandingsScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/battle/match',
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            BattleMatchScreen(opponent: state.extra as String),
      ),
      GoRoute(
        path: '/battle/result',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return BattleResultScreen(
            opponent: args['opponent'] as String,
            you: args['you'] as int,
            opp: args['opp'] as int,
          );
        },
      ),
    ],
  );
}

StatefulShellBranch _branch(String path, Widget child) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        pageBuilder: (_, state) => NoTransitionPage(child: child),
      ),
    ],
  );
}
