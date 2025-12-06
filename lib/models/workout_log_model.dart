import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise_log_model.dart';

part 'workout_log_model.g.dart';

@JsonSerializable()
class WorkoutLogModel {
  final String id;
  final String assignedWorkoutId;
  final String clientId;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime date;
  final List<ExerciseLogModel> exercises;
  final bool completed;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime loggedAt;

  WorkoutLogModel({
    required this.id,
    required this.assignedWorkoutId,
    required this.clientId,
    required this.date,
    required this.exercises,
    this.completed = false,
    required this.loggedAt,
  });

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) => _$WorkoutLogModelFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutLogModelToJson(this);

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




