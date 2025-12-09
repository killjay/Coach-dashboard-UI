// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MealModel _$MealModelFromJson(Map<String, dynamic> json) => MealModel(
  name: json['name'] as String,
  calories: (json['calories'] as num).toDouble(),
  protein: (json['protein'] as num).toDouble(),
  carbs: (json['carbs'] as num).toDouble(),
  fat: (json['fat'] as num).toDouble(),
  photoUrl: json['photoUrl'] as String?,
);

Map<String, dynamic> _$MealModelToJson(MealModel instance) => <String, dynamic>{
  'name': instance.name,
  'calories': instance.calories,
  'protein': instance.protein,
  'carbs': instance.carbs,
  'fat': instance.fat,
  'photoUrl': instance.photoUrl,
};

FoodLogModel _$FoodLogModelFromJson(Map<String, dynamic> json) => FoodLogModel(
  id: json['id'] as String,
  clientId: json['clientId'] as String,
  date: FoodLogModel._timestampFromJson(json['date']),
  meals: (json['meals'] as List<dynamic>)
      .map((e) => MealModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCalories: (json['totalCalories'] as num).toDouble(),
  totalProtein: (json['totalProtein'] as num).toDouble(),
  totalCarbs: (json['totalCarbs'] as num).toDouble(),
  totalFat: (json['totalFat'] as num).toDouble(),
  loggedAt: FoodLogModel._timestampFromJson(json['loggedAt']),
);

Map<String, dynamic> _$FoodLogModelToJson(FoodLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'date': FoodLogModel._timestampToJson(instance.date),
      'meals': instance.meals.map((e) => e.toJson()).toList(),
      'totalCalories': instance.totalCalories,
      'totalProtein': instance.totalProtein,
      'totalCarbs': instance.totalCarbs,
      'totalFat': instance.totalFat,
      'loggedAt': FoodLogModel._timestampToJson(instance.loggedAt),
    };
