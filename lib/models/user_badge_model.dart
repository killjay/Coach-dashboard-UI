import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_badge_model.g.dart';

@JsonSerializable()
class UserBadgeModel {
  final String id;
  final String userId;
  final String badgeId;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime earnedDate;

  UserBadgeModel({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.earnedDate,
  });

  factory UserBadgeModel.fromJson(Map<String, dynamic> json) => _$UserBadgeModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserBadgeModelToJson(this);

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




