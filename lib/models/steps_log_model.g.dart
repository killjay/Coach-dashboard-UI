// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'steps_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepsLogModel _$StepsLogModelFromJson(Map<String, dynamic> json) =>
    StepsLogModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      date: StepsLogModel._timestampFromJson(json['date']),
      steps: (json['steps'] as num).toInt(),
      goal: (json['goal'] as num).toInt(),
      loggedAt: StepsLogModel._timestampFromJson(json['loggedAt']),
    );

Map<String, dynamic> _$StepsLogModelToJson(StepsLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'date': StepsLogModel._timestampToJson(instance.date),
      'steps': instance.steps,
      'goal': instance.goal,
      'loggedAt': StepsLogModel._timestampToJson(instance.loggedAt),
    };
