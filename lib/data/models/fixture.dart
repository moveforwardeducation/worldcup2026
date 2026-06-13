import 'package:flutter/foundation.dart';

/// A match the user can predict. The final score is bundled for the demo so
/// results can be revealed; a real build would fetch this from a fixtures API.
@immutable
class Fixture {
  const Fixture({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.dateLabel,
    required this.scoreA,
    required this.scoreB,
    required this.kickoffInMinutes,
    this.kickoffMs,
    this.status,
    this.group,
  });

  final String id;
  final String teamA;
  final String teamB;
  final String dateLabel;
  final int scoreA;
  final int scoreB;

  /// Kickoff offset (minutes) from the stored app anchor — used by the bundled
  /// demo so it can show open/locked/resolved states without real dates.
  final int kickoffInMinutes;

  /// Absolute kickoff time (epoch ms) from the real schedule (Firestore).
  /// When set, this takes precedence over [kickoffInMinutes].
  final int? kickoffMs;

  /// Real match status from the results feed: 'scheduled' | 'in_play' |
  /// 'finished'. Null for bundled demo fixtures (time-window logic is used).
  final String? status;

  /// Group code from the feed, e.g. 'GROUP_A'. Null for knockout matches and
  /// for bundled fixtures (whose group is parsed from [dateLabel] instead).
  final String? group;

  bool get isFinished => status == 'finished';

  /// The group letter ('A'..'L') this fixture belongs to, or null if it's a
  /// knockout match. Prefers the explicit [group] field, else parses the
  /// dateLabel (e.g. 'Group A · MD1').
  String? get groupLetter {
    final g = group;
    if (g != null && g.isNotEmpty) {
      final m = RegExp(r'([A-L])$').firstMatch(g.toUpperCase());
      if (m != null) return m.group(1);
    }
    final m = RegExp(r'Group ([A-L])', caseSensitive: false).firstMatch(dateLabel);
    return m?.group(1)?.toUpperCase();
  }

  /// 0 = team A win, 1 = draw, 2 = team B win.
  int get result {
    if (scoreA > scoreB) return 0;
    if (scoreA == scoreB) return 1;
    return 2;
  }

  factory Fixture.fromJson(Map<String, dynamic> json) => Fixture(
        id: json['id'] as String,
        teamA: json['teamA'] as String,
        teamB: json['teamB'] as String,
        dateLabel: json['dateLabel'] as String,
        scoreA: json['scoreA'] as int,
        scoreB: json['scoreB'] as int,
        kickoffInMinutes: (json['kickoffInMinutes'] as int?) ?? 60,
      );

  /// Builds a fixture from a Firestore `fixtures/{id}` document (real schedule
  /// + results written by the sync pipeline).
  factory Fixture.fromFirestore(String id, Map<String, dynamic> d) => Fixture(
        id: id,
        teamA: (d['teamA'] as String?) ?? '',
        teamB: (d['teamB'] as String?) ?? '',
        dateLabel: (d['dateLabel'] as String?) ?? '',
        scoreA: (d['scoreA'] as num?)?.toInt() ?? 0,
        scoreB: (d['scoreB'] as num?)?.toInt() ?? 0,
        kickoffInMinutes: 0,
        kickoffMs: (d['kickoffMs'] as num?)?.toInt(),
        status: d['status'] as String?,
        group: d['group'] as String?,
      );
}

/// A stored prediction: which outcome the user picked for a fixture.
@immutable
class Prediction {
  const Prediction({required this.fixtureId, required this.pick});

  /// 0 = A win, 1 = draw, 2 = B win.
  final String fixtureId;
  final int pick;

  Map<String, dynamic> toMap() => {'fixtureId': fixtureId, 'pick': pick};

  factory Prediction.fromMap(Map map) => Prediction(
        fixtureId: map['fixtureId'] as String,
        pick: map['pick'] as int,
      );
}
