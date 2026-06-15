import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../constants/xp_rules.dart';

/// Outcome of awarding XP — used to trigger celebrations.
class AwardResult {
  const AwardResult({
    required this.xpGained,
    required this.leveledUp,
    required this.newLevel,
    required this.dailyGoalReached,
  });

  final int xpGained;
  final bool leveledUp;
  final int newLevel;
  final bool dailyGoalReached;
}

const int _oneDayMs = 86400000;

int _todayMs() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
}

/// Central gamification engine. Owns XP awarding, daily-goal accounting,
/// streak rollover and level-up detection. Everything else funnels through
/// here so the rules live in one place.
class ProgressionService {
  ProgressionService(this._ref);

  final Ref _ref;

  AwardResult awardXp(int amount) {
    final notifier = _ref.read(xpProvider.notifier);
    final current = _ref.read(xpProvider);
    final today = _todayMs();
    final beforeLevel = current.level;

    final sameDay = current.dailyGoalDateMs == today;
    final dailyBase = sameDay ? current.dailyXpEarned : 0;
    final newDaily = dailyBase + amount;

    final next = current.copyWith(
      totalXp: current.totalXp + amount,
      dailyXpEarned: newDaily,
      dailyGoalDateMs: today,
    );
    notifier.set(next);

    final dailyGoalReached =
        dailyBase < XpRules.dailyGoalXp && newDaily >= XpRules.dailyGoalXp;

    return AwardResult(
      xpGained: amount,
      leveledUp: next.level > beforeLevel,
      newLevel: next.level,
      dailyGoalReached: dailyGoalReached,
    );
  }

  /// Call once when the user does something that counts toward their streak
  /// (e.g. completing a lesson). No-op if already counted today.
  void registerStreakActivity() {
    final notifier = _ref.read(streakProvider.notifier);
    final s = _ref.read(streakProvider);
    final today = _todayMs();
    if (s.lastActiveDateMs == today) return;

    final int newCurrent;
    if (s.lastActiveDateMs == 0) {
      newCurrent = 1;
    } else if (s.lastActiveDateMs == today - _oneDayMs) {
      newCurrent = s.current + 1;
    } else {
      newCurrent = 1; // streak broken
    }

    // Shift the 7-day window so the newest slot represents today.
    final gapDays = s.lastActiveDateMs == 0
        ? 1
        : ((today - s.lastActiveDateMs) ~/ _oneDayMs).clamp(1, 7);
    final window = List<bool>.from(s.last7Days);
    for (var i = 0; i < gapDays; i++) {
      window
        ..removeAt(0)
        ..add(false);
    }
    window[window.length - 1] = true;

    notifier.set(s.copyWith(
      current: newCurrent,
      best: math.max(s.best, newCurrent),
      lastActiveDateMs: today,
      last7Days: window,
    ));
  }
}

final progressionServiceProvider = Provider<ProgressionService>((ref) {
  return ProgressionService(ref);
});
