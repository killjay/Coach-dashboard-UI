// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_workout_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignedWorkoutModel _$AssignedWorkoutModelFromJson(
  Map<String, dynamic> json,
) => AssignedWorkoutModel(
  id: json['id'] as String,
  templateId: json['templateId'] as String,
  clientId: json['clientId'] as String,
  coachId: json['coachId'] as String,
  startDate: AssignedWorkoutModel._timestampFromJson(json['startDate']),
  endDate: AssignedWorkoutModel._timestampFromJsonNullable(json['endDate']),
  status:
      $enumDecodeNullable(_$WorkoutStatusEnumMap, json['status']) ??
      WorkoutStatus.pending,
  assignedAt: AssignedWorkoutModel._timestampFromJson(json['assignedAt']),
);

Map<String, dynamic> _$AssignedWorkoutModelToJson(
  AssignedWorkoutModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'templateId': instance.templateId,
  'clientId': instance.clientId,
  'coachId': instance.coachId,
  'startDate': AssignedWorkoutModel._timestampToJson(instance.startDate),
  'endDate': AssignedWorkoutModel._timestampToJsonNullable(instance.endDate),
  'status': _$WorkoutStatusEnumMap[instance.status]!,
  'assignedAt': AssignedWorkoutModel._timestampToJson(instance.assignedAt),
};

const _$WorkoutStatusEnumMap = {
  WorkoutStatus.pending: 'pending',
  WorkoutStatus.inProgress: 'in_progress',
  WorkoutStatus.completed: 'completed',
  WorkoutStatus.skipped: 'skipped',
};
