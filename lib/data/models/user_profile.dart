import 'package:flutter/material.dart';

@immutable
class UserProfile {
  const UserProfile({
    required this.username,
    required this.avatarSeed,
    required this.favoriteTeamId,
    required this.createdAtMs,
    this.followedTeamIds = const [],
  });

  final String username;
  final int avatarSeed;

  /// The user's *primary* fan club — receives their XP, shown on Home/Club.
  final String favoriteTeamId;
  final int createdAtMs;

  /// All teams the user follows (includes [favoriteTeamId]). Used to highlight
  /// their teams across leaderboards/predictions and for the "My Teams" strip.
  final List<String> followedTeamIds;

  UserProfile copyWith({
    String? username,
    int? avatarSeed,
    String? favoriteTeamId,
    List<String>? followedTeamIds,
  }) =>
      UserProfile(
        username: username ?? this.username,
        avatarSeed: avatarSeed ?? this.avatarSeed,
        favoriteTeamId: favoriteTeamId ?? this.favoriteTeamId,
        createdAtMs: createdAtMs,
        followedTeamIds: followedTeamIds ?? this.followedTeamIds,
      );

  Map<String, dynamic> toMap() => {
        'username': username,
        'avatarSeed': avatarSeed,
        'favoriteTeamId': favoriteTeamId,
        'createdAtMs': createdAtMs,
        'followedTeamIds': followedTeamIds,
      };

  factory UserProfile.fromMap(Map map) {
    final fav = map['favoriteTeamId'] as String;
    final followed = (map['followedTeamIds'] as List?)?.cast<String>();
    return UserProfile(
      username: map['username'] as String,
      avatarSeed: map['avatarSeed'] as int,
      favoriteTeamId: fav,
      createdAtMs: map['createdAtMs'] as int,
      // Backward-compatible: default to just the primary team.
      followedTeamIds: (followed == null || followed.isEmpty) ? [fav] : followed,
    );
  }
}
