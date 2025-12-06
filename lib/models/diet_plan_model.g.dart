// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DietPlanModel _$DietPlanModelFromJson(Map<String, dynamic> json) =>
    DietPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      calories: (json['calories'] as num).toInt(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      createdBy: json['createdBy'] as String,
      createdAt: DietPlanModel._timestampFromJson(json['createdAt']),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$DietPlanModelToJson(DietPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'createdBy': instance.createdBy,
      'createdAt': DietPlanModel._timestampToJson(instance.createdAt),
      'description': instance.description,
    };
