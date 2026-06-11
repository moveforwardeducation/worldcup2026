import 'package:flutter/material.dart';

@immutable
class StreakState {
  const StreakState({
    required this.current,
    required this.best,
    required this.lastActiveDateMs,
    required this.last7Days,
  });

  final int current;
  final int best;

  /// Local midnight (epoch ms) of the last day XP was earned.
  final int lastActiveDateMs;

  /// Most recent 7 days, oldest -> newest. true = active.
  final List<bool> last7Days;

  StreakState copyWith({
    int? current,
    int? best,
    int? lastActiveDateMs,
    List<bool>? last7Days,
  }) =>
      StreakState(
        current: current ?? this.current,
        best: best ?? this.best,
        lastActiveDateMs: lastActiveDateMs ?? this.lastActiveDateMs,
        last7Days: last7Days ?? this.last7Days,
      );

  Map<String, dynamic> toMap() => {
        'current': current,
        'best': best,
        'lastActiveDateMs': lastActiveDateMs,
        'last7Days': last7Days,
      };

  factory StreakState.fromMap(Map map) => StreakState(
        current: (map['current'] as int?) ?? 0,
        best: (map['best'] as int?) ?? 0,
        lastActiveDateMs: (map['lastActiveDateMs'] as int?) ?? 0,
        last7Days: ((map['last7Days'] as List?) ?? const [])
            .cast<bool>()
            .toList(),
      );

  static final initial = StreakState(
    current: 0,
    best: 0,
    lastActiveDateMs: 0,
    last7Days: List<bool>.filled(7, false),
  );
}
