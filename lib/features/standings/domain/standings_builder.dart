import '../../../data/models/fixture.dart';

/// One team's row in a group standings table.
class StandingRow {
  StandingRow(this.teamId);

  final String teamId;
  int played = 0;
  int won = 0;
  int drawn = 0;
  int lost = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;

  int get points => won * 3 + drawn;
  int get goalDiff => goalsFor - goalsAgainst;
}

/// A group's full standings table.
class GroupStanding {
  const GroupStanding({required this.name, required this.rows});
  final String name; // e.g. "Group A"
  final List<StandingRow> rows; // sorted best-first
}

/// Builds full standings per group from finished fixtures. Pure (no Firebase /
/// Riverpod) so it's unit-testable. Returns an empty list when no fixture
/// carries group information.
///
/// Tiebreak: points, then goal difference, then goals for, then team id.
/// (Real World Cup tiebreakers also use head-to-head; this is a close
/// approximation suitable for an in-app table.)
List<GroupStanding> buildStandings(List<Fixture> fixtures) {
  final byGroup = <String, List<Fixture>>{};
  for (final f in fixtures) {
    final letter = f.groupLetter;
    if (letter == null) continue;
    byGroup.putIfAbsent(letter, () => []).add(f);
  }
  if (byGroup.isEmpty) return const [];

  final letters = byGroup.keys.toList()..sort();
  final out = <GroupStanding>[];
  for (final letter in letters) {
    final fs = byGroup[letter]!;
    final rows = <String, StandingRow>{};
    StandingRow rowFor(String id) => rows.putIfAbsent(id, () => StandingRow(id));

    // Seed rows for every team that appears (so 0-played teams still show).
    for (final f in fs) {
      rowFor(f.teamA);
      rowFor(f.teamB);
    }

    for (final f in fs) {
      if (f.status != 'finished') continue;
      final a = rowFor(f.teamA);
      final b = rowFor(f.teamB);
      a.played++;
      b.played++;
      a.goalsFor += f.scoreA;
      a.goalsAgainst += f.scoreB;
      b.goalsFor += f.scoreB;
      b.goalsAgainst += f.scoreA;
      if (f.scoreA > f.scoreB) {
        a.won++;
        b.lost++;
      } else if (f.scoreB > f.scoreA) {
        b.won++;
        a.lost++;
      } else {
        a.drawn++;
        b.drawn++;
      }
    }

    final sorted = rows.values.toList()
      ..sort((x, y) {
        final p = y.points.compareTo(x.points);
        if (p != 0) return p;
        final d = y.goalDiff.compareTo(x.goalDiff);
        if (d != 0) return d;
        final g = y.goalsFor.compareTo(x.goalsFor);
        if (g != 0) return g;
        return x.teamId.compareTo(y.teamId);
      });

    out.add(GroupStanding(name: 'Group $letter', rows: sorted));
  }
  return out;
}
