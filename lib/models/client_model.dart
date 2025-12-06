import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import 'demographics_model.dart';
import 'health_screening_model.dart';
import 'lifestyle_goals_model.dart';

part 'client_model.g.dart';

@JsonSerializable()
class ClientModel {
  final String id;
  final String email;
  final String name;
  final String? coachId;
  final bool onboardingCompleted;
  final DemographicsModel? demographics;
  final HealthScreeningModel? healthData;
  final LifestyleGoalsModel? lifestyleGoals;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  final String? profileImageUrl;

  ClientModel({
    required this.id,
    required this.email,
    required this.name,
    this.coachId,
    this.onboardingCompleted = false,
    this.demographics,
    this.healthData,
    this.lifestyleGoals,
    required this.createdAt,
    this.profileImageUrl,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) => _$ClientModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClientModelToJson(this);

  factory ClientModel.fromUserModel(UserModel user) {
    return ClientModel(
      id: user.id,
      email: user.email,
      name: user.name,
      createdAt: user.createdAt,
      profileImageUrl: user.profileImageUrl,
    );
  }

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return DateTime.now();
  }

  static String _timestampToJson(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}




