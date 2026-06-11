/// XP and level rules for the gamification engine.
class XpRules {
  XpRules._();

  static const int xpCorrectAnswer = 10;
  static const int xpPerfectLesson = 50;
  static const int xpDailyStreak = 25;
  static const int xpPredictionCorrect = 50;
  static const int xpBattleWin = 100;
  static const int dailyGoalXp = 150;

  /// Triangular progression — feels Duolingo-like:
  /// L1->2 needs 100, L2->3 needs 200, L3->4 needs 300, ...
  static int xpForLevel(int level) => 100 * level;

  /// Cumulative XP required to *reach* a given level (level >= 1).
  static int cumulativeXpForLevel(int level) {
    if (level <= 1) return 0;
    final n = level - 1;
    return 100 * n * (n + 1) ~/ 2;
  }

  /// Returns (level, xpIntoLevel, xpForNextLevel) from a total XP value.
  static ({int level, int xpIntoLevel, int xpForNextLevel}) levelFromTotalXp(
    int totalXp,
  ) {
    var level = 1;
    var remaining = totalXp;
    while (remaining >= xpForLevel(level)) {
      remaining -= xpForLevel(level);
      level += 1;
    }
    return (
      level: level,
      xpIntoLevel: remaining,
      xpForNextLevel: xpForLevel(level),
    );
  }
}
