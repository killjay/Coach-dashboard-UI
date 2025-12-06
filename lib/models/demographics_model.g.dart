// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demographics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DemographicsModel _$DemographicsModelFromJson(Map<String, dynamic> json) =>
    DemographicsModel(
      dateOfBirth: DemographicsModel._dateTimeFromJson(json['dateOfBirth']),
      gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$DemographicsModelToJson(DemographicsModel instance) =>
    <String, dynamic>{
      'dateOfBirth': DemographicsModel._dateTimeToJson(instance.dateOfBirth),
      'gender': _$GenderEnumMap[instance.gender],
      'heightCm': instance.heightCm,
      'weightKg': instance.weightKg,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};
