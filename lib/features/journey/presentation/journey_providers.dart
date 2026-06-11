import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/question.dart';
import '../../../data/models/stage.dart';
import '../../../data/providers.dart';
import '../../learning/data/question_factory.dart';
import '../data/journey_repository.dart';

final journeyRepositoryProvider = Provider<JourneyRepository>((ref) {
  return JourneyRepository();
});

final historyQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  return ref.read(seedLoaderProvider).loadHistoryQuestions();
});

/// Resolves once all seed catalogues are loaded.
final questionFactoryProvider = FutureProvider<QuestionFactory>((ref) async {
  final teams = await ref.watch(teamsProvider.future);
  final players = await ref.watch(playersProvider.future);
  final stadiums = await ref.watch(stadiumsProvider.future);
  final history = await ref.watch(historyQuestionsProvider.future);
  return QuestionFactory(
    teams: teams,
    players: players,
    stadiums: stadiums,
    history: history,
  );
});

/// Holds the ordered stage list. Call [refresh] after a lesson completes.
class JourneyNotifier extends StateNotifier<List<JourneyStage>> {
  JourneyNotifier(this._repo) : super(_repo.stages());
  final JourneyRepository _repo;

  void refresh() => state = _repo.stages();
}

final journeyProvider =
    StateNotifierProvider<JourneyNotifier, List<JourneyStage>>((ref) {
  return JourneyNotifier(ref.read(journeyRepositoryProvider));
});

/// Overall journey completion 0..1 (derived from the stage list).
final journeyProgressProvider = Provider<double>((ref) {
  final stages = ref.watch(journeyProvider);
  final total = stages.fold<int>(0, (s, st) => s + st.totalLessons);
  final done = stages.fold<int>(0, (s, st) => s + st.completedLessons);
  return total == 0 ? 0 : done / total;
});
