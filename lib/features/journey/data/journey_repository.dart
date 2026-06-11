import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../data/local/hive/hive_boxes.dart';
import '../../../data/models/lesson.dart';
import '../../../data/models/stage.dart';
import '../domain/journey_config.dart';

/// Persists lesson completion (stars) and derives stage/lesson unlock state.
class JourneyRepository {
  Box get _box => Hive.box(HiveBoxes.completedLessons);

  /// Stars earned for a lesson (0 = not completed).
  int starsFor(String lessonId) => (_box.get(lessonId) as int?) ?? 0;

  bool isCompleted(String lessonId) => _box.containsKey(lessonId);

  Future<void> recordResult(LessonResult result) async {
    final existing = starsFor(result.lessonId);
    if (result.stars > existing) {
      await _box.put(result.lessonId, result.stars);
    } else if (!_box.containsKey(result.lessonId)) {
      await _box.put(result.lessonId, result.stars);
    }
  }

  int completedCountIn(StageKind stage) {
    var n = 0;
    for (var i = 0; i < JourneyConfig.lessonsIn(stage); i++) {
      if (isCompleted(Lesson(stage: stage, index: i, questionCount: 0).id)) {
        n++;
      }
    }
    return n;
  }

  /// Builds the ordered stage list with unlock + progress info.
  List<JourneyStage> stages() {
    final order = JourneyConfig.stagesInOrder;
    final result = <JourneyStage>[];
    var previousComplete = true; // first stage is always unlocked
    for (var i = 0; i < order.length; i++) {
      final kind = order[i];
      final total = JourneyConfig.lessonsIn(kind);
      final done = completedCountIn(kind);
      final unlocked = previousComplete;
      result.add(JourneyStage(
        index: i,
        kind: kind,
        totalLessons: total,
        completedLessons: done,
        unlocked: unlocked,
      ));
      previousComplete = unlocked && done >= total;
    }
    return result;
  }

  /// A lesson is unlocked if its stage is unlocked and either it's the first
  /// lesson or the previous lesson in the stage is complete.
  bool isLessonUnlocked(StageKind stage, int lessonIndex, bool stageUnlocked) {
    if (!stageUnlocked) return false;
    if (lessonIndex == 0) return true;
    return isCompleted(
        Lesson(stage: stage, index: lessonIndex - 1, questionCount: 0).id);
  }

  int totalCompletedLessons() {
    var n = 0;
    for (final stage in JourneyConfig.stagesInOrder) {
      n += completedCountIn(stage);
    }
    return n;
  }
}
