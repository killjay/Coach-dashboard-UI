// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachModel _$CoachModelFromJson(Map<String, dynamic> json) => CoachModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  clientIds:
      (json['clientIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  settings: json['settings'] as Map<String, dynamic>?,
  createdAt: CoachModel._timestampFromJson(json['createdAt']),
);

Map<String, dynamic> _$CoachModelToJson(CoachModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'clientIds': instance.clientIds,
      'settings': instance.settings,
      'createdAt': CoachModel._timestampToJson(instance.createdAt),
    };
