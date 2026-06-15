import 'package:flutter/material.dart';

@immutable
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    required this.current,
    required this.rewardXp,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int target;
  final int current;
  final int rewardXp;

  bool get unlocked => current >= target;
  double get progress => target == 0 ? 0 : (current / target).clamp(0, 1);
  int get clampedCurrent => current > target ? target : current;
}
