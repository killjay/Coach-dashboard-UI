import 'package:json_annotation/json_annotation.dart';
import 'set_log_model.dart';

part 'exercise_log_model.g.dart';

@JsonSerializable()
class ExerciseLogModel {
  final String exerciseName;
  final List<SetLogModel> sets;
  final bool completed;

  ExerciseLogModel({
    required this.exerciseName,
    required this.sets,
    this.completed = false,
  });

  factory ExerciseLogModel.fromJson(Map<String, dynamic> json) => _$ExerciseLogModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseLogModelToJson(this);
}




