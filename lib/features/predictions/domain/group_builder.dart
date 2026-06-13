import '../../../data/models/fixture.dart';
import '../../../data/models/group.dart';

/// Builds real [GroupInfo]s from a fixture list by bucketing on each fixture's
/// group letter and computing standings from finished matches. Pure (no
/// Firebase / Riverpod), so it's unit-testable.
///
/// Returns an empty list when no fixture carries group information (the caller
/// then falls back to bundled demo groups).
List<GroupInfo> buildGroupsFromFixtures(List<Fixture> fixtures) {
  final byGroup = <String, List<Fixture>>{};
  for (final f in fixtures) {
    final letter = f.groupLetter;
    if (letter == null) continue; // knockout match
    byGroup.putIfAbsent(letter, () => []).add(f);
  }
  if (byGroup.isEmpty) return const [];

  final letters = byGroup.keys.toList()..sort();
  final out = <GroupInfo>[];
  for (final letter in letters) {
    final fs = byGroup[letter]!;

    final teamSet = <String>{};
    for (final f in fs) {
      teamSet
        ..add(f.teamA)
        ..add(f.teamB);
    }
    final pts = {for (final t in teamSet) t: 0};
    final gd = {for (final t in teamSet) t: 0};
    final gf = {for (final t in teamSet) t: 0};

    var total = 0;
    var finishedCount = 0;
    for (final f in fs) {
      total++;
      if (f.status != 'finished') continue;
      finishedCount++;
      final a = f.teamA, b = f.teamB;
      gf[a] = (gf[a] ?? 0) + f.scoreA;
      gf[b] = (gf[b] ?? 0) + f.scoreB;
      gd[a] = (gd[a] ?? 0) + (f.scoreA - f.scoreB);
      gd[b] = (gd[b] ?? 0) + (f.scoreB - f.scoreA);
      if (f.scoreA > f.scoreB) {
        pts[a] = (pts[a] ?? 0) + 3;
      } else if (f.scoreB > f.scoreA) {
        pts[b] = (pts[b] ?? 0) + 3;
      } else {
        pts[a] = (pts[a] ?? 0) + 1;
        pts[b] = (pts[b] ?? 0) + 1;
      }
    }

    // Order teams by standings (points, goal diff, goals for, then id).
    final teams = teamSet.toList()
      ..sort((x, y) {
        final p = (pts[y] ?? 0).compareTo(pts[x] ?? 0);
        if (p != 0) return p;
        final d = (gd[y] ?? 0).compareTo(gd[x] ?? 0);
        if (d != 0) return d;
        final g = (gf[y] ?? 0).compareTo(gf[x] ?? 0);
        if (g != 0) return g;
        return x.compareTo(y);
      });

    final allFinished = total > 0 && finishedCount == total;
    out.add(GroupInfo(
      id: 'grp_$letter',
      name: 'Group $letter',
      teamIds: teams,
      winnerId: teams.first, // current leader; only graded once concluded
      // Encode status in concludeInMinutes so the existing groupStatus()
      // helper treats it as resolved (past) / open (future).
      concludeInMinutes: allFinished ? -100000000 : 100000000,
    ));
  }
  return out;
}
