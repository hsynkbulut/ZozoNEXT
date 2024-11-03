import 'package:json_annotation/json_annotation.dart';

part 'performance_stats.g.dart';

@JsonSerializable()
class PerformanceStats {
  final double averageScore;
  final int totalQuestions;
  final int totalCorrect;
  final int totalIncorrect;
  final Map<String, double> subjectBreakdown;
  final Map<String, double> topicBreakdown;

  const PerformanceStats({
    required this.averageScore,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.subjectBreakdown,
    required this.topicBreakdown,
  });

  factory PerformanceStats.empty() => const PerformanceStats(
        averageScore: 0,
        totalQuestions: 0,
        totalCorrect: 0,
        totalIncorrect: 0,
        subjectBreakdown: {},
        topicBreakdown: {},
      );

  factory PerformanceStats.fromJson(Map<String, dynamic> json) =>
      _$PerformanceStatsFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceStatsToJson(this);
}
