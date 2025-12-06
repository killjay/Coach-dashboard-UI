import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'diet_plan_model.g.dart';

@JsonSerializable()
class DietPlanModel {
  final String id;
  final String name;
  final int calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double fat; // in grams
  final String createdBy; // coachId
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  final String? description;

  DietPlanModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.createdBy,
    required this.createdAt,
    this.description,
  });

  factory DietPlanModel.fromJson(Map<String, dynamic> json) => _$DietPlanModelFromJson(json);
  Map<String, dynamic> toJson() => _$DietPlanModelToJson(this);

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




