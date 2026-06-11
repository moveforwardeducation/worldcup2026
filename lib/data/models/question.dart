import 'package:flutter/foundation.dart';

enum QuestionType { team, player, stadium, history }

/// A single multiple-choice question. [subjectId] points at the team/player/
/// stadium used to render the visual; [historyIcon] is used for history Qs.
@immutable
class Question {
  const Question({
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.subjectId,
    this.historyCategory,
  });

  final QuestionType type;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? subjectId;
  final String? historyCategory;

  String get correctAnswer => options[correctIndex];

  factory Question.history(Map<String, dynamic> json) {
    final options = (json['options'] as List).cast<String>();
    return Question(
      type: QuestionType.history,
      prompt: json['prompt'] as String,
      options: options,
      correctIndex: json['correctIndex'] as int,
      historyCategory: json['category'] as String?,
    );
  }
}
