// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_screening_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthScreeningModel _$HealthScreeningModelFromJson(
  Map<String, dynamic> json,
) => HealthScreeningModel(
  pcos: json['pcos'] as bool? ?? false,
  diabetes: json['diabetes'] as bool? ?? false,
  thyroidIssues: json['thyroidIssues'] as bool? ?? false,
  hypertension: json['hypertension'] as bool? ?? false,
  otherConditions: json['otherConditions'] as String?,
);

Map<String, dynamic> _$HealthScreeningModelToJson(
  HealthScreeningModel instance,
) => <String, dynamic>{
  'pcos': instance.pcos,
  'diabetes': instance.diabetes,
  'thyroidIssues': instance.thyroidIssues,
  'hypertension': instance.hypertension,
  'otherConditions': instance.otherConditions,
};
