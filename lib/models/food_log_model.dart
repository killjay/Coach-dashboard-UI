import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'food_log_model.g.dart';

@JsonSerializable()
class MealModel {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? photoUrl;

  MealModel({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.photoUrl,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) => _$MealModelFromJson(json);
  Map<String, dynamic> toJson() => _$MealModelToJson(this);
}

@JsonSerializable()
class FoodLogModel {
  final String id;
  final String clientId;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime date;
  final List<MealModel> meals;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime loggedAt;

  FoodLogModel({
    required this.id,
    required this.clientId,
    required this.date,
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.loggedAt,
  });

  factory FoodLogModel.fromJson(Map<String, dynamic> json) => _$FoodLogModelFromJson(json);
  Map<String, dynamic> toJson() => _$FoodLogModelToJson(this);

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return DateTime.now();
  }

  static dynamic _timestampToJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}




