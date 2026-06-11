import 'package:flutter/foundation.dart';

import 'stage.dart';

/// A lesson is N questions inside a stage. Identified by stage + index.
@immutable
class Lesson {
  const Lesson({
    required this.stage,
    required this.index,
    required this.questionCount,
  });

  final StageKind stage;
  final int index;
  final int questionCount;

  String get id => '${stage.name}_$index';
  String get title => 'Lesson ${index + 1}';
}

/// Result of playing a lesson — used by the result screen and to store stars.
@immutable
class LessonResult {
  const LessonResult({
    required this.lessonId,
    required this.correct,
    required this.total,
    required this.xpEarned,
    required this.coinsEarned,
    required this.stars,
    required this.leveledUp,
    required this.newLevel,
  });

  final String lessonId;
  final int correct;
  final int total;
  final int xpEarned;
  final int coinsEarned;
  final int stars;
  final bool leveledUp;
  final int newLevel;

  bool get isPerfect => correct == total;

  static int starsFor(int correct, int total) {
    if (total == 0) return 0;
    final ratio = correct / total;
    if (ratio >= 0.999) return 3;
    if (ratio >= 0.7) return 2;
    if (ratio >= 0.4) return 1;
    return 0;
  }
}
