// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PerformanceStats _$PerformanceStatsFromJson(Map<String, dynamic> json) =>
    PerformanceStats(
      averageScore: (json['averageScore'] as num).toDouble(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      totalCorrect: (json['totalCorrect'] as num).toInt(),
      totalIncorrect: (json['totalIncorrect'] as num).toInt(),
      subjectBreakdown: (json['subjectBreakdown'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      topicBreakdown: (json['topicBreakdown'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$PerformanceStatsToJson(PerformanceStats instance) =>
    <String, dynamic>{
      'averageScore': instance.averageScore,
      'totalQuestions': instance.totalQuestions,
      'totalCorrect': instance.totalCorrect,
      'totalIncorrect': instance.totalIncorrect,
      'subjectBreakdown': instance.subjectBreakdown,
      'topicBreakdown': instance.topicBreakdown,
    };
