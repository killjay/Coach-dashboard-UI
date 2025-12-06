// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutTemplateModel _$WorkoutTemplateModelFromJson(
  Map<String, dynamic> json,
) => WorkoutTemplateModel(
  id: json['id'] as String,
  name: json['name'] as String,
  exercises: (json['exercises'] as List<dynamic>)
      .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdBy: json['createdBy'] as String,
  createdAt: WorkoutTemplateModel._timestampFromJson(json['createdAt']),
  description: json['description'] as String?,
);

Map<String, dynamic> _$WorkoutTemplateModelToJson(
  WorkoutTemplateModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'exercises': instance.exercises,
  'createdBy': instance.createdBy,
  'createdAt': WorkoutTemplateModel._timestampToJson(instance.createdAt),
  'description': instance.description,
};
