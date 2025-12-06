// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaterLogModel _$WaterLogModelFromJson(Map<String, dynamic> json) =>
    WaterLogModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      date: WaterLogModel._timestampFromJson(json['date']),
      amount: (json['amount'] as num).toDouble(),
      goal: (json['goal'] as num).toDouble(),
      loggedAt: WaterLogModel._timestampFromJson(json['loggedAt']),
    );

Map<String, dynamic> _$WaterLogModelToJson(WaterLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'date': WaterLogModel._timestampToJson(instance.date),
      'amount': instance.amount,
      'goal': instance.goal,
      'loggedAt': WaterLogModel._timestampToJson(instance.loggedAt),
    };
