// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_metrics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BodyMetricsModel _$BodyMetricsModelFromJson(Map<String, dynamic> json) =>
    BodyMetricsModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      date: BodyMetricsModel._timestampFromJson(json['date']),
      weight: (json['weight'] as num?)?.toDouble(),
      bodyFat: (json['bodyFat'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      chest: (json['chest'] as num?)?.toDouble(),
      hips: (json['hips'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      loggedAt: BodyMetricsModel._timestampFromJson(json['loggedAt']),
    );

Map<String, dynamic> _$BodyMetricsModelToJson(BodyMetricsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'date': BodyMetricsModel._timestampToJson(instance.date),
      'weight': instance.weight,
      'bodyFat': instance.bodyFat,
      'waist': instance.waist,
      'chest': instance.chest,
      'hips': instance.hips,
      'bmi': instance.bmi,
      'loggedAt': BodyMetricsModel._timestampToJson(instance.loggedAt),
    };
