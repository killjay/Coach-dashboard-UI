import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise_model.dart';

part 'workout_template_model.g.dart';

@JsonSerializable()
class WorkoutTemplateModel {
  final String id;
  final String name;
  final List<ExerciseModel> exercises;
  final String createdBy; // coachId
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  final String? description;

  WorkoutTemplateModel({
    required this.id,
    required this.name,
    required this.exercises,
    required this.createdBy,
    required this.createdAt,
    this.description,
  });

  factory WorkoutTemplateModel.fromJson(Map<String, dynamic> json) => _$WorkoutTemplateModelFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutTemplateModelToJson(this);

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




