import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'coach_model.g.dart';

@JsonSerializable()
class CoachModel {
  final String id;
  final String email;
  final String name;
  final List<String> clientIds;
  final Map<String, dynamic>? settings;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  CoachModel({
    required this.id,
    required this.email,
    required this.name,
    this.clientIds = const [],
    this.settings,
    required this.createdAt,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) => _$CoachModelFromJson(json);
  Map<String, dynamic> toJson() => _$CoachModelToJson(this);

  factory CoachModel.fromUserModel(UserModel user) {
    return CoachModel(
      id: user.id,
      email: user.email,
      name: user.name,
      createdAt: user.createdAt,
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

