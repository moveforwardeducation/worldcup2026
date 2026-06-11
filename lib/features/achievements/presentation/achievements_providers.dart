import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/stats_repository.dart';
import '../../../data/models/achievement.dart';
import '../../../data/providers.dart';
import '../../collection/presentation/collection_providers.dart';

/// Builds the achievement list with live progress derived from real state.
final achievementsProvider = Provider<List<Achievement>>((ref) {
  final stats = ref.watch(statsProvider);
  final unlocked = ref.watch(unlockedCardsProvider);
  final streak = ref.watch(streakProvider);
  final xp = ref.watch(xpProvider);

  final teamCards = unlocked.where((id) => id.startsWith('team_')).length;
  final totalCards = unlocked.length;

  return [
    Achievement(
      id: 'first_steps',
      title: 'First Steps',
      description: 'Complete your first lesson',
      icon: Icons.directions_walk_rounded,
      target: 1,
      current: stats.lessonsCompleted,
      rewardXp: 50,
      rewardCoins: 20,
    ),
    Achievement(
      id: 'team_collector',
      title: 'Team Collector',
      description: 'Collect 10 team cards',
      icon: Icons.flag_rounded,
      target: 10,
      current: teamCards,
      rewardXp: 100,
      rewardCoins: 50,
    ),
    Achievement(
      id: 'collector',
      title: 'Collector',
      description: 'Collect 10 cards of any type',
      icon: Icons.style_rounded,
      target: 10,
      current: totalCards,
      rewardXp: 100,
      rewardCoins: 50,
    ),
    Achievement(
      id: 'sharp_shooter',
      title: 'Sharp Shooter',
      description: 'Answer 100 questions correctly',
      icon: Icons.gps_fixed_rounded,
      target: 100,
      current: stats.totalCorrect,
      rewardXp: 150,
      rewardCoins: 75,
    ),
    Achievement(
      id: 'predictor',
      title: 'Predictor',
      description: 'Make 20 correct predictions',
      icon: Icons.online_prediction_rounded,
      target: 20,
      current: stats.predictionsCorrect,
      rewardXp: 200,
      rewardCoins: 100,
    ),
    Achievement(
      id: 'streak_master',
      title: 'Streak Master',
      description: 'Maintain a 14 day streak',
      icon: Icons.local_fire_department_rounded,
      target: 14,
      current: streak.best,
      rewardXp: 200,
      rewardCoins: 100,
    ),
    Achievement(
      id: 'wc_expert',
      title: 'Football Legend',
      description: 'Reach Level 50',
      icon: Icons.workspace_premium_rounded,
      target: 50,
      current: xp.level,
      rewardXp: 500,
      rewardCoins: 250,
    ),
  ];
});

final unlockedAchievementsCountProvider = Provider<int>((ref) {
  return ref.watch(achievementsProvider).where((a) => a.unlocked).length;
});
