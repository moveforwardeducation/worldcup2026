import 'dart:math' as math;

import '../../../data/models/player.dart';
import '../../../data/models/question.dart';
import '../../../data/models/stadium.dart';
import '../../../data/models/stage.dart';
import '../../../data/models/team.dart';

/// Generates multiple-choice questions from the seed catalogue. Learning
/// stages produce one challenge type; knockout stages mix all types plus
/// World Cup history.
///
/// Within a single lesson the *answer subject* is guaranteed unique (no
/// repeated team/player/stadium/history prompt) as long as the catalogue is
/// large enough; if it runs out, repeats are allowed as a last resort.
class QuestionFactory {
  QuestionFactory({
    required this.teams,
    required this.players,
    required this.stadiums,
    required this.history,
  });

  final List<Team> teams;
  final List<Player> players;
  final List<Stadium> stadiums;
  final List<Question> history;

  List<Question> buildLesson({
    required StageKind stage,
    required int lessonIndex,
    required int count,
  }) {
    // Seed by stage+lesson so a given lesson is stable across opens.
    final rnd = math.Random(stage.index * 1000 + lessonIndex);
    final used = <String>{};
    final out = <Question>[];
    for (var i = 0; i < count; i++) {
      final q = _questionForStage(stage, rnd, used);
      out.add(q);
      used.add(_keyOf(q));
    }
    return out;
  }

  /// A fresh, non-deterministic mixed set — used by Battle mode.
  List<Question> randomMix(int count) {
    final rnd = math.Random();
    final used = <String>{};
    final out = <Question>[];
    for (var i = 0; i < count; i++) {
      final q = _questionForStage(StageKind.groupStage, rnd, used);
      out.add(q);
      used.add(_keyOf(q));
    }
    return out;
  }

  String _keyOf(Question q) => q.subjectId ?? q.prompt;

  Question _questionForStage(StageKind stage, math.Random rnd, Set<String> used) {
    switch (stage) {
      case StageKind.learnTeams:
        return _teamQuestion(rnd, used);
      case StageKind.learnPlayers:
        return _playerQuestion(rnd, used);
      case StageKind.learnStadiums:
        return _stadiumQuestion(rnd, used);
      default:
        // Knockout stages: rotate through the types for variety, then add
        // history. The modulo keeps a balanced spread per lesson.
        final pick = rnd.nextInt(4);
        switch (pick) {
          case 0:
            return _teamQuestion(rnd, used);
          case 1:
            return _playerQuestion(rnd, used);
          case 2:
            return _stadiumQuestion(rnd, used);
          default:
            return _historyQuestion(rnd, used);
        }
    }
  }

  Team _pickTeam(math.Random rnd, Set<String> used) {
    final available = teams.where((t) => !used.contains(t.id)).toList();
    final pool = available.isEmpty ? teams : available;
    return pool[rnd.nextInt(pool.length)];
  }

  Question _teamQuestion(math.Random rnd, Set<String> used) {
    final target = _pickTeam(rnd, used);
    final distractors = _pick(
      pool: teams.where((t) => t.id != target.id).toList(),
      count: 3,
      rnd: rnd,
    );
    final options = [target, ...distractors]..shuffle(rnd);
    return Question(
      type: QuestionType.team,
      prompt: 'Which national team does this jersey belong to?',
      options: options.map((t) => t.name).toList(),
      correctIndex: options.indexOf(target),
      subjectId: target.id,
    );
  }

  Question _playerQuestion(math.Random rnd, Set<String> used) {
    final available = players.where((p) => !used.contains(p.id)).toList();
    final pool = available.isEmpty ? players : available;
    final target = pool[rnd.nextInt(pool.length)];
    // Prefer same-team distractors so the shirt/flag isn't a giveaway, then
    // fall back to same position, then anyone.
    final sameTeam =
        players.where((p) => p.teamId == target.teamId && p.id != target.id);
    final samePos =
        players.where((p) => p.position == target.position && p.id != target.id);
    final distractorPool = <Player>{...sameTeam, ...samePos, ...players}
      ..removeWhere((p) => p.id == target.id);
    final distractors =
        _pick(pool: distractorPool.toList(), count: 3, rnd: rnd);
    final options = [target, ...distractors]..shuffle(rnd);
    return Question(
      type: QuestionType.player,
      prompt: 'Who is this player?',
      options: options.map((p) => p.name).toList(),
      correctIndex: options.indexOf(target),
      subjectId: target.id,
    );
  }

  Question _stadiumQuestion(math.Random rnd, Set<String> used) {
    final available = stadiums.where((s) => !used.contains(s.id)).toList();
    final pool = available.isEmpty ? stadiums : available;
    final target = pool[rnd.nextInt(pool.length)];

    // Three text-based templates — no fuzzy stadium artwork.
    // 0: "Which stadium is in {city}?"  → answer = stadium name
    // 1: "Which stadium has the nickname '{nickname}'?" → answer = stadium name
    // 2: "In which city is {stadium name}?" → answer = city
    // Skip the nickname template if the target has no nickname.
    final hasNickname = (target.nickname ?? '').isNotEmpty;
    final tpl = hasNickname ? rnd.nextInt(3) : (rnd.nextInt(2) == 0 ? 0 : 2);

    if (tpl == 2) {
      // City answer.
      final distractorPool = stadiums
          .where((s) => s.id != target.id && s.city != target.city)
          .map((s) => s.city)
          .toSet()
          .toList();
      final distractors = _pick(pool: distractorPool, count: 3, rnd: rnd);
      final options = [target.city, ...distractors]..shuffle(rnd);
      return Question(
        type: QuestionType.stadium,
        prompt: 'In which city is ${target.name}?',
        options: options,
        correctIndex: options.indexOf(target.city),
        subjectId: target.id,
      );
    }

    // Templates 0 and 1 — both have a stadium-name answer.
    final distractors = _pick(
      pool: stadiums.where((s) => s.id != target.id).toList(),
      count: 3,
      rnd: rnd,
    );
    final options = [target, ...distractors]..shuffle(rnd);
    final prompt = tpl == 0
        ? 'Which stadium is in ${target.city}?'
        : "Which stadium is nicknamed '${target.nickname}'?";
    return Question(
      type: QuestionType.stadium,
      prompt: prompt,
      options: options.map((s) => s.name).toList(),
      correctIndex: options.indexOf(target),
      subjectId: target.id,
    );
  }

  Question _historyQuestion(math.Random rnd, Set<String> used) {
    if (history.isEmpty) return _teamQuestion(rnd, used);
    final available =
        history.where((h) => !used.contains(h.prompt)).toList();
    final pool = available.isEmpty ? history : available;
    return pool[rnd.nextInt(pool.length)];
  }

  List<T> _pick<T>({
    required List<T> pool,
    required int count,
    required math.Random rnd,
  }) {
    final copy = List<T>.from(pool)..shuffle(rnd);
    final seen = <T>[];
    for (final item in copy) {
      if (seen.length >= count) break;
      if (!seen.contains(item)) seen.add(item);
    }
    return seen;
  }
}
