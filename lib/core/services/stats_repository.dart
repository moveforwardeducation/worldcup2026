import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../data/local/hive/hive_boxes.dart';

/// Lifetime gameplay stats shown on the Profile screen.
class UserStats {
  const UserStats({
    required this.lessonsCompleted,
    required this.totalCorrect,
    required this.totalAnswered,
    required this.predictionsMade,
    required this.predictionsCorrect,
  });

  final int lessonsCompleted;
  final int totalCorrect;
  final int totalAnswered;
  final int predictionsMade;
  final int predictionsCorrect;

  int get accuracyPct =>
      totalAnswered == 0 ? 0 : ((totalCorrect / totalAnswered) * 100).round();

  int get predictionAccuracyPct => predictionsMade == 0
      ? 0
      : ((predictionsCorrect / predictionsMade) * 100).round();

  static const empty = UserStats(
    lessonsCompleted: 0,
    totalCorrect: 0,
    totalAnswered: 0,
    predictionsMade: 0,
    predictionsCorrect: 0,
  );
}

class StatsRepository {
  Box get _box => Hive.box(HiveBoxes.settings);

  UserStats read() => UserStats(
        lessonsCompleted: (_box.get('lessonsCompleted') as int?) ?? 0,
        totalCorrect: (_box.get('totalCorrect') as int?) ?? 0,
        totalAnswered: (_box.get('totalAnswered') as int?) ?? 0,
        predictionsMade: (_box.get('predictionsMade') as int?) ?? 0,
        predictionsCorrect: (_box.get('predictionsCorrect') as int?) ?? 0,
      );

  Future<void> recordLesson({required int correct, required int total}) async {
    await _box.put('lessonsCompleted',
        ((_box.get('lessonsCompleted') as int?) ?? 0) + 1);
    await _box.put(
        'totalCorrect', ((_box.get('totalCorrect') as int?) ?? 0) + correct);
    await _box.put(
        'totalAnswered', ((_box.get('totalAnswered') as int?) ?? 0) + total);
  }

  Future<void> recordPrediction({required bool correct}) async {
    await _box.put('predictionsMade',
        ((_box.get('predictionsMade') as int?) ?? 0) + 1);
    if (correct) {
      await _box.put('predictionsCorrect',
          ((_box.get('predictionsCorrect') as int?) ?? 0) + 1);
    }
  }
}

class StatsNotifier extends StateNotifier<UserStats> {
  StatsNotifier(this._repo) : super(_repo.read());
  final StatsRepository _repo;

  Future<void> recordLesson({required int correct, required int total}) async {
    await _repo.recordLesson(correct: correct, total: total);
    state = _repo.read();
  }

  Future<void> recordPrediction({required bool correct}) async {
    await _repo.recordPrediction(correct: correct);
    state = _repo.read();
  }

  void refresh() => state = _repo.read();
}

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository();
});

final statsProvider = StateNotifierProvider<StatsNotifier, UserStats>((ref) {
  return StatsNotifier(ref.read(statsRepositoryProvider));
});
