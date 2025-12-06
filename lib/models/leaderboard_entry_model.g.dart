// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardEntryModel _$LeaderboardEntryModelFromJson(
  Map<String, dynamic> json,
) => LeaderboardEntryModel(
  clientId: json['clientId'] as String,
  name: json['name'] as String,
  score: (json['score'] as num).toDouble(),
  metric: $enumDecode(_$LeaderboardMetricEnumMap, json['metric']),
  rank: (json['rank'] as num).toInt(),
  date: LeaderboardEntryModel._timestampFromJson(json['date']),
  isAnonymous: json['isAnonymous'] as bool? ?? false,
);

Map<String, dynamic> _$LeaderboardEntryModelToJson(
  LeaderboardEntryModel instance,
) => <String, dynamic>{
  'clientId': instance.clientId,
  'name': instance.name,
  'score': instance.score,
  'metric': _$LeaderboardMetricEnumMap[instance.metric]!,
  'rank': instance.rank,
  'date': LeaderboardEntryModel._timestampToJson(instance.date),
  'isAnonymous': instance.isAnonymous,
};

const _$LeaderboardMetricEnumMap = {
  LeaderboardMetric.dailySteps: 'daily_steps',
  LeaderboardMetric.monthlySteps: 'monthly_steps',
  LeaderboardMetric.workoutConsistency: 'workout_consistency',
  LeaderboardMetric.progressScore: 'progress_score',
};
