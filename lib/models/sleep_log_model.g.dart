// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SleepLogModel _$SleepLogModelFromJson(Map<String, dynamic> json) =>
    SleepLogModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      date: SleepLogModel._timestampFromJson(json['date']),
      timeInBedMinutes: (json['timeInBedMinutes'] as num).toInt(),
      timeAsleepMinutes: (json['timeAsleepMinutes'] as num).toInt(),
      efficiency: (json['efficiency'] as num).toDouble(),
      loggedAt: SleepLogModel._timestampFromJson(json['loggedAt']),
    );

Map<String, dynamic> _$SleepLogModelToJson(SleepLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'date': SleepLogModel._timestampToJson(instance.date),
      'timeInBedMinutes': instance.timeInBedMinutes,
      'timeAsleepMinutes': instance.timeAsleepMinutes,
      'efficiency': instance.efficiency,
      'loggedAt': SleepLogModel._timestampToJson(instance.loggedAt),
    };
