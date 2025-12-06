// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientModel _$ClientModelFromJson(Map<String, dynamic> json) => ClientModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  coachId: json['coachId'] as String?,
  onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
  demographics: json['demographics'] == null
      ? null
      : DemographicsModel.fromJson(
          json['demographics'] as Map<String, dynamic>,
        ),
  healthData: json['healthData'] == null
      ? null
      : HealthScreeningModel.fromJson(
          json['healthData'] as Map<String, dynamic>,
        ),
  lifestyleGoals: json['lifestyleGoals'] == null
      ? null
      : LifestyleGoalsModel.fromJson(
          json['lifestyleGoals'] as Map<String, dynamic>,
        ),
  createdAt: ClientModel._timestampFromJson(json['createdAt']),
  profileImageUrl: json['profileImageUrl'] as String?,
);

Map<String, dynamic> _$ClientModelToJson(ClientModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'coachId': instance.coachId,
      'onboardingCompleted': instance.onboardingCompleted,
      'demographics': instance.demographics,
      'healthData': instance.healthData,
      'lifestyleGoals': instance.lifestyleGoals,
      'createdAt': ClientModel._timestampToJson(instance.createdAt),
      'profileImageUrl': instance.profileImageUrl,
    };
