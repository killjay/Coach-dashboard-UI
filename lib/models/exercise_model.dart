import 'package:json_annotation/json_annotation.dart';

part 'exercise_model.g.dart';

@JsonSerializable()
class ExerciseModel {
  final String name;
  final int sets;
  final String reps; // e.g., "8-10" or "10-12"
  final double? weight; // Prescribed weight (optional)
  final String? rpe; // Rate of Perceived Exertion
  final String? notes;
  final String? videoUrl;

  ExerciseModel({
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
    this.rpe,
    this.notes,
    this.videoUrl,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => _$ExerciseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseModelToJson(this);
}




