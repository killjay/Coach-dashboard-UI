// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_diet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignedDietModel _$AssignedDietModelFromJson(Map<String, dynamic> json) =>
    AssignedDietModel(
      id: json['id'] as String,
      planId: json['planId'] as String,
      clientId: json['clientId'] as String,
      coachId: json['coachId'] as String,
      startDate: AssignedDietModel._timestampFromJson(json['startDate']),
      endDate: AssignedDietModel._timestampFromJsonNullable(json['endDate']),
      assignedAt: AssignedDietModel._timestampFromJson(json['assignedAt']),
    );

Map<String, dynamic> _$AssignedDietModelToJson(AssignedDietModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'clientId': instance.clientId,
      'coachId': instance.coachId,
      'startDate': AssignedDietModel._timestampToJson(instance.startDate),
      'endDate': AssignedDietModel._timestampToJsonNullable(instance.endDate),
      'assignedAt': AssignedDietModel._timestampToJson(instance.assignedAt),
    };
