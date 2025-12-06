import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'assigned_workout_model.g.dart';

enum WorkoutStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('skipped')
  skipped,
}

@JsonSerializable()
class AssignedWorkoutModel {
  final String id;
  final String templateId;
  final String clientId;
  final String coachId;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime startDate;
  @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJsonNullable)
  final DateTime? endDate;
  final WorkoutStatus status;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime assignedAt;

  AssignedWorkoutModel({
    required this.id,
    required this.templateId,
    required this.clientId,
    required this.coachId,
    required this.startDate,
    this.endDate,
    this.status = WorkoutStatus.pending,
    required this.assignedAt,
  });

  factory AssignedWorkoutModel.fromJson(Map<String, dynamic> json) => _$AssignedWorkoutModelFromJson(json);
  Map<String, dynamic> toJson() => _$AssignedWorkoutModelToJson(this);

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

  static DateTime? _timestampFromJsonNullable(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  static dynamic _timestampToJsonNullable(DateTime? dateTime) {
    return dateTime != null ? Timestamp.fromDate(dateTime) : null;
  }
}

