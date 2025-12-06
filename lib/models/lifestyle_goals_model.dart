import 'package:json_annotation/json_annotation.dart';

part 'lifestyle_goals_model.g.dart';

enum ActivityLevel {
  @JsonValue('sedentary')
  sedentary,
  @JsonValue('lightly_active')
  lightlyActive,
  @JsonValue('moderately_active')
  moderatelyActive,
  @JsonValue('very_active')
  veryActive,
}

enum FitnessGoal {
  @JsonValue('fat_loss')
  fatLoss,
  @JsonValue('muscle_gain')
  muscleGain,
  @JsonValue('maintenance')
  maintenance,
  @JsonValue('performance')
  performance,
}

@JsonSerializable()
class LifestyleGoalsModel {
  final ActivityLevel? activityLevel;
  final FitnessGoal? fitnessGoal;

  LifestyleGoalsModel({
    this.activityLevel,
    this.fitnessGoal,
  });

  factory LifestyleGoalsModel.fromJson(Map<String, dynamic> json) => _$LifestyleGoalsModelFromJson(json);
  Map<String, dynamic> toJson() => _$LifestyleGoalsModelToJson(this);
}




