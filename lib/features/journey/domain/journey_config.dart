import '../../../data/models/stage.dart';

/// Static definition of the journey: which stages exist, in order, and how
/// many lessons each contains. Drives unlock gating and the journey map.
class JourneyConfig {
  JourneyConfig._();

  static const int questionsPerLesson = 8;

  /// Stage -> number of lessons. Order here is the progression order.
  static const Map<StageKind, int> lessonCounts = {
    StageKind.learnTeams: 5,
    StageKind.learnPlayers: 5,
    StageKind.learnStadiums: 4,
    StageKind.groupStage: 6,
    StageKind.roundOf32: 4,
    StageKind.roundOf16: 4,
    StageKind.quarterFinals: 3,
    StageKind.semiFinals: 2,
    StageKind.finals: 1,
  };

  static List<StageKind> get stagesInOrder => lessonCounts.keys.toList();

  static int lessonsIn(StageKind stage) => lessonCounts[stage] ?? 0;

  static int get totalLessons =>
      lessonCounts.values.fold(0, (sum, n) => sum + n);
}
