import 'package:json_annotation/json_annotation.dart';

part 'health_screening_model.g.dart';

@JsonSerializable()
class HealthScreeningModel {
  final bool pcos;
  final bool diabetes;
  final bool thyroidIssues;
  final bool hypertension;
  final String? otherConditions;

  HealthScreeningModel({
    this.pcos = false,
    this.diabetes = false,
    this.thyroidIssues = false,
    this.hypertension = false,
    this.otherConditions,
  });

  factory HealthScreeningModel.fromJson(Map<String, dynamic> json) => _$HealthScreeningModelFromJson(json);
  Map<String, dynamic> toJson() => _$HealthScreeningModelToJson(this);

  bool get hasAnyCondition => pcos || diabetes || thyroidIssues || hypertension || (otherConditions != null && otherConditions!.isNotEmpty);
}




