// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lifestyle_goals_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LifestyleGoalsModel _$LifestyleGoalsModelFromJson(Map<String, dynamic> json) =>
    LifestyleGoalsModel(
      activityLevel: $enumDecodeNullable(
        _$ActivityLevelEnumMap,
        json['activityLevel'],
      ),
      fitnessGoal: $enumDecodeNullable(
        _$FitnessGoalEnumMap,
        json['fitnessGoal'],
      ),
    );

Map<String, dynamic> _$LifestyleGoalsModelToJson(
  LifestyleGoalsModel instance,
) => <String, dynamic>{
  'activityLevel': _$ActivityLevelEnumMap[instance.activityLevel],
  'fitnessGoal': _$FitnessGoalEnumMap[instance.fitnessGoal],
};

const _$ActivityLevelEnumMap = {
  ActivityLevel.sedentary: 'sedentary',
  ActivityLevel.lightlyActive: 'lightly_active',
  ActivityLevel.moderatelyActive: 'moderately_active',
  ActivityLevel.veryActive: 'very_active',
};

const _$FitnessGoalEnumMap = {
  FitnessGoal.fatLoss: 'fat_loss',
  FitnessGoal.muscleGain: 'muscle_gain',
  FitnessGoal.maintenance: 'maintenance',
  FitnessGoal.performance: 'performance',
};
