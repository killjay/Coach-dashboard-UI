import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'leaderboard_entry_model.g.dart';

enum LeaderboardMetric {
  @JsonValue('daily_steps')
  dailySteps,
  @JsonValue('monthly_steps')
  monthlySteps,
  @JsonValue('workout_consistency')
  workoutConsistency,
  @JsonValue('progress_score')
  progressScore,
}

@JsonSerializable()
class LeaderboardEntryModel {
  final String clientId;
  final String name;
  final double score;
  final LeaderboardMetric metric;
  final int rank;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime date;
  final bool isAnonymous;

  LeaderboardEntryModel({
    required this.clientId,
    required this.name,
    required this.score,
    required this.metric,
    required this.rank,
    required this.date,
    this.isAnonymous = false,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) => _$LeaderboardEntryModelFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardEntryModelToJson(this);

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return DateTime.now();
  }

  static dynamic _timestampToJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}




