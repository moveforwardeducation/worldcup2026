import 'package:hive_ce_flutter/hive_flutter.dart';

/// Centralized box names so we never typo them across the app.
class HiveBoxes {
  HiveBoxes._();

  static const String userProfile = 'user_profile';
  static const String xpState = 'xp_state';
  static const String streak = 'streak';
  static const String unlockedCards = 'unlocked_cards';
  static const String completedLessons = 'completed_lessons';
  static const String predictionHistory = 'prediction_history';
  static const String achievementProgress = 'achievement_progress';
  static const String settings = 'settings';

  static Future<void> openAll() async {
    await Future.wait([
      Hive.openBox(userProfile),
      Hive.openBox(xpState),
      Hive.openBox(streak),
      Hive.openBox(unlockedCards),
      Hive.openBox(completedLessons),
      Hive.openBox(predictionHistory),
      Hive.openBox(achievementProgress),
      Hive.openBox(settings),
    ]);
  }
}
