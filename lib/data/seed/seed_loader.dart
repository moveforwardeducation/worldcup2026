import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/fixture.dart';
import '../models/group.dart';
import '../models/live_challenge.dart';
import '../models/player.dart';
import '../models/team_jersey.dart';
import '../models/question.dart';
import '../models/stadium.dart';
import '../models/team.dart';

/// Loads bundled JSON seed data. In Phase 1 we keep this in memory.
/// Phase 2 will move static content into Drift on first launch.
class SeedLoader {
  Future<List<Team>> loadTeams() async {
    final raw = await rootBundle.loadString('assets/seed/teams.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Team.fromJson).toList();
  }

  Future<List<Player>> loadPlayers() async {
    final raw = await rootBundle.loadString('assets/seed/players.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Player.fromJson).toList();
  }

  Future<List<Stadium>> loadStadiums() async {
    final raw = await rootBundle.loadString('assets/seed/stadiums.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Stadium.fromJson).toList();
  }

  Future<List<Question>> loadHistoryQuestions() async {
    final raw = await rootBundle.loadString('assets/seed/history_questions.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Question.history).toList();
  }

  Future<List<Fixture>> loadFixtures() async {
    final raw = await rootBundle.loadString('assets/seed/fixtures.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Fixture.fromJson).toList();
  }

  Future<List<LiveChallenge>> loadLiveChallenges() async {
    final raw = await rootBundle.loadString('assets/seed/live_challenges.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(LiveChallenge.fromJson).toList();
  }

  Future<List<GroupInfo>> loadGroups() async {
    final raw = await rootBundle.loadString('assets/seed/groups.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(GroupInfo.fromJson).toList();
  }

  Future<List<TeamJersey>> loadJerseys() async {
    final raw = await rootBundle.loadString('assets/seed/jersey_specs.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(TeamJersey.fromJson).toList();
  }
}
