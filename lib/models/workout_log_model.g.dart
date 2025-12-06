// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutLogModel _$WorkoutLogModelFromJson(Map<String, dynamic> json) =>
    WorkoutLogModel(
      id: json['id'] as String,
      assignedWorkoutId: json['assignedWorkoutId'] as String,
      clientId: json['clientId'] as String,
      date: WorkoutLogModel._timestampFromJson(json['date']),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseLogModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      completed: json['completed'] as bool? ?? false,
      loggedAt: WorkoutLogModel._timestampFromJson(json['loggedAt']),
    );

Map<String, dynamic> _$WorkoutLogModelToJson(WorkoutLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assignedWorkoutId': instance.assignedWorkoutId,
      'clientId': instance.clientId,
      'date': WorkoutLogModel._timestampToJson(instance.date),
      'exercises': instance.exercises,
      'completed': instance.completed,
      'loggedAt': WorkoutLogModel._timestampToJson(instance.loggedAt),
    };
