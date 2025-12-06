import 'package:json_annotation/json_annotation.dart';

part 'badge_model.g.dart';

@JsonSerializable()
class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String icon; // Icon identifier
  final Map<String, dynamic> criteria; // Criteria for earning the badge

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.criteria,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) => _$BadgeModelFromJson(json);
  Map<String, dynamic> toJson() => _$BadgeModelToJson(this);
}




