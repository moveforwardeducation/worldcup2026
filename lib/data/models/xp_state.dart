import 'package:flutter/material.dart';

import '../../core/constants/xp_rules.dart';

@immutable
class XpState {
  const XpState({
    required this.totalXp,
    required this.dailyXpEarned,
    required this.dailyGoalDateMs,
  });

  final int totalXp;
  final int dailyXpEarned;

  /// Local midnight (epoch ms) marking which day [dailyXpEarned] applies to.
  final int dailyGoalDateMs;

  int get level => XpRules.levelFromTotalXp(totalXp).level;
  int get xpIntoLevel => XpRules.levelFromTotalXp(totalXp).xpIntoLevel;
  int get xpForNextLevel => XpRules.levelFromTotalXp(totalXp).xpForNextLevel;
  double get dailyGoalProgress =>
      (dailyXpEarned / XpRules.dailyGoalXp).clamp(0, 1).toDouble();

  XpState copyWith({
    int? totalXp,
    int? dailyXpEarned,
    int? dailyGoalDateMs,
  }) =>
      XpState(
        totalXp: totalXp ?? this.totalXp,
        dailyXpEarned: dailyXpEarned ?? this.dailyXpEarned,
        dailyGoalDateMs: dailyGoalDateMs ?? this.dailyGoalDateMs,
      );

  Map<String, dynamic> toMap() => {
        'totalXp': totalXp,
        'dailyXpEarned': dailyXpEarned,
        'dailyGoalDateMs': dailyGoalDateMs,
      };

  factory XpState.fromMap(Map map) => XpState(
        totalXp: (map['totalXp'] as int?) ?? 0,
        dailyXpEarned: (map['dailyXpEarned'] as int?) ?? 0,
        dailyGoalDateMs: (map['dailyGoalDateMs'] as int?) ?? 0,
      );

  static const initial = XpState(
    totalXp: 0,
    dailyXpEarned: 0,
    dailyGoalDateMs: 0,
  );
}
