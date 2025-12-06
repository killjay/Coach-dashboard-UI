// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseLogModel _$ExerciseLogModelFromJson(Map<String, dynamic> json) =>
    ExerciseLogModel(
      exerciseName: json['exerciseName'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map((e) => SetLogModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      completed: json['completed'] as bool? ?? false,
    );

Map<String, dynamic> _$ExerciseLogModelToJson(ExerciseLogModel instance) =>
    <String, dynamic>{
      'exerciseName': instance.exerciseName,
      'sets': instance.sets,
      'completed': instance.completed,
    };
