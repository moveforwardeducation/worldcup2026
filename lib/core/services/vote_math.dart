import 'dart:math' as math;

/// Pure helpers for community-vote tallies. Base counts are deterministic per
/// poll so the demo shows believable, stable percentages; in production these
/// are replaced by real Firestore counters.
class VoteMath {
  VoteMath._();

  static List<int> baseCounts(String pollId, int options) {
    return List.generate(options, (i) {
      final r = math.Random('$pollId#$i'.hashCode);
      return 180 + r.nextInt(1000);
    });
  }

  /// Base counts plus the user's own vote (if any).
  static List<int> withUser(List<int> base, int? userChoice) {
    if (userChoice == null) return base;
    final c = List<int>.from(base);
    if (userChoice >= 0 && userChoice < c.length) c[userChoice] += 1;
    return c;
  }

  /// Display counts = seeded baseline floor + real Firestore tallies + the
  /// user's own pick (if it isn't already reflected in the live numbers).
  static List<int> blend({
    required String pollId,
    required int options,
    required Map<int, int> live,
    int? userChoice,
  }) {
    final c = baseCounts(pollId, options);
    live.forEach((i, v) {
      if (i >= 0 && i < options) c[i] += v;
    });
    if (userChoice != null &&
        userChoice >= 0 &&
        userChoice < options &&
        (live[userChoice] ?? 0) == 0) {
      c[userChoice] += 1;
    }
    return c;
  }

  static int total(List<int> counts) => counts.fold(0, (a, b) => a + b);

  static List<int> percentages(List<int> counts) {
    final t = total(counts);
    if (t == 0) return List.filled(counts.length, 0);
    // Largest-remainder rounding so percentages sum to 100.
    final raw = counts.map((c) => c * 100 / t).toList();
    final floors = raw.map((r) => r.floor()).toList();
    var remainder = 100 - floors.fold(0, (a, b) => a + b);
    final order = List.generate(counts.length, (i) => i)
      ..sort((a, b) => (raw[b] - floors[b]).compareTo(raw[a] - floors[a]));
    for (var i = 0; i < remainder; i++) {
      floors[order[i % order.length]] += 1;
    }
    return floors;
  }
}
