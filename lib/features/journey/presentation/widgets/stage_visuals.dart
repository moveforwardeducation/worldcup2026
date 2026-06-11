import 'package:flutter/material.dart';

import '../../../../data/models/stage.dart';

/// Icon + accent colour for each journey stage.
extension StageVisuals on StageKind {
  IconData get icon {
    switch (this) {
      case StageKind.learnTeams:
        return Icons.flag_rounded;
      case StageKind.learnPlayers:
        return Icons.person_rounded;
      case StageKind.learnStadiums:
        return Icons.stadium_rounded;
      case StageKind.groupStage:
        return Icons.grid_view_rounded;
      case StageKind.roundOf32:
        return Icons.sports_soccer_rounded;
      case StageKind.roundOf16:
        return Icons.sports_soccer_rounded;
      case StageKind.quarterFinals:
        return Icons.military_tech_rounded;
      case StageKind.semiFinals:
        return Icons.workspace_premium_rounded;
      case StageKind.finals:
        return Icons.emoji_events_rounded;
    }
  }
}
