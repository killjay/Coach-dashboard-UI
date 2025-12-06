// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseModel _$ExerciseModelFromJson(Map<String, dynamic> json) =>
    ExerciseModel(
      name: json['name'] as String,
      sets: (json['sets'] as num).toInt(),
      reps: json['reps'] as String,
      weight: (json['weight'] as num?)?.toDouble(),
      rpe: json['rpe'] as String?,
      notes: json['notes'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );

Map<String, dynamic> _$ExerciseModelToJson(ExerciseModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sets': instance.sets,
      'reps': instance.reps,
      'weight': instance.weight,
      'rpe': instance.rpe,
      'notes': instance.notes,
      'videoUrl': instance.videoUrl,
    };
