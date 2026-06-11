import 'package:flutter/material.dart';

enum StageKind {
  learnTeams,
  learnPlayers,
  learnStadiums,
  groupStage,
  roundOf32,
  roundOf16,
  quarterFinals,
  semiFinals,
  finals,
}

extension StageKindX on StageKind {
  String get title {
    switch (this) {
      case StageKind.learnTeams:
        return 'Learn Teams';
      case StageKind.learnPlayers:
        return 'Learn Players';
      case StageKind.learnStadiums:
        return 'Learn Stadiums';
      case StageKind.groupStage:
        return 'Group Stage';
      case StageKind.roundOf32:
        return 'Round of 32';
      case StageKind.roundOf16:
        return 'Round of 16';
      case StageKind.quarterFinals:
        return 'Quarter Finals';
      case StageKind.semiFinals:
        return 'Semi Finals';
      case StageKind.finals:
        return 'Final';
    }
  }
}

@immutable
class JourneyStage {
  const JourneyStage({
    required this.index,
    required this.kind,
    required this.totalLessons,
    required this.completedLessons,
    required this.unlocked,
  });

  final int index;
  final StageKind kind;
  final int totalLessons;
  final int completedLessons;
  final bool unlocked;

  bool get isCompleted => completedLessons >= totalLessons;
  double get progress =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;
}
